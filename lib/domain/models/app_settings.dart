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

  // Profile (stored on the phone so it shows offline).
  static const profileName = 'profile_name';
  static const profileAvatar = 'profile_avatar';
  static const profileField = 'profile_field';
  static const learningLevel = 'learning_level';
  static const profileSyncedName = 'profile_synced_name';
  static const chaptersSyncedAt = 'chapters_synced_at';

  static String newsRefreshedAt(String category) => 'news_refreshed_$category';

  static String gameBest(String gameId) => 'game_best_$gameId';
}

/// `topics_per_day`: 1, 2, 3, or random (1 or 2 each day).
enum TopicsPerDay {
  one('1'),
  two('2'),
  three('3'),
  random('random');

  const TopicsPerDay(this.storageValue);
  final String storageValue;

  static TopicsPerDay parse(String? value) => switch (value) {
        '1' => TopicsPerDay.one,
        '2' => TopicsPerDay.two,
        '3' => TopicsPerDay.three,
        _ => TopicsPerDay.random,
      };
}

/// Which difficulty of cards to show. Items have difficulty 1 (basic),
/// 2 (intermediate) or 3 (advanced).
enum LearningLevel {
  basics('basics', 'Basics', 'Foundations first'),
  mixed('mixed', 'Mixed', 'Basics and advanced together'),
  advanced('advanced', 'Advanced', 'Harder cards, fewer basics');

  const LearningLevel(this.storageValue, this.label, this.description);
  final String storageValue;
  final String label;
  final String description;

  static LearningLevel parse(String? value) =>
      LearningLevel.values.firstWhere((l) => l.storageValue == value, orElse: () => LearningLevel.mixed);

  bool allows(int difficulty) => switch (this) {
        LearningLevel.basics => difficulty <= 2,
        LearningLevel.mixed => true,
        LearningLevel.advanced => difficulty >= 2,
      };
}

/// A profile picture: one of the bundled characters or the user's own photo.
class ProfileAvatar {
  const ProfileAvatar._(this.kind, this.path);

  final String kind;
  final String path;

  static const bundledCount = 24;

  static String assetPath(int index) => 'assets/avatars/avatar_${index.toString().padLeft(2, '0')}.png';

  static ProfileAvatar asset(int index) => ProfileAvatar._('asset', assetPath(index));

  static ProfileAvatar file(String path) => ProfileAvatar._('file', path);

  bool get isAsset => kind == 'asset';

  String get storageValue => '$kind:$path';

  static ProfileAvatar? parse(String? value) {
    if (value == null) return null;
    final i = value.indexOf(':');
    if (i <= 0) return null;
    final kind = value.substring(0, i);
    final path = value.substring(i + 1);
    if (path.isEmpty || (kind != 'asset' && kind != 'file')) return null;
    return ProfileAvatar._(kind, path);
  }
}

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.light,
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
    this.profileName = '',
    this.profileField = '',
    this.profileAvatar,
    this.level = LearningLevel.mixed,
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
  final String profileName;
  final String profileField;
  final ProfileAvatar? profileAvatar;
  final LearningLevel level;

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
      // Light is the default; dark and system are opt-in.
      themeMode: switch (map[SettingKeys.themeMode]) {
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.light,
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
      profileName: (map[SettingKeys.profileName] ?? '').trim(),
      profileField: (map[SettingKeys.profileField] ?? '').trim(),
      profileAvatar: ProfileAvatar.parse(map[SettingKeys.profileAvatar]),
      level: LearningLevel.parse(map[SettingKeys.learningLevel]),
    );
  }

  static String themeModeValue(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}
