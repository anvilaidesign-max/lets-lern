import 'package:drift/drift.dart';

import '../../../domain/models/progress.dart';
import '../database.dart';

class ActivityDao {
  ActivityDao(this.db);
  final AppDatabase db;

  static DailyActivity toModel(DailyActivityRow r) => DailyActivity(
        day: r.day,
        topics: r.topics.split(',').where((s) => s.isNotEmpty).toList(),
        itemsCompleted: r.itemsCompleted,
      );

  Future<DailyActivityRow?> day(String day) =>
      (db.select(db.dailyActivityEntries)..where((t) => t.day.equals(day))).getSingleOrNull();

  Future<void> saveTopics(String day, List<String> topics) =>
      db.into(db.dailyActivityEntries).insert(
            DailyActivityEntriesCompanion.insert(day: day, topics: topics.join(',')),
            onConflict: DoUpdate((old) => DailyActivityEntriesCompanion.custom(topics: Constant(topics.join(',')))),
          );

  Future<DailyActivityRow> incrementCompleted(String day, List<String> topics) async {
    await db.into(db.dailyActivityEntries).insert(
          DailyActivityEntriesCompanion.insert(
            day: day,
            topics: topics.join(','),
            itemsCompleted: const Value(1),
          ),
          onConflict: DoUpdate(
            (old) => DailyActivityEntriesCompanion.custom(itemsCompleted: old.itemsCompleted + const Constant(1)),
          ),
        );
    return (await this.day(day))!;
  }

  Future<List<DailyActivityRow>> all() => db.select(db.dailyActivityEntries).get();

  Stream<Map<String, int>> watchItemsByDay() =>
      db.select(db.dailyActivityEntries).watch().map((rows) => {for (final r in rows) r.day: r.itemsCompleted});

  Future<void> upsertRows(List<DailyActivityEntriesCompanion> rows) =>
      db.batch((b) => b.insertAllOnConflictUpdate(db.dailyActivityEntries, rows));
}

class SettingsDao {
  SettingsDao(this.db);
  final AppDatabase db;

  Future<Map<String, String>> all() async {
    final rows = await db.select(db.settings).get();
    return {for (final r in rows) r.key: r.value};
  }

  Future<void> set(String key, String value) =>
      db.into(db.settings).insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

  Future<void> setMany(Map<String, String> values) => db.batch((b) {
        for (final e in values.entries) {
          b.insert(db.settings, SettingsCompanion.insert(key: e.key, value: e.value), mode: InsertMode.insertOrReplace);
        }
      });

  Future<void> remove(String key) => (db.delete(db.settings)..where((t) => t.key.equals(key))).go();
}

class SyncQueueDao {
  SyncQueueDao(this.db);
  final AppDatabase db;

  /// Adds a change. An older queued change for the same row is replaced, so
  /// the queue never grows beyond one entry per row.
  Future<void> enqueue(String entity, String entityKey, String payloadJson, DateTime now) =>
      db.transaction(() async {
        await (db.delete(db.syncQueue)
              ..where((t) => t.entity.equals(entity) & t.entityKey.equals(entityKey)))
            .go();
        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
              entity: entity,
              entityKey: entityKey,
              payloadJson: payloadJson,
              createdAt: now,
            ));
      });

  Future<List<SyncQueueRow>> oldest(int limit) =>
      (db.select(db.syncQueue)..orderBy([(t) => OrderingTerm.asc(t.id)])..limit(limit)).get();

  Future<void> deleteIds(List<int> ids) => (db.delete(db.syncQueue)..where((t) => t.id.isIn(ids))).go();

  Future<void> incrementAttempts(List<int> ids) async {
    await (db.update(db.syncQueue)..where((t) => t.id.isIn(ids)))
        .write(SyncQueueCompanion.custom(attempts: db.syncQueue.attempts + const Constant(1)));
  }

  Future<int> dropExceeded(int maxAttempts) =>
      (db.delete(db.syncQueue)..where((t) => t.attempts.isBiggerThanValue(maxAttempts))).go();

  Stream<int> watchCount() {
    final count = db.syncQueue.id.count();
    return (db.selectOnly(db.syncQueue)..addColumns([count])).watchSingle().map((r) => r.read(count) ?? 0);
  }
}

class EssayDao {
  EssayDao(this.db);
  final AppDatabase db;

  Future<EssayRow?> byId(String id) => (db.select(db.essays)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<EssayRow?> watchById(String id) =>
      (db.select(db.essays)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Stream<List<EssayRow>> watchAll() =>
      (db.select(db.essays)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  Future<List<EssayRow>> withStatus(String status) =>
      (db.select(db.essays)..where((t) => t.status.equals(status))).get();

  Future<void> insert(EssaysCompanion row) => db.into(db.essays).insertOnConflictUpdate(row);

  Future<void> patch(String id, EssaysCompanion changes) =>
      (db.update(db.essays)..where((t) => t.id.equals(id))).write(changes);
}
