import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/logger.dart';
import '../../data/remote/supabase_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/daily_plan_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/sync/sync_service.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/topic.dart';
import '../../platform/background_tasks.dart';
import '../../platform/notification_service.dart';
import '../../platform/screen_time_channel.dart';
import '../common/widgets.dart';
import '../home/home_providers.dart';
import '../screen_time/screen_time_card.dart';

/// Settings (ARCHITECTURE.md 11.2 #10).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _set(WidgetRef ref, String key, String value, {bool topicsChanged = false}) async {
    await ref.read(settingsProvider.notifier).set(key, value);
    if (topicsChanged) {
      await ref.read(dailyPlanRepositoryProvider).refreshToday();
      ref.invalidate(todayTopicsProvider);
    }
    await ref.read(notificationSchedulerProvider).reschedule();
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref, String key, ClockTime current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked != null) await _set(ref, key, ClockTime(picked.hour, picked.minute).toString());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final user = ref.watch(authUserProvider).value;
    final isAndroid = !kIsWeb && Platform.isAndroid;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          const SectionTitle('Appearance'),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
            ],
            selected: {s.themeMode},
            onSelectionChanged: (v) => ref.read(settingsProvider.notifier).set(SettingKeys.themeMode, AppSettings.themeModeValue(v.first)),
          ),
          const SectionTitle('Notifications'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Learning notifications'),
            value: s.notificationsEnabled,
            onChanged: (v) async {
              if (v) await NotificationService.instance.requestPermission();
              await _set(ref, SettingKeys.notificationsEnabled, '$v');
            },
          ),
          Text('Every', style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 2, label: Text('2 hours')),
              ButtonSegment(value: 3, label: Text('3 hours')),
              ButtonSegment(value: 4, label: Text('4 hours')),
            ],
            selected: {s.notifIntervalHours},
            onSelectionChanged: (v) => _set(ref, SettingKeys.notifIntervalHours, '${v.first}'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Quiet from'),
            trailing: Text(s.quietStart.toString(), style: theme.textTheme.titleMedium),
            onTap: () => _pickTime(context, ref, SettingKeys.quietStart, s.quietStart),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Quiet until'),
            trailing: Text(s.quietEnd.toString(), style: theme.textTheme.titleMedium),
            onTap: () => _pickTime(context, ref, SettingKeys.quietEnd, s.quietEnd),
          ),
          const SectionTitle('Topics'),
          Text('Topics per day', style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<TopicsPerDay>(
            segments: const [
              ButtonSegment(value: TopicsPerDay.one, label: Text('1')),
              ButtonSegment(value: TopicsPerDay.two, label: Text('2')),
              ButtonSegment(value: TopicsPerDay.random, label: Text('Random')),
            ],
            selected: {s.topicsPerDay},
            onSelectionChanged: (v) => _set(ref, SettingKeys.topicsPerDay, v.first.storageValue, topicsChanged: true),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final t in Topic.all)
                TopicChip(
                  code: t.code,
                  selected: s.effectiveTopics.contains(t.code),
                  onTap: () {
                    final current = {...s.effectiveTopics};
                    if (current.contains(t.code)) {
                      if (current.length == 1) {
                        showMessage(context, 'Keep at least one topic.');
                        return;
                      }
                      current.remove(t.code);
                    } else {
                      current.add(t.code);
                    }
                    _set(ref, SettingKeys.enabledTopics, [for (final c in Topic.allCodes) if (current.contains(c)) c].join(','), topicsChanged: true);
                  },
                ),
            ],
          ),
          const SectionTitle('Brain breaks'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(isAndroid ? 'Screen time reminders' : 'Daily break reminders'),
            subtitle: Text(isAndroid
                ? 'Remind me to take a break after ${formatMinutes(s.screenTimeLimitMinutes)} on my phone'
                : 'At ${s.breakReminderTimes.join(', ')}'),
            value: s.screenTimeEnabled,
            onChanged: (v) async {
              final channel = ref.read(screenTimeChannelProvider);
              if (v && isAndroid && !await channel.hasPermission()) {
                if (!context.mounted) return;
                final go = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Allow usage access'),
                    content: const Text(
                      'To know how long you have been on your phone, Android needs "Usage access". '
                      'Find Daily Mind in the list and turn it on. Your usage never leaves your phone.',
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not now')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Open settings')),
                    ],
                  ),
                );
                if (go == true) await channel.openPermissionSettings();
              }
              await _set(ref, SettingKeys.screenTimeEnabled, '$v');
              await BackgroundTasks.setScreenTimeCheck(enabled: v);
            },
          ),
          if (isAndroid) ...[
            Text('Limit: ${formatMinutes(s.screenTimeLimitMinutes)}', style: theme.textTheme.bodyMedium),
            Slider(
              value: s.screenTimeLimitMinutes.toDouble(),
              min: 15,
              max: 120,
              divisions: 7,
              label: formatMinutes(s.screenTimeLimitMinutes),
              onChanged: (v) => ref.read(settingsProvider.notifier).set(SettingKeys.screenTimeLimitMinutes, '${v.round()}'),
            ),
          ],
          const SectionTitle('Essay'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Weekends only'),
            subtitle: const Text('Essay challenge opens on Saturday and Sunday'),
            value: s.essayWeekendOnly,
            onChanged: (v) => ref.read(settingsProvider.notifier).set(SettingKeys.essayWeekendOnly, '$v'),
          ),
          const SectionTitle('Content and sync'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Include unverified content'),
            subtitle: const Text('New cards that have not been checked yet'),
            value: s.includeUnverified,
            onChanged: (v) async {
              await ref.read(settingsProvider.notifier).setMany({
                SettingKeys.includeUnverified: '$v',
                // Forces a full download so the change applies to every card.
                SettingKeys.offlinePackRefreshedAt: '',
              });
              ref.read(syncServiceProvider).run();
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sync now'),
            subtitle: Text(s.lastSyncAt == null
                ? 'Not synced yet'
                : 'Last sync ${DateFormat.MMMd().add_jm().format(s.lastSyncAt!.toLocal())}'),
            trailing: const Icon(Icons.sync),
            onTap: () async {
              showMessage(context, 'Syncing…');
              final outcome = await ref.read(syncServiceProvider).run();
              if (!context.mounted) return;
              showMessage(context, switch (outcome) {
                SyncOutcome.done => 'All synced.',
                SyncOutcome.skippedOffline => 'You are offline. We will sync when you are back online.',
                SyncOutcome.skippedSignedOut => 'Sign in to sync your progress.',
                SyncOutcome.skippedBusy => 'Sync is already running.',
                SyncOutcome.failed => 'Sync failed. We will try again later.',
              });
              ref.invalidate(homeItemProvider);
            },
          ),
          const SectionTitle('Account'),
          if (user != null) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_circle_outlined),
              title: Text(user.userMetadata?['full_name'] as String? ?? 'Signed in'),
              subtitle: Text(user.email ?? ''),
            ),
            OutlinedButton(
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
                await ref.read(settingsProvider.notifier).set(SettingKeys.guestMode, 'false');
              },
              child: const Text('Sign out'),
            ),
          ] else ...[
            Text(
              'You are using Daily Mind offline. Sign in to back up your progress and use AI features.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(onPressed: () => context.push('/login'), child: const Text('Sign in')),
          ],
          const SectionTitle('About'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Daily Mind'),
            subtitle: const Text('Version 1.0.0 · Learn something instead of scrolling.'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Daily Mind',
              applicationVersion: '1.0.0',
              children: [
                const Text('Recent app log (for bug reports):'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  width: 300,
                  child: SingleChildScrollView(
                    child: Text(AppLogger.recent.reversed.take(50).join('\n'), style: const TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
