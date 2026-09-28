import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/logger.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/essay.dart';
import '../../domain/models/progress.dart';
import '../../domain/services/sync_merge.dart';
import '../local/daos/misc_daos.dart';
import '../local/daos/progress_dao.dart';
import '../local/database.dart';
import '../remote/connectivity_service.dart';
import '../remote/edge_functions_api.dart';
import '../remote/supabase_service.dart';
import '../repositories/chapter_repository.dart';
import '../repositories/content_repository.dart';
import '../repositories/essay_repository.dart';
import '../repositories/settings_repository.dart';
import 'sync_queue.dart';

enum SyncOutcome { done, skippedOffline, skippedSignedOut, skippedBusy, failed }

/// Background sync (ARCHITECTURE.md 7.2). Runs on app open, when the
/// connection comes back, and daily from WorkManager. Never blocks the UI.
class SyncService {
  SyncService(this._ref);

  final Ref _ref;
  bool _running = false;

  static const _pageSize = 500;
  static const _pushBatch = 50;
  static const _maxAttempts = 10;
  static const _callTimeout = Duration(seconds: 30);

  AppDatabase get _db => _ref.read(databaseProvider);
  SettingsNotifier get _settings => _ref.read(settingsProvider.notifier);

  Future<SyncOutcome> run() async {
    if (_running) return SyncOutcome.skippedBusy;
    _running = true;
    try {
      final supabase = _ref.read(supabaseServiceProvider);
      final userId = supabase.userId;
      if (supabase.client == null || userId == null) return SyncOutcome.skippedSignedOut;
      if (!await _ref.read(connectivityServiceProvider).isOnline()) return SyncOutcome.skippedOffline;

      await _adoptOrSwitchAccount(userId);
      await _push();
      await _syncProfileName(userId);
      await _pullContent();
      await _pullChapters();
      await _restoreIfNeeded(userId);
      await _sendQueuedEssays();
      return SyncOutcome.done;
    } catch (e, st) {
      AppLogger.error('Sync failed', e, st);
      return SyncOutcome.failed;
    } finally {
      _running = false;
    }
  }

  /// Guest progress is kept and uploaded on first sign-in. If a different
  /// account signs in on this phone, the previous user's data is cleared.
  Future<void> _adoptOrSwitchAccount(String userId) async {
    final owner = _settings.raw(SettingKeys.localOwnerId);
    if (owner == userId) return;
    if (owner == null) {
      final queue = _ref.read(syncQueueWriterProvider);
      for (final row in await ProgressDao(_db).all()) {
        await queue.progress(row);
      }
      for (final row in await ActivityDao(_db).all()) {
        await queue.activity(row);
      }
      for (final row in await _ref.read(chapterRepositoryProvider).allProgress()) {
        await queue.chapterProgress(row);
      }
    } else {
      await _db.clearUserData();
      await _settings.remove(SettingKeys.progressRestoredFor);
      await _settings.remove(SettingKeys.completedToday);
    }
    await _settings.set(SettingKeys.localOwnerId, userId);
  }

  /// PUSH: oldest first; stop at the first failure and retry next sync.
  Future<void> _push() async {
    final dao = SyncQueueDao(_db);
    final dropped = await dao.dropExceeded(_maxAttempts);
    if (dropped > 0) AppLogger.warn('Dropped $dropped sync rows after $_maxAttempts attempts');
    final client = _ref.read(supabaseServiceProvider).client!;
    final userId = _ref.read(supabaseServiceProvider).userId!;

    while (true) {
      final rows = await dao.oldest(_pushBatch);
      if (rows.isEmpty) return;
      final entity = rows.first.entity;
      final batch = rows.takeWhile((r) => r.entity == entity).toList();
      final payloads = [for (final r in batch) jsonDecode(r.payloadJson) as Map<String, dynamic>];
      try {
        switch (entity) {
          case SyncEntity.progress:
            await client.rpc('sync_user_progress', params: {'p_rows': payloads}).timeout(_callTimeout);
          case SyncEntity.activity:
            await client.rpc('sync_daily_activity', params: {'p_rows': payloads}).timeout(_callTimeout);
          case SyncEntity.chapterProgress:
            await client.rpc('sync_chapter_progress', params: {'p_rows': payloads}).timeout(_callTimeout);
          case SyncEntity.report:
            await client
                .from('content_reports')
                .upsert([for (final p in payloads) {...p, 'user_id': userId}], onConflict: 'id', ignoreDuplicates: true)
                .timeout(_callTimeout);
          default:
            AppLogger.warn('Unknown sync entity $entity');
        }
        await dao.deleteIds([for (final r in batch) r.id]);
      } catch (e) {
        AppLogger.warn('Sync push failed for $entity', e);
        await dao.incrementAttempts([for (final r in batch) r.id]);
        return;
      }
    }
  }

  /// Saves the profile name to the account (`profiles.display_name`).
  Future<void> _syncProfileName(String userId) async {
    final name = _settings.raw(SettingKeys.profileName)?.trim() ?? '';
    if (name.isEmpty || name == _settings.raw(SettingKeys.profileSyncedName)) return;
    try {
      final client = _ref.read(supabaseServiceProvider).client!;
      await client.from('profiles').upsert({'id': userId, 'display_name': name}).timeout(_callTimeout);
      await _settings.set(SettingKeys.profileSyncedName, name);
    } catch (e) {
      AppLogger.warn('Profile name sync failed', e);
    }
  }

  /// PULL content in pages of 500 until a short page. A full refresh runs
  /// weekly so the offline pack stays current (ARCHITECTURE.md 7.1).
  Future<void> _pullContent() async {
    final settings = _ref.read(settingsProvider);
    final lastFull = DateTime.tryParse(_settings.raw(SettingKeys.offlinePackRefreshedAt) ?? '');
    final fullRefresh = lastFull == null || DateTime.now().difference(lastFull) > const Duration(days: 7);

    String? since = fullRefresh ? null : settings.lastSyncAt?.toUtc().toIso8601String();
    String? afterId;
    String? serverTime;
    final api = _ref.read(edgeFunctionsApiProvider);
    final content = _ref.read(contentRepositoryProvider);

    for (var page = 0; page < 100; page++) {
      final response = await api.call('get-content-updates', {
        'since': since,
        'after_id': afterId,
        'limit': _pageSize,
        'include_unverified': settings.includeUnverified,
      });
      serverTime ??= response['server_time'] as String?;
      final items = response['items'] as List? ?? const [];
      final applied = await content.applyServerItems(items);
      if (applied.skipped > 0) AppLogger.warn('Skipped ${applied.skipped} invalid items');
      final cursor = response['next_cursor'];
      if (cursor is! Map || items.length < _pageSize) break;
      since = cursor['since'] as String?;
      afterId = cursor['after_id'] as String?;
    }

    final values = <String, String>{};
    if (serverTime != null) values[SettingKeys.lastSyncAt] = serverTime;
    if (fullRefresh) values[SettingKeys.offlinePackRefreshedAt] = DateTime.now().toIso8601String();
    if (values.isNotEmpty) await _settings.setMany(values);
  }

  /// PULL new or updated book chapters (REST, RLS: active chapters only).
  Future<void> _pullChapters() async {
    try {
      final client = _ref.read(supabaseServiceProvider).client!;
      final includeUnverified = _ref.read(settingsProvider).includeUnverified;
      var since = _settings.raw(SettingKeys.chaptersSyncedAt) ?? '1970-01-01T00:00:00Z';
      for (var page = 0; page < 20; page++) {
        var query = client.from('chapters').select().gt('updated_at', since);
        if (!includeUnverified) query = query.eq('verified', true);
        final rows = await query.order('updated_at').limit(100).timeout(_callTimeout);
        if (rows.isEmpty) break;
        await _ref.read(chapterRepositoryProvider).upsertFromJson(rows);
        since = rows.last['updated_at'] as String;
        await _settings.set(SettingKeys.chaptersSyncedAt, since);
        if (rows.length < 100) break;
      }
    } catch (e) {
      AppLogger.warn('Chapter pull failed', e);
    }
  }

  /// PULL progress once per account on this device (new phone or reinstall).
  Future<void> _restoreIfNeeded(String userId) async {
    if (_settings.raw(SettingKeys.progressRestoredFor) == userId) return;
    final client = _ref.read(supabaseServiceProvider).client!;

    final remote = <Map<String, dynamic>>[];
    for (var from = 0; ; from += 1000) {
      final page = await client.from('user_progress').select().range(from, from + 999).timeout(_callTimeout);
      remote.addAll(page);
      if (page.length < 1000) break;
    }
    final progressDao = ProgressDao(_db);
    final local = await progressDao.forItems(remote.map((r) => r['item_id'] as String));
    final merged = <UserProgressCompanion>[];
    for (final r in remote) {
      final id = r['item_id'] as String;
      final remoteCounters = ProgressCounters(
        itemId: id,
        seenCount: (r['seen_count'] as num?)?.toInt() ?? 0,
        answeredCorrect: (r['answered_correct'] as num?)?.toInt() ?? 0,
        answeredWrong: (r['answered_wrong'] as num?)?.toInt() ?? 0,
        lastSeenAt: DateTime.tryParse(r['last_seen_at'] as String? ?? '')?.toLocal(),
        saved: r['saved'] == true,
        savedUpdatedAt: DateTime.tryParse(r['saved_updated_at'] as String? ?? '')?.toLocal(),
      );
      final l = local[id];
      final result = l == null
          ? remoteCounters
          : SyncMerge.progress(
              ProgressCounters(
                itemId: id,
                seenCount: l.seenCount,
                answeredCorrect: l.answeredCorrect,
                answeredWrong: l.answeredWrong,
                lastSeenAt: l.lastSeenAt,
                saved: l.saved,
                savedUpdatedAt: l.savedUpdatedAt,
              ),
              remoteCounters,
            );
      merged.add(UserProgressCompanion(
        itemId: Value(id),
        seenCount: Value(result.seenCount),
        answeredCorrect: Value(result.answeredCorrect),
        answeredWrong: Value(result.answeredWrong),
        lastSeenAt: Value(result.lastSeenAt),
        saved: Value(result.saved),
        savedUpdatedAt: Value(result.savedUpdatedAt),
        lastAnswerCorrect: Value(l?.lastAnswerCorrect),
        reported: Value(l?.reported ?? false),
        updatedAt: Value(DateTime.now()),
      ));
    }
    if (merged.isNotEmpty) await progressDao.upsertRows(merged);

    final activity = await client.from('daily_activity').select().timeout(_callTimeout);
    final activityDao = ActivityDao(_db);
    final localDays = {for (final r in await activityDao.all()) r.day: r};
    await activityDao.upsertRows([
      for (final r in activity)
        DailyActivityEntriesCompanion(
          day: Value(r['day'] as String),
          topics: Value(localDays[r['day']]?.topics ??
              ((r['topics'] as List?)?.whereType<String>().join(',') ?? '')),
          itemsCompleted: Value(SyncMerge.itemsCompleted(
            localDays[r['day']]?.itemsCompleted ?? 0,
            (r['items_completed'] as num?)?.toInt() ?? 0,
          )),
        ),
    ]);

    // Past scored essays, for the history list and chart.
    final essays = await client
        .from('essays')
        .select('id, prompt, image_path, extracted_text, score_total, score_breakdown, feedback, status, created_at')
        .eq('status', 'done')
        .timeout(_callTimeout);
    final essayDao = EssayDao(_db);
    for (final e in essays) {
      if (await essayDao.byId(e['id'] as String) != null) continue;
      final breakdown = e['score_breakdown'] as Map? ?? const {};
      final feedback = e['feedback'] as Map? ?? const {};
      EssayResult? result;
      try {
        result = EssayResult.fromJson({
          'breakdown': breakdown['breakdown'],
          'breakdown_comments': breakdown['comments'],
          ...feedback,
        });
      } catch (_) {}
      await essayDao.insert(EssaysCompanion.insert(
        id: e['id'] as String,
        prompt: e['prompt'] as String? ?? '',
        imagePath: Value(e['image_path'] as String?),
        extractedText: Value(e['extracted_text'] as String?),
        scoreTotal: Value((e['score_total'] as num?)?.toInt()),
        resultJson: Value(result == null ? null : jsonEncode(result.toJson())),
        status: EssayStatus.done.name,
        createdAt: DateTime.tryParse(e['created_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      ));
    }

    try {
      final chapterProgress = await client.from('user_chapter_progress').select().timeout(_callTimeout);
      await _ref.read(chapterRepositoryProvider).mergeRemoteProgress(chapterProgress);
    } catch (e) {
      AppLogger.warn('Chapter progress restore failed', e);
    }

    await _settings.set(SettingKeys.progressRestoredFor, userId);
  }

  Future<void> _sendQueuedEssays() async {
    final essays = _ref.read(essayRepositoryProvider);
    for (final id in await essays.queuedIds()) {
      final result = await essays.submit(id);
      if (!result.isSuccess) break;
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) => SyncService(ref));
