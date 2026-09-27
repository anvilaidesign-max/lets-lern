import 'package:drift/drift.dart';

import '../../../domain/models/progress.dart';
import '../database.dart';

class ProgressDao {
  ProgressDao(this.db);
  final AppDatabase db;

  static ItemProgress toModel(ProgressRow r) => ItemProgress(
        itemId: r.itemId,
        seenCount: r.seenCount,
        answeredCorrect: r.answeredCorrect,
        answeredWrong: r.answeredWrong,
        lastAnswerCorrect: r.lastAnswerCorrect,
        lastSeenAt: r.lastSeenAt,
        saved: r.saved,
        savedUpdatedAt: r.savedUpdatedAt,
        reported: r.reported,
      );

  Future<ProgressRow?> row(String itemId) =>
      (db.select(db.userProgress)..where((t) => t.itemId.equals(itemId))).getSingleOrNull();

  Stream<ItemProgress?> watch(String itemId) =>
      (db.select(db.userProgress)..where((t) => t.itemId.equals(itemId)))
          .watchSingleOrNull()
          .map((r) => r == null ? null : toModel(r));

  Future<Map<String, ItemProgress>> forItems(Iterable<String> itemIds) async {
    final ids = itemIds.toList();
    final result = <String, ItemProgress>{};
    for (var i = 0; i < ids.length; i += 500) {
      final chunk = ids.sublist(i, i + 500 > ids.length ? ids.length : i + 500);
      final rows = await (db.select(db.userProgress)..where((t) => t.itemId.isIn(chunk))).get();
      for (final r in rows) {
        result[r.itemId] = toModel(r);
      }
    }
    return result;
  }

  Future<List<ProgressRow>> all() => db.select(db.userProgress).get();

  /// Increments counters with an atomic upsert and returns the new row.
  Future<ProgressRow> bump(
    String itemId, {
    int seen = 0,
    int correct = 0,
    int wrong = 0,
    bool? lastAnswerCorrect,
    required DateTime now,
    bool touchSeen = true,
  }) async {
    await db.into(db.userProgress).insert(
          UserProgressCompanion.insert(
            itemId: itemId,
            seenCount: Value(seen),
            answeredCorrect: Value(correct),
            answeredWrong: Value(wrong),
            lastAnswerCorrect: Value(lastAnswerCorrect),
            lastSeenAt: Value(now),
            updatedAt: Value(now),
          ),
          onConflict: DoUpdate(
            (old) => UserProgressCompanion.custom(
              seenCount: old.seenCount + Constant(seen),
              answeredCorrect: old.answeredCorrect + Constant(correct),
              answeredWrong: old.answeredWrong + Constant(wrong),
              lastAnswerCorrect: lastAnswerCorrect == null ? old.lastAnswerCorrect : Constant(lastAnswerCorrect),
              lastSeenAt: touchSeen ? Constant(now) : old.lastSeenAt,
              updatedAt: Constant(now),
            ),
          ),
        );
    return (await row(itemId))!;
  }

  Future<ProgressRow> setSaved(String itemId, bool saved, DateTime now) async {
    await db.into(db.userProgress).insert(
          UserProgressCompanion.insert(
            itemId: itemId,
            saved: Value(saved),
            savedUpdatedAt: Value(now),
            updatedAt: Value(now),
          ),
          onConflict: DoUpdate(
            (old) => UserProgressCompanion.custom(
              saved: Constant(saved),
              savedUpdatedAt: Constant(now),
              updatedAt: Constant(now),
            ),
          ),
        );
    return (await row(itemId))!;
  }

  Future<void> setReported(String itemId, DateTime now) async {
    await db.into(db.userProgress).insert(
          UserProgressCompanion.insert(itemId: itemId, reported: const Value(true), updatedAt: Value(now)),
          onConflict: DoUpdate(
            (old) => const UserProgressCompanion(reported: Value(true)),
          ),
        );
  }

  Future<void> upsertRows(List<UserProgressCompanion> rows) =>
      db.batch((b) => b.insertAllOnConflictUpdate(db.userProgress, rows));

  /// Per-topic counters for the Progress screen.
  Stream<List<TopicAccuracy>> watchTopicAccuracy() {
    final correct = db.userProgress.answeredCorrect.sum();
    final wrong = db.userProgress.answeredWrong.sum();
    final seen = db.userProgress.itemId.count(filter: db.userProgress.seenCount.isBiggerThanValue(0));
    final query = db.selectOnly(db.userProgress).join([
      innerJoin(db.contentItems, db.contentItems.id.equalsExp(db.userProgress.itemId)),
    ])
      ..addColumns([db.contentItems.topicCode, correct, wrong, seen])
      ..groupBy([db.contentItems.topicCode]);
    return query.watch().map((rows) => [
          for (final r in rows)
            TopicAccuracy(
              topicCode: r.read(db.contentItems.topicCode)!,
              correct: r.read(correct) ?? 0,
              wrong: r.read(wrong) ?? 0,
              seen: r.read(seen) ?? 0,
            ),
        ]);
  }

  Stream<int> watchItemsLearned() {
    final count = db.userProgress.itemId.count();
    return (db.selectOnly(db.userProgress)
          ..addColumns([count])
          ..where(db.userProgress.seenCount.isBiggerThanValue(0)))
        .watchSingle()
        .map((r) => r.read(count) ?? 0);
  }
}
