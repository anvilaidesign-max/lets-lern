import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../data/repositories/chapter_repository.dart';
import '../../data/repositories/content_repository.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/content_item.dart';
import '../../domain/models/topic.dart';
import '../common/widgets.dart';
import 'library_screen.dart';

final topicChaptersProvider = StreamProvider.family<List<ChapterEntry>, String>(
  (ref, topic) => ref.watch(chapterRepositoryProvider).watchTopic(topic),
);

/// A topic: its book (chapters with quizzes) and its cards.
class TopicItemsScreen extends StatelessWidget {
  const TopicItemsScreen({super.key, required this.topicCode});

  final String topicCode;

  @override
  Widget build(BuildContext context) {
    final topic = Topic.byCode(topicCode);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(topic?.name ?? topicCode),
          bottom: const TabBar(tabs: [Tab(text: 'Read'), Tab(text: 'Cards')]),
        ),
        body: TabBarView(children: [_BookTab(topicCode: topicCode), _CardsTab(topicCode: topicCode)]),
      ),
    );
  }
}

class _BookTab extends ConsumerWidget {
  const _BookTab({required this.topicCode});
  final String topicCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(topicChaptersProvider(topicCode));
    final theme = Theme.of(context);
    final accent = AppColors.forTopicOn(theme.brightness, topicCode);

    return chapters.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const ErrorView(message: 'Could not load the chapters.'),
      data: (entries) {
        if (entries.isEmpty) {
          return const EmptyState(
            icon: Icons.menu_book_outlined,
            title: 'No chapters yet',
            message: 'New chapters arrive when you are online.',
          );
        }
        final read = entries.where((e) => e.progress?.isRead == true).length;
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: entries.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$read of ${entries.length} chapters read', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: read / entries.length, minHeight: 6, color: accent),
                    ),
                  ],
                ),
              );
            }
            final e = entries[i - 1];
            return _ChapterTile(entry: e, accent: accent);
          },
        );
      },
    );
  }
}

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({required this.entry, required this.accent});
  final ChapterEntry entry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = entry.chapter;
    final p = entry.progress;
    final status = p == null || !p.isRead
        ? '${c.readingMinutes} min read · ${c.quiz.length} quiz questions'
        : p.quizTaken
            ? 'Read ✓ · Quiz best ${p.bestScore}/${p.totalQuestions}${p.passed ? ' ✓' : ''}'
            : 'Read ✓ · Quiz not taken yet';
    return AppCard(
      onTap: () => context.push('/read/${c.id}'),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p?.isRead == true ? accent : accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: p?.passed == true
                ? Icon(Icons.check, color: theme.colorScheme.surface)
                : Text(
                    '${c.position}',
                    style: theme.textTheme.titleMedium?.copyWith(color: p?.isRead == true ? theme.colorScheme.surface : accent),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(c.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(status, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

/// Cards of the topic, filtered by type, loaded page by page.
class _CardsTab extends ConsumerStatefulWidget {
  const _CardsTab({required this.topicCode});
  final String topicCode;

  @override
  ConsumerState<_CardsTab> createState() => _CardsTabState();
}

class _CardsTabState extends ConsumerState<_CardsTab> {
  static const _pageSize = 30;

  final _items = <ContentItem>[];
  final _scroll = ScrollController();
  ContentGroup? _group;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) _loadMore();
    });
    _loadMore();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    final page = await ref.read(contentRepositoryProvider).page(
          widget.topicCode,
          group: _group,
          limit: _pageSize,
          offset: _items.length,
        );
    if (!mounted) return;
    setState(() {
      _items.addAll(page);
      _hasMore = page.length == _pageSize;
      _loading = false;
    });
  }

  void _setGroup(ContentGroup? group) {
    setState(() {
      _group = group;
      _items.clear();
      _hasMore = true;
    });
    _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            children: [
              _Filter(label: 'All', selected: _group == null, onTap: () => _setGroup(null)),
              for (final g in ContentGroup.values) _Filter(label: g.label, selected: _group == g, onTap: () => _setGroup(g)),
            ],
          ),
        ),
        Expanded(
          child: _items.isEmpty && !_loading
              ? const EmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'Nothing here yet',
                  message: 'New cards arrive when you are online.',
                )
              : ListView.separated(
                  controller: _scroll,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: _items.length + (_hasMore ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => i >= _items.length
                      ? const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : ItemTile(item: _items[i]),
                ),
        ),
      ],
    );
  }
}

class _Filter extends StatelessWidget {
  const _Filter({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
      );
}
