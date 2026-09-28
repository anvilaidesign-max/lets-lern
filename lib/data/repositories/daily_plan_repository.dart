import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_utils.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/content_item.dart';
import '../../domain/services/next_item_picker.dart';
import '../../domain/services/notification_planner.dart';
import '../../domain/services/topic_rotation_service.dart';
import '../local/daos/content_dao.dart';
import '../local/daos/misc_daos.dart';
import '../local/daos/progress_dao.dart';
import '../local/database.dart';
import '../remote/supabase_service.dart';
import 'settings_repository.dart';

/// Today's topics and what to show next, built from local data only.
class DailyPlanRepository {
  DailyPlanRepository(this._ref);

  final Ref _ref;
  final _random = Random();

  AppDatabase get _db => _ref.read(databaseProvider);
  AppSettings get _settings => _ref.read(settingsProvider);

  /// Seed for the deterministic rotation: the account id, or a per-device id
  /// for guests.
  String get identity =>
      _ref.read(supabaseServiceProvider).userId ??
      _ref.read(settingsProvider.notifier).raw(SettingKeys.deviceId) ??
      'guest';

  List<String> _split(String topics) => topics.split(',').where((s) => s.isNotEmpty).toList();

  /// Topics for [date]. Today's result is saved in `daily_activity` so it stays
  /// the same all day (ARCHITECTURE.md 8.1).
  Future<List<String>> topicsFor(DateTime date) async {
    final dao = ActivityDao(_db);
    final key = DateKeys.dayKey(date);
    final stored = await dao.day(key);
    if (stored != null && stored.topics.isNotEmpty) return _split(stored.topics);

    final topics = await _compute(date, dao);
    final isFuture = DateKeys.startOfDay(date).isAfter(DateKeys.startOfDay(DateTime.now()));
    if (!isFuture) await dao.saveTopics(key, topics);
    return topics;
  }

  Future<List<String>> _compute(DateTime date, ActivityDao dao) async {
    final settings = _settings;
    final yesterday = DateKeys.addDays(date, -1);
    final yRow = await dao.day(DateKeys.dayKey(yesterday));
    final yTopics = yRow != null && yRow.topics.isNotEmpty
        ? _split(yRow.topics)
        : topicsForDay(
            date: yesterday,
            userId: identity,
            enabledTopics: settings.effectiveTopics,
            topicsPerDay: settings.topicsPerDay,
          );
    return topicsForDay(
      date: date,
      userId: identity,
      enabledTopics: settings.effectiveTopics,
      topicsPerDay: settings.topicsPerDay,
      yesterdayTopics: yTopics,
    );
  }

  /// Recomputes today's topics after the topic settings change.
  Future<List<String>> refreshToday() async {
    final dao = ActivityDao(_db);
    final today = DateTime.now();
    final topics = await _compute(today, dao);
    await dao.saveTopics(DateKeys.dayKey(today), topics);
    return topics;
  }

  Future<ContentItem?> nextItem({Set<String> exclude = const {}, ContentGroup? group, List<String>? topics}) async {
    final pool = filterByLevel(await ContentDao(_db).activeForTopics(topics ?? await topicsFor(DateTime.now())), _settings.level);
    if (pool.isEmpty && topics == null) {
      // Today's topics have no content yet: fall back to every enabled topic.
      return nextItem(exclude: exclude, group: group, topics: _settings.effectiveTopics);
    }
    final progress = await ProgressDao(_db).forItems(pool.map((i) => i.id));
    return NextItemPicker.pick(
      pool: pool,
      progress: progress,
      now: DateTime.now(),
      random: _random,
      exclude: exclude,
      onlyGroup: group,
    );
  }

  /// Up to [count] true/false challenges from today's topics.
  Future<List<ContentItem>> quizItems(int count) async {
    var pool = await ContentDao(_db).activeForTopics(await topicsFor(DateTime.now()));
    if (pool.where((i) => i.isChallenge).length < count) {
      pool = await ContentDao(_db).activeForTopics(_settings.effectiveTopics);
    }
    final challenges = filterByLevel(pool.where((i) => i.isChallenge).toList(), _settings.level);
    final progress = await ProgressDao(_db).forItems(challenges.map((i) => i.id));
    return NextItemPicker.pickMany(
      count: count,
      pool: challenges,
      progress: progress,
      now: DateTime.now(),
      random: _random,
    );
  }

  /// Notification slots for the next 2 days with an item for each
  /// (ARCHITECTURE.md 8.3).
  Future<List<(PlannedSlot, ContentItem)>> planNotifications(DateTime now) async {
    final settings = _settings;
    final slots = NotificationPlanner.plan(
      now: now,
      intervalHours: settings.notifIntervalHours,
      quietStart: settings.quietStart,
      quietEnd: settings.quietEnd,
      seed: identity,
    );
    final contentDao = ContentDao(_db);
    final used = <String>{};
    final result = <(PlannedSlot, ContentItem)>[];
    final poolCache = <String, List<ContentItem>>{};

    for (final slot in slots) {
      final key = DateKeys.dayKey(slot.day);
      var pool = poolCache[key];
      if (pool == null) {
        pool = await contentDao.activeForTopics(await topicsFor(slot.day));
        if (pool.isEmpty) pool = await contentDao.activeForTopics(settings.effectiveTopics);
        pool = filterByLevel(pool, settings.level);
        poolCache[key] = pool;
      }
      final progress = await ProgressDao(_db).forItems(pool.map((i) => i.id));
      final item = NextItemPicker.pick(pool: pool, progress: progress, now: now, random: _random, exclude: used);
      if (item == null) continue;
      used.add(item.id);
      result.add((slot, item));
    }
    return result;
  }
}

final dailyPlanRepositoryProvider = Provider<DailyPlanRepository>((ref) => DailyPlanRepository(ref));
