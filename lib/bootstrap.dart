import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'core/config/env.dart';
import 'data/local/daos/misc_daos.dart';
import 'data/local/database.dart';
import 'data/local/seed_loader.dart';
import 'data/remote/supabase_service.dart';
import 'data/repositories/settings_repository.dart';
import 'domain/models/app_settings.dart';
import 'platform/notification_service.dart';

/// Opens everything the app needs before the first frame. Shared by the app
/// and the WorkManager background task.
Future<ProviderContainer> createAppContainer({required bool background}) async {
  final env = Env.fromEnvironment();
  final db = AppDatabase.open();

  final settingsDao = SettingsDao(db);
  final settings = await settingsDao.all();
  if (settings[SettingKeys.deviceId] == null) {
    final id = const Uuid().v4();
    await settingsDao.set(SettingKeys.deviceId, id);
    settings[SettingKeys.deviceId] = id;
  }

  // The seed pack guarantees content offline from minute one.
  await SeedLoader(db).loadIfNeeded(settings);

  await NotificationService.initTimeZone();
  await SupabaseService.initialize(env);
  await NotificationService.instance.initialize();

  return ProviderContainer(
    overrides: [
      envProvider.overrideWithValue(env),
      databaseProvider.overrideWithValue(db),
      initialSettingsProvider.overrideWithValue(settings),
    ],
  );
}
