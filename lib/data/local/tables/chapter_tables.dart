import 'package:drift/drift.dart';

/// Book chapters per topic (mirrors `public.chapters`). Added in schema v2.
@DataClassName('ChapterRow')
@TableIndex(name: 'chapters_topic_position', columns: {#topicCode, #position})
class Chapters extends Table {
  TextColumn get id => text()();
  TextColumn get topicCode => text()();
  IntColumn get position => integer()();
  TextColumn get title => text()();
  TextColumn get summary => text()();
  TextColumn get body => text()();
  TextColumn get keyPointsJson => text().withDefault(const Constant('[]'))();
  TextColumn get quizJson => text().withDefault(const Constant('[]'))();
  IntColumn get difficulty => integer().withDefault(const Constant(1))();
  TextColumn get sourcesJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Reading and quiz progress per chapter (mirrors
/// `public.user_chapter_progress`). Added in schema v2.
@DataClassName('ChapterProgressRow')
class ChapterProgressEntries extends Table {
  @override
  String get tableName => 'chapter_progress';

  TextColumn get chapterId => text()();
  DateTimeColumn get readAt => dateTime().nullable()();
  IntColumn get bestScore => integer().nullable()();
  IntColumn get lastScore => integer().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get totalQuestions => integer().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {chapterId};
}
