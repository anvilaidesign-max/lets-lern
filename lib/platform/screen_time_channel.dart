import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_time/screen_time.dart';

class AppUsage {
  const AppUsage({required this.packageName, required this.appName, required this.minutes});

  final String packageName;
  final String appName;
  final int minutes;
}

/// Dart side of the Android `ScreenTimePlugin` (ARCHITECTURE.md 10.1).
/// Every call fails safe: no permission or no support means "off".
class ScreenTimeChannel {
  const ScreenTimeChannel();

  static const _channel = MethodChannel(screenTimeChannelName);

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  Future<bool> hasPermission() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('hasPermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openPermissionSettings() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('openPermissionSettings');
    } catch (_) {}
  }

  Future<List<AppUsage>> getTodayUsage() async {
    if (!isSupported) return const [];
    try {
      final raw = await _channel.invokeListMethod<Map<dynamic, dynamic>>('getTodayUsage') ?? const [];
      return [
        for (final m in raw)
          AppUsage(
            packageName: m['packageName'] as String? ?? '',
            appName: m['appName'] as String? ?? '',
            minutes: (m['minutes'] as num?)?.toInt() ?? 0,
          ),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<int> getTotalScreenTimeToday() => _intCall('getTotalScreenTimeToday');

  Future<int> getContinuousUsageMinutes() => _intCall('getContinuousUsageMinutes');

  Future<int> _intCall(String method) async {
    if (!isSupported) return 0;
    try {
      return await _channel.invokeMethod<int>(method) ?? 0;
    } catch (_) {
      return 0;
    }
  }
}

final screenTimeChannelProvider = Provider<ScreenTimeChannel>((ref) => const ScreenTimeChannel());
