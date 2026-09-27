import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/date_utils.dart';
import '../../data/remote/connectivity_service.dart';
import '../../data/remote/supabase_service.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/content_item.dart';
import '../../domain/models/topic.dart';
import '../../domain/services/streak_service.dart';
import '../common/widgets.dart';
import 'home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final streak = ref.watch(streakProvider);
    final completed = ref.watch(todayCompletedProvider);
    final topics = ref.watch(todayTopicsProvider);
    final item = ref.watch(homeItemProvider);
    final online = ref.watch(isOnlineProvider).value ?? true;
    final user = ref.watch(authUserProvider).value;
    final firstName = (user?.userMetadata?['full_name'] as String?)?.split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.read(todayProvider.notifier).refresh();
            await ref.read(homeItemProvider.notifier).advance();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstName == null ? _greeting(DateTime.now()) : '${_greeting(DateTime.now())}, $firstName',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          completed >= StreakCalculator.minItemsPerDay
                              ? 'Today counts. Keep going!'
                              : '${StreakCalculator.minItemsPerDay - completed} more to keep your streak',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  _StreakBadge(streak: streak),
                ],
              ),
              if (!online) ...[
                const SizedBox(height: AppSpacing.sm),
                const Align(alignment: Alignment.centerLeft, child: OfflinePill()),
              ],
              const SizedBox(height: AppSpacing.md),
              topics.when(
                data: (codes) => Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [for (final c in codes) TopicChip(code: c, selected: true)],
                ),
                loading: () => const SizedBox(height: 36),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.lg),
              item.when(
                data: (i) => i == null
                    ? const AppCard(
                        child: EmptyState(
                          icon: Icons.inbox_outlined,
                          title: 'Nothing to show yet',
                          message: 'Content will appear here. Check your topics in Settings.',
                        ),
                      )
                    : _NextItemCard(item: i),
                loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => ErrorView(message: 'Could not load today\'s card.', onRetry: () => ref.invalidate(homeItemProvider)),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ActionTile(
                icon: Icons.bolt_outlined,
                title: 'Quick quiz',
                subtitle: '5 true or false questions',
                onTap: () => context.push('/quiz'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ActionTile(
                icon: Icons.chat_bubble_outline,
                title: 'AI game',
                subtitle: online ? 'Learn and play with your AI tutor' : 'Needs internet',
                onTap: () => context.push('/ai-game'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _EssayTile(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$streak day streak',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text('$streak', style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _NextItemCard extends ConsumerWidget {
  const _NextItemCard({required this.item});
  final ContentItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = AppColors.forTopicOn(theme.brightness, item.topicCode);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: () async {
        await context.push('/card/${item.id}');
        ref.read(homeItemProvider.notifier).advance();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Topic.byCode(item.topicCode)?.icon, size: 18, color: color),
              const SizedBox(width: 6),
              TypeLabel(text: '${Topic.shortNameOf(item.topicCode)} · ${item.type.label}', color: color),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            item.type == ContentType.challenge ? item.preview : item.preview,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (item.type != ContentType.challenge && item.preview != item.title) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(item.title, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text(
                item.type == ContentType.challenge ? 'True or false? Tap to answer' : 'Tap to learn',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _EssayTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekendOnly = ref.watch(settingsProvider.select((s) => s.essayWeekendOnly));
    final now = DateTime.now();
    final open = !weekendOnly || DateKeys.isWeekend(now);
    final days = DateKeys.nextSaturday(now).difference(DateKeys.startOfDay(now)).inDays;
    return _ActionTile(
      icon: Icons.edit_note,
      title: 'Essay challenge',
      subtitle: open ? 'Write by hand, get a score out of 20' : 'Opens Saturday · in $days day${days == 1 ? '' : 's'}',
      onTap: () => context.push('/essay'),
    );
  }
}
