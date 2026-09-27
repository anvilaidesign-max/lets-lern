import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_utils.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/content_item.dart';
import '../../domain/models/progress.dart';
import '../local/daos/misc_daos.dart';
import '../local/daos/progress_dao.dart';
import '../local/database.dart';
import '../sync/sync_queue.dart';
import 'daily_plan_repository.dart';
import 'settings_repository.dart';

/// Records what the user does. Always writes to Drift first, then queues the
/// change for upload (ARCHITECTURE.md 3.1).
class ProgressRepository {
  ProgressRepository(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);
  ProgressDao get _progress => ProgressDao(_db);
  ActivityDao get _activity => ActivityDao(_db);
  SyncQueueWriter get _queue => _ref.read(syncQueueWriterProvider);
  SettingsNotifier get _settings => _ref.read(settingsProvider.notifier);

  Stream<ItemProgress?> watch(String itemId) => _progress.watch(itemId);

  Future<Map<String, ItemProgress>> forItems(Iterable<String> ids) => _progress.forItems(ids);

  /// Called when a card is opened. Facts, lessons and words count as
  /// completed when viewed; challenges count when answered.
  Future<void> recordView(ContentItem item) async {
    final row = await _progress.bump(item.id, seen: 1, now: DateTime.now());
    await _queue.progress(row);
    if (item.type != ContentType.challenge) await _complete(item.id);
  }

  Future<void> recordAnswer(ContentItem item, {required bool correct}) async {
    final row = await _progress.bump(
      item.id,
      correct: correct ? 1 : 0,
      wrong: correct ? 0 : 1,
      lastAnswerCorrect: correct,
      now: DateTime.now(),
    );
    await _queue.progress(row);
    await _complete(item.id);
  }

  Future<bool> toggleSaved(String itemId, {required bool saved}) async {
    final row = await _progress.setSaved(itemId, saved, DateTime.now());
    await _queue.progress(row);
    return row.saved;
  }

  Future<void> report(String itemId, String reason) async {
    await _progress.setReported(itemId, DateTime.now());
    await _queue.report(itemId, reason);
  }

  /// Counts an item towards today's streak once per day.
  Future<void> _complete(String itemId) async {
    final today = DateKeys.dayKey(DateTime.now());
    final stored = _settings.raw(SettingKeys.completedToday) ?? '';
    final parts = stored.split('|');
    final ids = parts.length == 2 && parts[0] == today ? parts[1].split(',').toSet() : <String>{};
    if (!ids.add(itemId)) return;
    await _settings.set(SettingKeys.completedToday, '$today|${ids.join(',')}');

    final topics = await _ref.read(dailyPlanRepositoryProvider).topicsFor(DateTime.now());
    final row = await _activity.incrementCompleted(today, topics);
    await _queue.activity(row);
  }

  Stream<Map<String, int>> watchItemsByDay() => _activity.watchItemsByDay();

  Stream<List<TopicAccuracy>> watchTopicAccuracy() => _progress.watchTopicAccuracy();

  Stream<int> watchItemsLearned() => _progress.watchItemsLearned();
}

final progressRepositoryProvider = Provider<ProgressRepository>((ref) => ProgressRepository(ref));
