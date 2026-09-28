import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/topic.dart';
import '../../platform/background_tasks.dart';
import '../../platform/notification_service.dart';
import '../../platform/screen_time_channel.dart';
import '../common/widgets.dart';

/// 3 pages (+ screen time on Android): what the app does, topics,
/// notification permission (ARCHITECTURE.md 11.2 #1). Every permission is
/// optional; the app works without them.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _page = 0;
  final Set<String> _topics = {...Topic.allCodes};
  bool _notificationsOn = false;
  bool _screenTimeOn = false;
  final _name = TextEditingController();
  final _field = TextEditingController();
  LearningLevel _level = LearningLevel.mixed;

  bool get _showScreenTime => !kIsWeb && Platform.isAndroid;
  int get _pageCount => _showScreenTime ? 5 : 4;

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    _field.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pageCount - 1) {
      _pages.nextPage(duration: AppDurations.slow, curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final all = _topics.length == Topic.allCodes.length;
    await ref.read(settingsProvider.notifier).setMany({
      SettingKeys.enabledTopics: all ? '' : [for (final c in Topic.allCodes) if (_topics.contains(c)) c].join(','),
      SettingKeys.notificationsEnabled: '$_notificationsOn',
      SettingKeys.screenTimeEnabled: '$_screenTimeOn',
      SettingKeys.profileName: _name.text.trim(),
      SettingKeys.profileField: _field.text.trim(),
      SettingKeys.learningLevel: _level.storageValue,
      SettingKeys.onboardingDone: 'true',
    });
    if (_screenTimeOn) await BackgroundTasks.setScreenTimeCheck(enabled: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  _Page(
                    emoji: '',
                    logo: true,
                    title: 'Welcome to We Learn',
                    body: 'Short facts, words and true or false challenges through the day, '
                        'instead of endless scrolling. Maths, English, French, science, politics, '
                        'economics, finance and world affairs.',
                  ),
                  _Page(
                    emoji: '👋',
                    title: 'About you',
                    body: 'So your cards and AI tutor match what you study and how deep you want to go.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(hintText: 'Your name'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _field,
                          decoration: const InputDecoration(hintText: 'What you study or do (e.g. Electronics Engineering)'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SegmentedButton<LearningLevel>(
                          segments: [for (final l in LearningLevel.values) ButtonSegment(value: l, label: Text(l.label))],
                          selected: {_level},
                          onSelectionChanged: (v) => setState(() => _level = v.first),
                        ),
                      ],
                    ),
                  ),
                  _Page(
                    emoji: '🎯',
                    title: 'Pick your topics',
                    body: 'Each day brings one or two of them. You can change this any time.',
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final t in Topic.all)
                          TopicChip(
                            code: t.code,
                            selected: _topics.contains(t.code),
                            onTap: () => setState(() {
                              if (_topics.contains(t.code)) {
                                if (_topics.length > 1) _topics.remove(t.code);
                              } else {
                                _topics.add(t.code);
                              }
                            }),
                          ),
                      ],
                    ),
                  ),
                  _Page(
                    emoji: '🔔',
                    title: 'Learning moments',
                    body: 'We send a short card every few hours while you are awake, never during quiet hours. '
                        'Tap one to learn or answer. Everything is planned on your phone and works offline.',
                    child: _notificationsOn
                        ? Text('Notifications are on ✓', style: theme.textTheme.titleMedium)
                        : FilledButton(
                            onPressed: () async {
                              final granted = await NotificationService.instance.requestPermission();
                              setState(() => _notificationsOn = granted);
                              if (!granted && context.mounted) {
                                showMessage(context, 'No problem. You can turn them on later in Settings.');
                              }
                            },
                            child: const Text('Allow notifications'),
                          ),
                  ),
                  if (_showScreenTime)
                    _Page(
                      emoji: '🌿',
                      title: 'Brain breaks',
                      body: 'Optional: We Learn can remind you to take a break when you have been on your phone '
                          'too long. Android needs "Usage access" for this. Your usage data never leaves your phone.',
                      child: _screenTimeOn
                          ? Text('Brain breaks are on ✓', style: theme.textTheme.titleMedium)
                          : OutlinedButton(
                              onPressed: () async {
                                await ref.read(screenTimeChannelProvider).openPermissionSettings();
                                setState(() => _screenTimeOn = true);
                              },
                              child: const Text('Open usage access settings'),
                            ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _pageCount; i++)
                        AnimatedContainer(
                          duration: AppDurations.fast,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _page ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _page ? theme.colorScheme.onSurface : theme.colorScheme.outline,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      child: Text(_page == _pageCount - 1 ? 'Get started' : 'Continue'),
                    ),
                  ),
                  if (_page >= 3)
                    TextButton(onPressed: _next, child: const Text('Skip for now')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.emoji, required this.title, required this.body, this.child, this.logo = false});

  final String emoji;
  final String title;
  final String body;
  final Widget? child;
  final bool logo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),
          if (logo)
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset('assets/icon/logo.png', width: 112, height: 112, semanticLabel: 'We Learn logo'),
            )
          else
            Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          Text(
            body,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          if (child != null) ...[const SizedBox(height: AppSpacing.xl), child!],
        ],
      ),
    );
  }
}
