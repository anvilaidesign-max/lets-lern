import 'package:drift/drift.dart';

/// Mirrors `public.topics`.
@DataClassName('TopicRow')
class Topics extends Table {
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {code};
}

/// Mirrors `public.content_items` (same columns).
@DataClassName('ContentItemRow')
@TableIndex(name: 'content_items_topic_code', columns: {#topicCode, #isActive})
class ContentItems extends Table {
  TextColumn get id => text()();
  TextColumn get topicCode => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get statement => text().nullable()();
  BoolColumn get isTrue => boolean().nullable()();
  TextColumn get correctAnswer => text().nullable()();
  TextColumn get explanation => text().nullable()();
  TextColumn get term => text().nullable()();
  TextColumn get translation => text().nullable()();
  TextColumn get exampleSentence => text().nullable()();
  IntColumn get difficulty => integer().withDefault(const Constant(1))();
  TextColumn get sourceName => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  BoolColumn get verified => boolean().withDefault(const Constant(false))();
  BoolColumn get inOfflinePack => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached essay prompts so the essay tab works offline.
@DataClassName('EssayPromptRow')
class EssayPrompts extends Table {
  TextColumn get id => text()();
  TextColumn get topicCode => text().nullable()();
  TextColumn get prompt => text()();

  @override
  Set<Column> get primaryKey => {id};
}
