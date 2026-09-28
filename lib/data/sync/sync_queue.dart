import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../local/daos/misc_daos.dart';
import '../local/database.dart';

class SyncEntity {
  SyncEntity._();

  static const progress = 'user_progress';
  static const activity = 'daily_activity';
  static const report = 'content_report';
  static const chapterProgress = 'chapter_progress';
}

/// Writes local changes to the sync queue (ARCHITECTURE.md 7.2). Every write
/// goes to Drift first; this only records what must be uploaded later.
class SyncQueueWriter {
  SyncQueueWriter(this._dao);

  final SyncQueueDao _dao;

  static Map<String, dynamic> progressPayload(ProgressRow r) => {
        'item_id': r.itemId,
        'seen_count': r.seenCount,
        'answered_correct': r.answeredCorrect,
        'answered_wrong': r.answeredWrong,
        'last_seen_at': r.lastSeenAt?.toUtc().toIso8601String(),
        'saved': r.saved,
        'saved_updated_at': r.savedUpdatedAt?.toUtc().toIso8601String(),
      };

  static Map<String, dynamic> activityPayload(DailyActivityRow r) => {
        'day': r.day,
        'topics': r.topics.split(',').where((s) => s.isNotEmpty).toList(),
        'items_completed': r.itemsCompleted,
      };

  static Map<String, dynamic> chapterProgressPayload(ChapterProgressRow r) => {
        'chapter_id': r.chapterId,
        'read_at': r.readAt?.toUtc().toIso8601String(),
        'best_score': r.bestScore,
        'last_score': r.lastScore,
        'attempts': r.attempts,
        'total_questions': r.totalQuestions,
      };

  Future<void> chapterProgress(ChapterProgressRow row) => _dao.enqueue(
        SyncEntity.chapterProgress,
        row.chapterId,
        jsonEncode(chapterProgressPayload(row)),
        DateTime.now(),
      );

  Future<void> progress(ProgressRow row) =>
      _dao.enqueue(SyncEntity.progress, row.itemId, jsonEncode(progressPayload(row)), DateTime.now());

  Future<void> activity(DailyActivityRow row) =>
      _dao.enqueue(SyncEntity.activity, row.day, jsonEncode(activityPayload(row)), DateTime.now());

  Future<void> report(String itemId, String reason) {
    final id = const Uuid().v4();
    return _dao.enqueue(
      SyncEntity.report,
      id,
      jsonEncode({
        'id': id,
        'item_id': itemId,
        'reason': reason,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      }),
      DateTime.now(),
    );
  }
}

final syncQueueWriterProvider = Provider<SyncQueueWriter>(
  (ref) => SyncQueueWriter(SyncQueueDao(ref.watch(databaseProvider))),
);
