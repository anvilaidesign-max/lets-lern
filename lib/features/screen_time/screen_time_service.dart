import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_utils.dart';
import '../../data/repositories/daily_plan_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/app_settings.dart';
import '../../platform/notification_service.dart';
import '../../platform/screen_time_channel.dart';

/// Decides whether a break reminder is due (ARCHITECTURE.md 10.1).
///
/// A reminder is sent when, since the last reminder, total screen time today
/// grew by the limit, or the screen has been on continuously for the limit.
/// Never during quiet hours.
class BreakReminderRule {
  BreakReminderRule._();

  static bool isQuietTime(DateTime now, ClockTime quietStart, ClockTime quietEnd) {
    final minutes = now.hour * 60 + now.minute;
    final start = quietStart.minutesOfDay;
    final end = quietEnd.minutesOfDay;
    if (start == end) return false;
    return start > end ? (minutes >= start || minutes < end) : (minutes >= start && minutes < end);
  }

  static bool isDue({
    required int totalToday,
    required int baseline,
    required int continuous,
    required int? minutesSinceLastReminder,
    required int limit,
  }) {
    final grewByLimit = totalToday - baseline >= limit;
    final longSession = continuous >= limit && (minutesSinceLastReminder == null || minutesSinceLastReminder >= limit);
    return grewByLimit || longSession;
  }
}

class ScreenTimeService {
  ScreenTimeService(this._ref);

  final Ref _ref;

  Future<void> check() async {
    final settings = _ref.read(settingsProvider);
    final channel = _ref.read(screenTimeChannelProvider);
    if (!settings.screenTimeEnabled || !channel.isSupported || !await channel.hasPermission()) return;

    final now = DateTime.now();
    if (BreakReminderRule.isQuietTime(now, settings.quietStart, settings.quietEnd)) return;

    final notifier = _ref.read(settingsProvider.notifier);
    final today = DateKeys.dayKey(now);
    final total = await channel.getTotalScreenTimeToday();
    final continuous = await channel.getContinuousUsageMinutes();
    final baseline = notifier.raw(SettingKeys.screenTimeBaselineDay) == today
        ? int.tryParse(notifier.raw(SettingKeys.screenTimeBaselineMinutes) ?? '') ?? 0
        : 0;
    final lastReminder = DateTime.tryParse(notifier.raw(SettingKeys.screenTimeLastReminderAt) ?? '');

    final due = BreakReminderRule.isDue(
      totalToday: total,
      baseline: baseline,
      continuous: continuous,
      minutesSinceLastReminder: lastReminder == null ? null : now.difference(lastReminder).inMinutes,
      limit: settings.screenTimeLimitMinutes,
    );
    if (!due) return;

    final item = await _ref.read(dailyPlanRepositoryProvider).nextItem();
    await NotificationService.instance.showBreakReminder(
      body: item == null
          ? 'You have been on your phone for a while. Look up and rest your eyes for a minute.'
          : 'Instead of scrolling: ${item.preview}',
      route: item == null ? null : '/card/${item.id}',
    );
    await notifier.setMany({
      SettingKeys.screenTimeBaselineDay: today,
      SettingKeys.screenTimeBaselineMinutes: '$total',
      SettingKeys.screenTimeLastReminderAt: now.toIso8601String(),
    });
  }
}

final screenTimeServiceProvider = Provider<ScreenTimeService>((ref) => ScreenTimeService(ref));
