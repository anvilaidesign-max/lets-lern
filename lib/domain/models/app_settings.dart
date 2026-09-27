import 'package:flutter/material.dart' show ThemeMode;

import '../../core/utils/date_utils.dart';
import 'topic.dart';

/// Local key/value settings (ARCHITECTURE.md 6).
class SettingKeys {
  SettingKeys._();

  static const themeMode = 'theme_mode';
  static const notifIntervalHours = 'notif_interval_hours';
  static const quietStart = 'quiet_start';
  static const quietEnd = 'quiet_end';
  static const topicsPerDay = 'topics_per_day';
  static const enabledTopics = 'enabled_topics';
  static const screenTimeLimitMinutes = 'screen_time_limit_minutes';
  static const screenTimeEnabled = 'screen_time_enabled';
  static const essayWeekendOnly = 'essay_weekend_only';
  static const includeUnverified = 'include_unverified';
  static const notificationsEnabled = 'notifications_enabled';
  static const breakReminderTimes = 'break_reminder_times';
  static const lastSyncAt = 'last_sync_at';
  static const onboardingDone = 'onboarding_done';
  static const guestMode = 'guest_mode';

  // Internal bookkeeping (not user facing).
  static const deviceId = 'device_id';
  static const seedVersion = 'seed_version';
  static const localOwnerId = 'local_owner_id';
  static const progressRestoredFor = 'progress_restored_for';
  static const offlinePackRefreshedAt = 'offline_pack_refreshed_at';
  static const screenTimeBaselineDay = 'screen_time_baseline_day';
  static const screenTimeBaselineMinutes = 'screen_time_baseline_minutes';
  static const screenTimeLastReminderAt = 'screen_time_last_reminder_at';
  static const essayPromptOffset = 'essay_prompt_offset';
  static const completedToday = 'completed_today';
}

/// `topics_per_day`: 1, 2, or random (1 or 2 each day).
enum TopicsPerDay {
  one('1'),
  two('2'),
  random('random');

  const TopicsPerDay(this.storageValue);
  final String storageValue;

  static TopicsPerDay parse(String? value) => switch (value) {
        '1' => TopicsPerDay.one,
        '2' => TopicsPerDay.two,
        _ => TopicsPerDay.random,
      };
}

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.notifIntervalHours = 3,
    this.quietStart = const ClockTime(21, 30),
    this.quietEnd = const ClockTime(7, 0),
    this.topicsPerDay = TopicsPerDay.random,
    this.enabledTopics = const [],
    this.screenTimeLimitMinutes = 45,
    this.screenTimeEnabled = false,
    this.essayWeekendOnly = true,
    this.includeUnverified = false,
    this.notificationsEnabled = true,
    this.breakReminderTimes = const [ClockTime(11, 0), ClockTime(15, 0), ClockTime(19, 0)],
    this.lastSyncAt,
    this.onboardingDone = false,
    this.guestMode = false,
  });

  final ThemeMode themeMode;
  final int notifIntervalHours;
  final ClockTime quietStart;
  final ClockTime quietEnd;
  final TopicsPerDay topicsPerDay;

  /// Empty means "all topics" (the default).
  final List<String> enabledTopics;
  final int screenTimeLimitMinutes;
  final bool screenTimeEnabled;
  final bool essayWeekendOnly;
  final bool includeUnverified;
  final bool notificationsEnabled;
  final List<ClockTime> breakReminderTimes;
  final DateTime? lastSyncAt;
  final bool onboardingDone;
  final bool guestMode;

  List<String> get effectiveTopics {
    final valid = enabledTopics.where(Topic.allCodes.contains).toList();
    return valid.isEmpty ? Topic.allCodes : valid;
  }

  static AppSettings fromMap(Map<String, String> map) {
    int intOr(String key, int fallback, {int? min, int? max}) {
      final v = int.tryParse(map[key] ?? '');
      if (v == null) return fallback;
      if (min != null && v < min) return min;
      if (max != null && v > max) return max;
      return v;
    }

    bool boolOr(String key, bool fallback) => switch (map[key]) {
          'true' => true,
          'false' => false,
          _ => fallback,
        };

    const defaults = AppSettings();
    final topics = (map[SettingKeys.enabledTopics] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final breakTimes = (map[SettingKeys.breakReminderTimes] ?? '')
        .split(',')
        .map(ClockTime.tryParse)
        .whereType<ClockTime>()
        .toList();

    return AppSettings(
      themeMode: switch (map[SettingKeys.themeMode]) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      notifIntervalHours: intOr(SettingKeys.notifIntervalHours, 3, min: 2, max: 4),
      quietStart: ClockTime.tryParse(map[SettingKeys.quietStart]) ?? defaults.quietStart,
      quietEnd: ClockTime.tryParse(map[SettingKeys.quietEnd]) ?? defaults.quietEnd,
      topicsPerDay: TopicsPerDay.parse(map[SettingKeys.topicsPerDay]),
      enabledTopics: topics,
      screenTimeLimitMinutes: intOr(SettingKeys.screenTimeLimitMinutes, 45, min: 15, max: 240),
      screenTimeEnabled: boolOr(SettingKeys.screenTimeEnabled, false),
      essayWeekendOnly: boolOr(SettingKeys.essayWeekendOnly, true),
      includeUnverified: boolOr(SettingKeys.includeUnverified, false),
      notificationsEnabled: boolOr(SettingKeys.notificationsEnabled, true),
      breakReminderTimes: breakTimes.isEmpty ? defaults.breakReminderTimes : breakTimes,
      lastSyncAt: DateTime.tryParse(map[SettingKeys.lastSyncAt] ?? ''),
      onboardingDone: boolOr(SettingKeys.onboardingDone, false),
      guestMode: boolOr(SettingKeys.guestMode, false),
    );
  }

  static String themeModeValue(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}
