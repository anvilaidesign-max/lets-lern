import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../data/repositories/content_repository.dart';
import '../../domain/models/content_item.dart';
import '../../domain/models/topic.dart';
import '../common/widgets.dart';

final topicCountsProvider = StreamProvider<Map<String, int>>(
  (ref) => ref.watch(contentRepositoryProvider).watchCountsByTopic(),
);

final savedItemsProvider = StreamProvider<List<ContentItem>>(
  (ref) => ref.watch(contentRepositoryProvider).watchSaved(),
);

/// Browse all topics, even outside today's (ARCHITECTURE.md 11.2 #6).
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          bottom: const TabBar(tabs: [Tab(text: 'Topics'), Tab(text: 'Saved')]),
        ),
        body: const TabBarView(children: [_TopicsGrid(), _SavedList()]),
      ),
    );
  }
}

class _TopicsGrid extends ConsumerWidget {
  const _TopicsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(topicCountsProvider).value ?? const {};
    final theme = Theme.of(context);
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.15,
      ),
      itemCount: Topic.all.length,
      itemBuilder: (context, i) {
        final topic = Topic.all[i];
        final color = AppColors.forTopicOn(theme.brightness, topic.code);
        return AppCard(
          onTap: () => context.push('/library/topic/${topic.code}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(topic.icon, color: color, size: 28),
              const Spacer(),
              Text(topic.name, style: theme.textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(
                '${counts[topic.code] ?? 0} cards',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SavedList extends ConsumerWidget {
  const _SavedList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedItemsProvider);
    return saved.when(
      data: (items) => items.isEmpty
          ? const EmptyState(
              icon: Icons.star_outline_rounded,
              title: 'No saved cards yet',
              message: 'Tap the star on any card to keep it here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) => ItemTile(item: items[i]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const ErrorView(message: 'Could not load saved cards.'),
    );
  }
}

class ItemTile extends StatelessWidget {
  const ItemTile({super.key, required this.item});
  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.forTopicOn(theme.brightness, item.topicCode);
    return AppCard(
      onTap: () => context.push('/card/${item.id}'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TypeLabel(text: '${Topic.shortNameOf(item.topicCode)} · ${item.type.label}', color: color),
                const SizedBox(height: 4),
                Text(item.preview, style: theme.textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
