import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/logger.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/topic.dart';
import '../local/database.dart';
import '../sync/sync_queue.dart';
import 'progress_repository.dart';

/// Topic books: chapters to read, each followed by a quiz.
class ChapterRepository {
  ChapterRepository(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);

  static Chapter toModel(ChapterRow r) => Chapter(
        id: r.id,
        topicCode: r.topicCode,
        position: r.position,
        title: r.title,
        summary: r.summary,
        body: r.body,
        keyPoints: Chapter.decodeStrings(r.keyPointsJson),
        quiz: Chapter.decodeQuiz(r.quizJson),
        difficulty: r.difficulty,
        sources: Chapter.decodeSources(r.sourcesJson),
      );

  static ChapterProgress progressModel(ChapterProgressRow r) => ChapterProgress(
        chapterId: r.chapterId,
        readAt: r.readAt,
        bestScore: r.bestScore,
        lastScore: r.lastScore,
        attempts: r.attempts,
        totalQuestions: r.totalQuestions,
      );

  Stream<List<ChapterEntry>> watchTopic(String topicCode) {
    final query = _db.select(_db.chapters).join([
      leftOuterJoin(_db.chapterProgressEntries, _db.chapterProgressEntries.chapterId.equalsExp(_db.chapters.id)),
    ])
      ..where(_db.chapters.topicCode.equals(topicCode) & _db.chapters.isActive.equals(true))
      ..orderBy([OrderingTerm.asc(_db.chapters.position)]);
    return query.watch().map((rows) => [
          for (final r in rows)
            ChapterEntry(
              toModel(r.readTable(_db.chapters)),
              switch (r.readTableOrNull(_db.chapterProgressEntries)) {
                final p? => progressModel(p),
                null => null,
              },
            ),
        ]);
  }

  /// All active chapters of [topics], for games that reuse chapter quizzes.
  Future<List<Chapter>> chaptersFor(List<String> topics) async {
    if (topics.isEmpty) return const [];
    final rows = await (_db.select(_db.chapters)..where((t) => t.topicCode.isIn(topics) & t.isActive.equals(true))).get();
    return rows.map(toModel).toList();
  }

  Future<Chapter?> chapter(String id) async {
    final row = await (_db.select(_db.chapters)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : toModel(row);
  }

  Stream<ChapterProgress?> watchProgress(String chapterId) =>
      (_db.select(_db.chapterProgressEntries)..where((t) => t.chapterId.equals(chapterId)))
          .watchSingleOrNull()
          .map((r) => r == null ? null : progressModel(r));

  Future<Chapter?> nextChapter(Chapter current) async {
    final row = await (_db.select(_db.chapters)
          ..where((t) =>
              t.topicCode.equals(current.topicCode) &
              t.isActive.equals(true) &
              t.position.isBiggerThanValue(current.position))
          ..orderBy([(t) => OrderingTerm.asc(t.position)])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : toModel(row);
  }

  /// The next chapter to read: the first unread chapter in [topics] (in
  /// order), otherwise the first one whose quiz is not yet passed. One query,
  /// no streams.
  Future<ChapterEntry?> continueReading(List<String> topics) async {
    final rows = await (_db.select(_db.chapters).join([
      leftOuterJoin(_db.chapterProgressEntries, _db.chapterProgressEntries.chapterId.equalsExp(_db.chapters.id)),
    ])
          ..where(_db.chapters.isActive.equals(true))
          ..orderBy([OrderingTerm.asc(_db.chapters.position)]))
        .get();
    final entries = [
      for (final r in rows)
        ChapterEntry(
          toModel(r.readTable(_db.chapters)),
          switch (r.readTableOrNull(_db.chapterProgressEntries)) {
            final p? => progressModel(p),
            null => null,
          },
        ),
    ];
    final order = [...topics, ...Topic.allCodes.where((t) => !topics.contains(t))];
    int rank(ChapterEntry e) {
      final i = order.indexOf(e.chapter.topicCode);
      return i < 0 ? order.length : i;
    }

    entries.sort((a, b) {
      final byTopic = rank(a).compareTo(rank(b));
      return byTopic != 0 ? byTopic : a.chapter.position.compareTo(b.chapter.position);
    });
    for (final e in entries) {
      if (e.progress?.isRead != true) return e;
    }
    for (final e in entries) {
      if (e.chapter.quiz.isNotEmpty && e.progress?.passed != true) return e;
    }
    return null;
  }
  /// Chapters read and total; updates when either table changes.
  Stream<({int read, int total})> watchCounts() => _db
      .customSelect(
        'SELECT (SELECT COUNT(*) FROM chapters WHERE is_active = 1) AS total, '
        '(SELECT COUNT(*) FROM chapter_progress WHERE read_at IS NOT NULL) AS done',
        readsFrom: {_db.chapters, _db.chapterProgressEntries},
      )
      .watchSingle()
      .map((r) => (read: r.read<int>('done'), total: r.read<int>('total')));

  /// Number of active chapters per topic.
  Stream<Map<String, int>> watchCountsByTopic() => _db
      .customSelect(
        'SELECT topic_code, COUNT(*) AS n FROM chapters WHERE is_active = 1 GROUP BY topic_code',
        readsFrom: {_db.chapters},
      )
      .watch()
      .map((rows) => {for (final r in rows) r.read<String>('topic_code'): r.read<int>('n')});

  Future<ChapterProgressRow?> _row(String chapterId) =>
      (_db.select(_db.chapterProgressEntries)..where((t) => t.chapterId.equals(chapterId))).getSingleOrNull();

  /// Marks a chapter read (once). Reading a chapter counts towards the streak.
  Future<void> markRead(Chapter chapter) async {
    final existing = await _row(chapter.id);
    if (existing?.readAt != null) return;
    final now = DateTime.now();
    await _db.into(_db.chapterProgressEntries).insert(
          ChapterProgressEntriesCompanion.insert(chapterId: chapter.id, readAt: Value(now), updatedAt: Value(now)),
          onConflict: DoUpdate((old) => ChapterProgressEntriesCompanion.custom(readAt: Constant(now), updatedAt: Constant(now))),
        );
    await _enqueue(chapter.id);
    await _ref.read(progressRepositoryProvider).completeActivity('chapter:${chapter.id}');
  }

  Future<void> recordQuiz(Chapter chapter, {required int score, required int total}) async {
    final now = DateTime.now();
    final existing = await _row(chapter.id);
    final best = existing?.bestScore == null || score > existing!.bestScore! ? score : existing.bestScore!;
    await _db.into(_db.chapterProgressEntries).insertOnConflictUpdate(ChapterProgressEntriesCompanion(
          chapterId: Value(chapter.id),
          readAt: Value(existing?.readAt ?? now),
          bestScore: Value(best),
          lastScore: Value(score),
          attempts: Value((existing?.attempts ?? 0) + 1),
          totalQuestions: Value(total),
          updatedAt: Value(now),
        ));
    await _enqueue(chapter.id);
    await _ref.read(progressRepositoryProvider).completeActivity('quiz:${chapter.id}');
  }

  Future<void> _enqueue(String chapterId) async {
    final row = await _row(chapterId);
    if (row != null) await _ref.read(syncQueueWriterProvider).chapterProgress(row);
  }

  /// Saves chapters from the seed pack or the server. Invalid ones are
  /// skipped and logged.
  Future<int> upsertFromJson(List<dynamic> list) async {
    final rows = <ChaptersCompanion>[];
    for (final raw in list) {
      final c = raw is Map ? toCompanion(Map<String, dynamic>.from(raw)) : null;
      if (c == null) {
        AppLogger.warn('Skipped invalid chapter ${raw is Map ? raw['id'] : ''}');
        continue;
      }
      rows.add(c);
    }
    if (rows.isNotEmpty) await _db.batch((b) => b.insertAllOnConflictUpdate(_db.chapters, rows));
    return rows.length;
  }

  static ChaptersCompanion? toCompanion(Map<String, dynamic> json) {
    final id = json['id'];
    final topic = json['topic_code'];
    final title = json['title'];
    final body = json['body'];
    final position = json['position'];
    if (id is! String || topic is! String || Topic.byCode(topic) == null) return null;
    if (title is! String || title.trim().isEmpty || body is! String || body.trim().length < 100 || position is! num) return null;
    String encode(Object? v) => jsonEncode(v is List ? v : const []);
    return ChaptersCompanion(
      id: Value(id),
      topicCode: Value(topic),
      position: Value(position.toInt()),
      title: Value(title.trim()),
      summary: Value(json['summary'] is String ? json['summary'] as String : ''),
      body: Value(body),
      keyPointsJson: Value(encode(json['key_points'])),
      quizJson: Value(encode(json['quiz'])),
      difficulty: Value(json['difficulty'] is num ? (json['difficulty'] as num).toInt().clamp(1, 3) : 1),
      sourcesJson: Value(encode(json['sources'])),
      isActive: Value(json['is_active'] != false),
      updatedAt: Value(DateTime.tryParse(json['updated_at'] as String? ?? '')),
    );
  }

  /// Chapter progress from the server (new phone or reinstall). Keeps the
  /// earliest read time and the best score.
  Future<void> mergeRemoteProgress(List<Map<String, dynamic>> remote) async {
    for (final r in remote) {
      final id = r['chapter_id'] as String?;
      if (id == null) continue;
      final local = await _row(id);
      final remoteRead = DateTime.tryParse(r['read_at'] as String? ?? '')?.toLocal();
      final remoteBest = (r['best_score'] as num?)?.toInt();
      final readAt = [local?.readAt, remoteRead].whereType<DateTime>().fold<DateTime?>(null, (a, b) => a == null || b.isBefore(a) ? b : a);
      final best = [local?.bestScore, remoteBest].whereType<int>().fold<int?>(null, (a, b) => a == null || b > a ? b : a);
      final attemptsRemote = (r['attempts'] as num?)?.toInt() ?? 0;
      await _db.into(_db.chapterProgressEntries).insertOnConflictUpdate(ChapterProgressEntriesCompanion(
            chapterId: Value(id),
            readAt: Value(readAt),
            bestScore: Value(best),
            lastScore: Value(local?.lastScore ?? (r['last_score'] as num?)?.toInt()),
            attempts: Value((local?.attempts ?? 0) > attemptsRemote ? local!.attempts : attemptsRemote),
            totalQuestions: Value(local?.totalQuestions ?? (r['total_questions'] as num?)?.toInt()),
            updatedAt: Value(DateTime.now()),
          ));
    }
  }

  Future<List<ChapterProgressRow>> allProgress() => _db.select(_db.chapterProgressEntries).get();
}

final chapterRepositoryProvider = Provider<ChapterRepository>((ref) => ChapterRepository(ref));
