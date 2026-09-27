import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'bootstrap.dart';
import 'core/utils/logger.dart';
import 'platform/background_tasks.dart';
import 'platform/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handling (ARCHITECTURE.md 13.3): log, never crash.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.error('FlutterError', details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Uncaught error', error, stack);
    return true;
  };

  final container = await createAppContainer(background: false);
  final launchRoute = await NotificationService.instance.launchRoute();
  unawaited(BackgroundTasks.initialize());

  runApp(UncontrolledProviderScope(
    container: container,
    child: DailyMindApp(launchRoute: launchRoute),
  ));
}
