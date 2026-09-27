import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables/content_tables.dart';
import 'tables/user_tables.dart';

export 'tables/content_tables.dart';
export 'tables/user_tables.dart';

part 'database.g.dart';

/// The local SQLite database. The UI only ever reads from here
/// (ARCHITECTURE.md 3.1); sync keeps it up to date in the background.
@DriftDatabase(tables: [
  Topics,
  ContentItems,
  EssayPrompts,
  UserProgress,
  DailyActivityEntries,
  Essays,
  Settings,
  SyncQueue,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Opens the on-device database. `shareAcrossIsolates` lets the app and a
  /// background task in the same process use one connection.
  factory AppDatabase.open() => AppDatabase(
        driftDatabase(
          name: 'daily_mind',
          native: const DriftNativeOptions(shareAcrossIsolates: true),
        ),
      );

  /// Bump this and add a step in [migration] for every schema change. User
  /// progress must never be dropped on upgrade (ARCHITECTURE.md 13.6).
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Example for the next version:
          // if (from < 2) await m.addColumn(contentItems, contentItems.someNewColumn);
        },
        beforeOpen: (details) async {
          // The WorkManager background engine may open the same file.
          await customStatement('PRAGMA busy_timeout = 5000');
        },
      );

  /// Removes everything that belongs to a user (used when a different
  /// account signs in on this phone). Content stays.
  Future<void> clearUserData() => transaction(() async {
        await delete(userProgress).go();
        await delete(dailyActivityEntries).go();
        await delete(essays).go();
        await delete(syncQueue).go();
      });
}

/// Overridden in `bootstrap.dart` with the opened database.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);
