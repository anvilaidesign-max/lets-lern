import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import '../bootstrap.dart';
import '../core/utils/logger.dart';
import '../data/local/database.dart';
import '../data/repositories/news_repository.dart';
import '../data/sync/sync_service.dart';
import '../features/screen_time/screen_time_service.dart';
import 'notification_service.dart';

const dailyTaskName = 'daily_maintenance';
const screenTimeTaskName = 'screen_time_check';

/// WorkManager entry point. Runs in a separate background engine, so it opens
/// its own database connection and providers.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    ProviderContainer? container;
    try {
      container = await createAppContainer(background: true);
      switch (task) {
        case dailyTaskName:
          await container.read(syncServiceProvider).run();
          await container.read(notificationSchedulerProvider).reschedule();
          await container.read(newsRepositoryProvider).refreshAllIfStale();
        case screenTimeTaskName:
          await container.read(screenTimeServiceProvider).check();
      }
    } catch (e, st) {
      AppLogger.error('Background task $task failed', e, st);
    } finally {
      try {
        await container?.read(databaseProvider).close();
      } catch (_) {}
      container?.dispose();
    }
    // Returning true: failures are retried by the next scheduled run.
    return true;
  });
}

/// Android only in v1. On iOS, notifications are re-planned on every app
/// open (2 days ahead), which covers normal use.
class BackgroundTasks {
  BackgroundTasks._();

  static bool get _supported => !kIsWeb && Platform.isAndroid;

  static Future<void> initialize() async {
    if (!_supported) return;
    try {
      await Workmanager().initialize(callbackDispatcher);
      await Workmanager().registerPeriodicTask(
        dailyTaskName,
        dailyTaskName,
        frequency: const Duration(hours: 12),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
    } catch (e, st) {
      AppLogger.error('WorkManager init failed', e, st);
    }
  }

  /// 15 minutes is the Android minimum for periodic work.
  static Future<void> setScreenTimeCheck({required bool enabled}) async {
    if (!_supported) return;
    try {
      if (enabled) {
        await Workmanager().registerPeriodicTask(
          screenTimeTaskName,
          screenTimeTaskName,
          frequency: const Duration(minutes: 15),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
        );
      } else {
        await Workmanager().cancelByUniqueName(screenTimeTaskName);
      }
    } catch (e, st) {
      AppLogger.error('Screen time task update failed', e, st);
    }
  }
}
