import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/app_settings.dart';
import '../local/daos/misc_daos.dart';
import '../local/database.dart';

/// Raw settings loaded before `runApp`, so the router and theme have correct
/// values on the very first frame. Overridden in bootstrap.
final initialSettingsProvider = Provider<Map<String, String>>(
  (ref) => throw UnimplementedError('initialSettingsProvider must be overridden'),
);

/// App settings, backed by the local `settings` table.
class SettingsNotifier extends Notifier<AppSettings> {
  late Map<String, String> _raw;

  @override
  AppSettings build() {
    _raw = Map.of(ref.read(initialSettingsProvider));
    return AppSettings.fromMap(_raw);
  }

  SettingsDao get _dao => SettingsDao(ref.read(databaseProvider));

  String? raw(String key) => _raw[key];

  Future<void> set(String key, String value) async {
    _raw[key] = value;
    state = AppSettings.fromMap(_raw);
    await _dao.set(key, value);
  }

  Future<void> setMany(Map<String, String> values) async {
    _raw.addAll(values);
    state = AppSettings.fromMap(_raw);
    await _dao.setMany(values);
  }

  /// Wipes every setting except the device id and seed version, so the app
  /// starts again from onboarding.
  Future<void> resetAll() async {
    const keep = {SettingKeys.deviceId, SettingKeys.seedVersion};
    for (final key in _raw.keys.where((k) => !keep.contains(k)).toList()) {
      await _dao.remove(key);
      _raw.remove(key);
    }
    state = AppSettings.fromMap(_raw);
  }

  Future<void> remove(String key) async {
    _raw.remove(key);
    state = AppSettings.fromMap(_raw);
    await _dao.remove(key);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
