import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/errors/app_exception.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/news.dart';
import '../local/database.dart';
import '../remote/connectivity_service.dart';
import '../remote/rss_parser.dart';
import 'settings_repository.dart';

/// Real headlines from public RSS feeds. Fetched on the phone, cached in
/// Drift, and shown from the cache when offline.
class NewsRepository {
  NewsRepository(this._ref, {this._client});

  final Ref _ref;
  final http.Client? _client;

  static const staleAfter = Duration(minutes: 30);
  static const keepFor = Duration(days: 14);
  static const perCategoryLimit = 120;
  static const _timeout = Duration(seconds: 15);
  static const _headers = {
    'User-Agent': 'Mozilla/5.0 (Linux; Android 15) DailyMind/1.0',
    'Accept': 'application/rss+xml, application/atom+xml, application/xml, text/xml;q=0.9, */*;q=0.8',
  };

  AppDatabase get _db => _ref.read(databaseProvider);

  static NewsItem toModel(NewsRow r) => NewsItem(
        id: r.id,
        category: NewsCategory.tryParse(r.category) ?? NewsCategory.world,
        source: r.source,
        title: r.title,
        summary: r.summary,
        link: r.link,
        publishedAt: r.publishedAt,
        imageUrl: r.imageUrl,
      );

  Stream<List<NewsItem>> watch(NewsCategory category) => (_db.select(_db.newsItems)
        ..where((t) => t.category.equals(category.code))
        ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)])
        ..limit(perCategoryLimit))
      .watch()
      .map((rows) => rows.map(toModel).toList());

  DateTime? lastRefreshed(NewsCategory category) =>
      DateTime.tryParse(_ref.read(settingsProvider.notifier).raw(SettingKeys.newsRefreshedAt(category.code)) ?? '');

  bool isStale(NewsCategory category) {
    final last = lastRefreshed(category);
    return last == null || DateTime.now().difference(last) > staleAfter;
  }

  /// Fetches every feed of [category] in parallel. Succeeds if at least one
  /// feed worked; the cached stories stay if all of them fail.
  Future<Result<int>> refresh(NewsCategory category) => Result.guard(() async {
        if (!await _ref.read(connectivityServiceProvider).isOnline()) {
          throw const OfflineException('You are offline. Showing saved news.');
        }
        final sources = NewsSource.forCategory(category);
        final client = _client ?? http.Client();
        try {
          final results = await Future.wait(sources.map((s) => _fetch(client, s)));
          final items = results.expand((r) => r ?? const <NewsItem>[]).toList();
          if (results.every((r) => r == null)) {
            throw const NetworkException('We could not load the news right now. Showing saved stories.');
          }
          await _save(category, items);
          await _ref.read(settingsProvider.notifier).set(
                SettingKeys.newsRefreshedAt(category.code),
                DateTime.now().toIso8601String(),
              );
          return items.length;
        } finally {
          if (_client == null) client.close();
        }
      }, context: 'news refresh ${category.code}');

  Future<void> refreshAllIfStale() async {
    for (final category in NewsCategory.values) {
      if (isStale(category)) await refresh(category);
    }
  }

  Future<List<NewsItem>?> _fetch(http.Client client, NewsSource source) async {
    try {
      final response = await client.get(Uri.parse(source.url), headers: _headers).timeout(_timeout);
      if (response.statusCode != 200) {
        AppLogger.warn('News feed ${source.name} returned ${response.statusCode}');
        return null;
      }
      return RssParser.parse(RssParser.decode(response.bodyBytes), source);
    } catch (e) {
      AppLogger.warn('News feed ${source.name} failed', e);
      return null;
    }
  }

  Future<void> _save(NewsCategory category, List<NewsItem> items) async {
    final now = DateTime.now();
    // Future-dated items (bad feed clocks) are capped at "now".
    final rows = [
      for (final i in items)
        NewsItemsCompanion.insert(
          id: i.id,
          category: category.code,
          source: i.source,
          title: i.title,
          summary: i.summary,
          link: i.link,
          imageUrl: Value(i.imageUrl),
          publishedAt: i.publishedAt.isAfter(now) ? now : i.publishedAt,
          fetchedAt: now,
        ),
    ];
    await _db.transaction(() async {
      await _db.batch((b) => b.insertAllOnConflictUpdate(_db.newsItems, rows));
      await (_db.delete(_db.newsItems)
            ..where((t) => t.category.equals(category.code) & t.publishedAt.isSmallerThanValue(now.subtract(keepFor))))
          .go();
    });
  }
}

final newsRepositoryProvider = Provider<NewsRepository>((ref) => NewsRepository(ref));
