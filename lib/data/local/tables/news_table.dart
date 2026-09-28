import 'package:drift/drift.dart';

/// Cached news headlines, so the News tab shows the latest saved stories
/// offline. Added in schema version 2.
@DataClassName('NewsRow')
@TableIndex(name: 'news_items_category_published', columns: {#category, #publishedAt})
class NewsItems extends Table {
  TextColumn get id => text()();
  TextColumn get category => text()();
  TextColumn get source => text()();
  TextColumn get title => text()();
  TextColumn get summary => text()();
  TextColumn get link => text()();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get publishedAt => dateTime()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
