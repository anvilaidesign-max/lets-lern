import 'package:drift/drift.dart';

import '../../../domain/models/content_item.dart';
import '../database.dart';

class ContentDao {
  ContentDao(this.db);
  final AppDatabase db;

  static ContentItem toModel(ContentItemRow r) => ContentItem(
        id: r.id,
        topicCode: r.topicCode,
        type: ContentType.tryParse(r.type) ?? ContentType.fact,
        title: r.title,
        body: r.body,
        statement: r.statement,
        isTrue: r.isTrue,
        correctAnswer: r.correctAnswer,
        explanation: r.explanation,
        term: r.term,
        translation: r.translation,
        exampleSentence: r.exampleSentence,
        difficulty: r.difficulty,
        sourceName: r.sourceName,
        sourceUrl: r.sourceUrl,
        verified: r.verified,
        inOfflinePack: r.inOfflinePack,
        isActive: r.isActive,
        updatedAt: r.updatedAt,
      );

  Future<ContentItem?> byId(String id) async {
    final row = await (db.select(db.contentItems)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : toModel(row);
  }

  Stream<ContentItem?> watchById(String id) =>
      (db.select(db.contentItems)..where((t) => t.id.equals(id)))
          .watchSingleOrNull()
          .map((r) => r == null ? null : toModel(r));

  Future<List<ContentItem>> activeForTopics(List<String> topics) async {
    if (topics.isEmpty) return const [];
    final rows = await (db.select(db.contentItems)
          ..where((t) => t.topicCode.isIn(topics) & t.isActive.equals(true)))
        .get();
    return rows.map(toModel).toList();
  }

  Future<List<ContentItem>> page({
    required String topic,
    List<String>? types,
    required int limit,
    required int offset,
  }) async {
    final query = db.select(db.contentItems)
      ..where((t) {
        var cond = t.topicCode.equals(topic) & t.isActive.equals(true);
        if (types != null) cond = cond & t.type.isIn(types);
        return cond;
      })
      ..orderBy([(t) => OrderingTerm.asc(t.type), (t) => OrderingTerm.asc(t.title)])
      ..limit(limit, offset: offset);
    return (await query.get()).map(toModel).toList();
  }

  Stream<List<ContentItem>> watchSaved() {
    final query = db.select(db.contentItems).join([
      innerJoin(db.userProgress, db.userProgress.itemId.equalsExp(db.contentItems.id)),
    ])
      ..where(db.userProgress.saved.equals(true) & db.contentItems.isActive.equals(true))
      ..orderBy([OrderingTerm.desc(db.userProgress.savedUpdatedAt)]);
    return query.watch().map((rows) => [for (final r in rows) toModel(r.readTable(db.contentItems))]);
  }

  Stream<Map<String, int>> watchCountsByTopic() {
    final count = db.contentItems.id.count();
    final query = db.selectOnly(db.contentItems)
      ..addColumns([db.contentItems.topicCode, count])
      ..where(db.contentItems.isActive.equals(true))
      ..groupBy([db.contentItems.topicCode]);
    return query.watch().map((rows) => {
          for (final r in rows) r.read(db.contentItems.topicCode)!: r.read(count) ?? 0,
        });
  }

  Future<int> countActive() async {
    final count = db.contentItems.id.count();
    final row = await (db.selectOnly(db.contentItems)
          ..addColumns([count])
          ..where(db.contentItems.isActive.equals(true)))
        .getSingle();
    return row.read(count) ?? 0;
  }

  Future<Map<String, DateTime?>> updatedAtFor(Iterable<String> ids) async {
    final list = ids.toList();
    final result = <String, DateTime?>{};
    for (var i = 0; i < list.length; i += 500) {
      final chunk = list.sublist(i, i + 500 > list.length ? list.length : i + 500);
      final rows = await (db.selectOnly(db.contentItems)
            ..addColumns([db.contentItems.id, db.contentItems.updatedAt])
            ..where(db.contentItems.id.isIn(chunk)))
          .get();
      for (final r in rows) {
        result[r.read(db.contentItems.id)!] = r.read(db.contentItems.updatedAt);
      }
    }
    return result;
  }

  Future<void> upsertAll(List<ContentItemsCompanion> rows) =>
      db.batch((b) => b.insertAllOnConflictUpdate(db.contentItems, rows));

  Future<void> deactivate(List<String> ids) async {
    if (ids.isEmpty) return;
    await (db.update(db.contentItems)..where((t) => t.id.isIn(ids)))
        .write(const ContentItemsCompanion(isActive: Value(false)));
  }

  Future<void> upsertPrompts(List<EssayPromptsCompanion> rows) =>
      db.batch((b) => b.insertAllOnConflictUpdate(db.essayPrompts, rows));

  Future<List<EssayPromptRow>> prompts() =>
      (db.select(db.essayPrompts)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Future<void> upsertTopics(List<TopicsCompanion> rows) =>
      db.batch((b) => b.insertAllOnConflictUpdate(db.topics, rows));
}
