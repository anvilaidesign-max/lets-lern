import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/utils/date_utils.dart';
import '../core/utils/logger.dart';
import '../data/repositories/daily_plan_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../domain/models/content_item.dart';
import '../domain/services/notification_planner.dart';

/// Local notifications (ARCHITECTURE.md 8.3). Scheduled on the phone, so they
/// work offline. The payload is the route to open, e.g. `/card/{itemId}`.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  String? _pendingRoute;

  /// Set by the app once the router exists.
  void Function(String route)? onRoute;

  static const _learningIdStart = 1000;
  static const _learningIdEnd = 1200;
  static const _breakId = 2000;
  static const _dailyBreakIdStart = 3000;
  static const _essayReadyId = 4000;
  static const _actionTrue = 'answer_true';
  static const _actionFalse = 'answer_false';
  static const _challengeCategory = 'challenge';

  static Future<void> initTimeZone() async {
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      AppLogger.warn('Could not read the local time zone, using UTC', e);
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    try {
      await _plugin.initialize(
        settings: InitializationSettings(
          android: const AndroidInitializationSettings('@drawable/ic_notification'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            notificationCategories: [
              DarwinNotificationCategory(
                _challengeCategory,
                actions: [
                  DarwinNotificationAction.plain(_actionTrue, 'True',
                      options: {DarwinNotificationActionOption.foreground}),
                  DarwinNotificationAction.plain(_actionFalse, 'False',
                      options: {DarwinNotificationActionOption.foreground}),
                ],
              ),
            ],
          ),
        ),
        onDidReceiveNotificationResponse: _onResponse,
      );
      _initialized = true;
    } catch (e, st) {
      AppLogger.error('Notifications failed to initialize', e, st);
    }
  }

  static String? routeFor(NotificationResponse response) {
    final route = response.payload;
    if (route == null || !route.startsWith('/')) return null;
    return switch (response.actionId) {
      _actionTrue => '$route?answer=true',
      _actionFalse => '$route?answer=false',
      _ => route,
    };
  }

  void _onResponse(NotificationResponse response) {
    final route = routeFor(response);
    if (route == null) return;
    final handler = onRoute;
    if (handler != null) {
      handler(route);
    } else {
      _pendingRoute = route;
    }
  }

  /// The route of the notification that launched the app, if any.
  Future<String?> launchRoute() async {
    if (!_initialized) return null;
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      final response = details?.notificationResponse;
      if (details?.didNotificationLaunchApp == true && response != null) return routeFor(response);
    } catch (e) {
      AppLogger.warn('launch details failed', e);
    }
    return null;
  }

  String? takePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  /// Asks for permission (Android 13+ and iOS). Returns whether granted.
  Future<bool> requestPermission() async {
    if (!_initialized) return false;
    try {
      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        return await android?.requestNotificationsPermission() ?? false;
      }
      if (Platform.isIOS) {
        final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
      }
    } catch (e) {
      AppLogger.warn('Notification permission request failed', e);
    }
    return false;
  }

  Future<bool> areEnabled() async {
    if (!_initialized) return false;
    try {
      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        return await android?.areNotificationsEnabled() ?? false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  NotificationDetails _learningDetails(ContentItem item, NotificationText text) {
    final isChallenge = item.type == ContentType.challenge;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'learning',
        'Learning moments',
        channelDescription: 'Short facts, words and challenges through the day',
        styleInformation: BigTextStyleInformation(text.body),
        actions: isChallenge
            ? const [
                AndroidNotificationAction(_actionTrue, 'True', showsUserInterface: true),
                AndroidNotificationAction(_actionFalse, 'False', showsUserInterface: true),
              ]
            : null,
      ),
      iOS: DarwinNotificationDetails(categoryIdentifier: isChallenge ? _challengeCategory : null),
    );
  }

  static const _reminderDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'breaks',
      'Brain breaks',
      channelDescription: 'Reminders to take a break from your phone',
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> _cancelRange(int start, int end) async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      if (p.id >= start && p.id < end) await _plugin.cancel(id: p.id);
    }
  }

  /// Replaces all planned learning notifications. Uses inexact scheduling,
  /// so no exact alarm permission is needed.
  Future<void> scheduleLearning(List<(PlannedSlot, ContentItem)> plan) async {
    if (!_initialized) return;
    try {
      await _cancelRange(_learningIdStart, _learningIdEnd);
      var id = _learningIdStart;
      for (final (slot, item) in plan.take(_learningIdEnd - _learningIdStart)) {
        final text = notificationTextFor(item);
        await _plugin.zonedSchedule(
          id: id++,
          scheduledDate: tz.TZDateTime.from(slot.time, tz.local),
          notificationDetails: _learningDetails(item, text),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: text.title,
          body: text.body,
          payload: '/card/${item.id}',
        );
      }
    } catch (e, st) {
      AppLogger.error('Scheduling notifications failed', e, st);
    }
  }

  Future<void> cancelLearning() async {
    if (!_initialized) return;
    try {
      await _cancelRange(_learningIdStart, _learningIdEnd);
    } catch (_) {}
  }

  Future<void> showBreakReminder({required String body, String? route}) async {
    if (!_initialized) return;
    await _plugin.show(
      id: _breakId,
      title: 'Time for a brain break 🌿',
      body: body,
      notificationDetails: _reminderDetails,
      payload: route,
    );
  }

  Future<void> showEssayReady() async {
    if (!_initialized) return;
    await _plugin.show(
      id: _essayReadyId,
      title: 'Your essay is ready to check ✍️',
      body: 'We read your handwriting. Check the text, then get your score.',
      notificationDetails: _reminderDetails,
      payload: '/essay',
    );
  }

  /// iOS fallback for screen time (ARCHITECTURE.md 10.2): daily break
  /// reminders at the user's chosen times.
  Future<void> scheduleDailyBreaks(List<ClockTime> times) async {
    if (!_initialized) return;
    await _cancelRange(_dailyBreakIdStart, _dailyBreakIdStart + 10);
    var id = _dailyBreakIdStart;
    final now = tz.TZDateTime.now(tz.local);
    for (final time in times.take(10)) {
      var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
      if (!when.isAfter(now)) when = when.add(const Duration(days: 1));
      await _plugin.zonedSchedule(
        id: id++,
        scheduledDate: when,
        notificationDetails: _reminderDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: 'Time for a brain break 🌿',
        body: 'Look up from your screen for a minute. Your mind will thank you.',
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelDailyBreaks() async {
    if (!_initialized) return;
    await _cancelRange(_dailyBreakIdStart, _dailyBreakIdStart + 10);
  }
}

/// Plans and schedules the next 2 days of notifications. Called on every app
/// open, after settings change, and daily from WorkManager.
class NotificationScheduler {
  NotificationScheduler(this._ref);

  final Ref _ref;

  Future<void> reschedule() async {
    final service = NotificationService.instance;
    try {
      final settings = _ref.read(settingsProvider);
      if (!settings.onboardingDone || !settings.notificationsEnabled) {
        await service.cancelLearning();
      } else {
        final plan = await _ref.read(dailyPlanRepositoryProvider).planNotifications(DateTime.now());
        await service.scheduleLearning(plan);
      }
      if (!kIsWeb && Platform.isIOS) {
        if (settings.screenTimeEnabled) {
          await service.scheduleDailyBreaks(settings.breakReminderTimes);
        } else {
          await service.cancelDailyBreaks();
        }
      }
    } catch (e, st) {
      AppLogger.error('Reschedule failed', e, st);
    }
  }
}

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) => NotificationScheduler(ref));
