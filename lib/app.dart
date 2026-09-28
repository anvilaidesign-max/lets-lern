import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/remote/connectivity_service.dart';
import 'data/remote/supabase_service.dart';
import 'data/repositories/settings_repository.dart';
import 'data/sync/sync_service.dart';
import 'features/home/home_providers.dart';
import 'platform/notification_service.dart';

class DailyMindApp extends ConsumerStatefulWidget {
  const DailyMindApp({super.key, this.launchRoute});

  /// Route of the notification that opened the app, if any.
  final String? launchRoute;

  @override
  ConsumerState<DailyMindApp> createState() => _DailyMindAppState();
}

class _DailyMindAppState extends ConsumerState<DailyMindApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    NotificationService.instance.onRoute = (route) => ref.read(routerProvider).push(route);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = widget.launchRoute ?? NotificationService.instance.takePendingRoute();
      if (route != null) ref.read(routerProvider).push(route);
      _refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NotificationService.instance.onRoute = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(todayProvider.notifier).refresh();
      _refresh();
    }
  }

  /// Sync (if online and signed in) and re-plan notifications. Never awaited
  /// by the UI (ARCHITECTURE.md 2: never block the UI on a network call).
  void _refresh() {
    unawaited(() async {
      await ref.read(syncServiceProvider).run();
      await ref.read(notificationSchedulerProvider).reschedule();
    }());
  }

  @override
  Widget build(BuildContext context) {
    // Sync when the connection comes back or the user signs in.
    ref.listen(isOnlineProvider, (previous, next) {
      if (previous?.value == false && next.value == true) _refresh();
    });
    ref.listen(authUserProvider, (previous, next) {
      if (previous?.value == null && next.value != null) _refresh();
    });
    ref.listen(settingsProvider.select((s) => s.onboardingDone), (_, done) {
      if (done) _refresh();
    });

    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));
    return MaterialApp.router(
      title: 'We Learn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
