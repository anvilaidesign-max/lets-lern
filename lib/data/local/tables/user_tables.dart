import 'package:drift/drift.dart';

/// Mirrors `public.user_progress` for the signed-in user (or the guest).
/// `lastAnswerCorrect` and `reported` are local-only helpers.
@DataClassName('ProgressRow')
class UserProgress extends Table {
  TextColumn get itemId => text()();
  IntColumn get seenCount => integer().withDefault(const Constant(0))();
  IntColumn get answeredCorrect => integer().withDefault(const Constant(0))();
  IntColumn get answeredWrong => integer().withDefault(const Constant(0))();
  BoolColumn get lastAnswerCorrect => boolean().nullable()();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  BoolColumn get saved => boolean().withDefault(const Constant(false))();
  DateTimeColumn get savedUpdatedAt => dateTime().nullable()();
  BoolColumn get reported => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {itemId};
}

/// Mirrors `public.daily_activity`. `day` is the local `yyyy-MM-dd`, `topics`
/// a comma separated list of topic codes.
@DataClassName('DailyActivityRow')
class DailyActivityEntries extends Table {
  @override
  String get tableName => 'daily_activity';

  TextColumn get day => text()();
  TextColumn get topics => text()();
  IntColumn get itemsCompleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {day};
}

/// Essay metadata only; the photo stays as a file on the phone
/// (ARCHITECTURE.md 6).
@DataClassName('EssayRow')
class Essays extends Table {
  TextColumn get id => text()();
  TextColumn get prompt => text()();
  TextColumn get localImagePath => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get extractedText => text().nullable()();
  IntColumn get scoreTotal => integer().nullable()();
  TextColumn get resultJson => text().nullable()();
  TextColumn get status => text()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Changes waiting to be pushed (ARCHITECTURE.md 6, 7.2). `entityKey` lets a
/// newer change to the same row replace an older queued one.
@DataClassName('SyncQueueRow')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entity => text()();
  TextColumn get entityKey => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
}
