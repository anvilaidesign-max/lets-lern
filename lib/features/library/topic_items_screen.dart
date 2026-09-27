import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../data/repositories/content_repository.dart';
import '../../domain/models/content_item.dart';
import '../../domain/models/topic.dart';
import '../common/widgets.dart';
import 'library_screen.dart';

/// Items of one topic, filtered by type, loaded page by page.
class TopicItemsScreen extends ConsumerStatefulWidget {
  const TopicItemsScreen({super.key, required this.topicCode});

  final String topicCode;

  @override
  ConsumerState<TopicItemsScreen> createState() => _TopicItemsScreenState();
}

class _TopicItemsScreenState extends ConsumerState<TopicItemsScreen> {
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
    final topic = Topic.byCode(widget.topicCode);
    return Scaffold(
      appBar: AppBar(title: Text(topic?.name ?? widget.topicCode)),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              children: [
                _Filter(label: 'All', selected: _group == null, onTap: () => _setGroup(null)),
                for (final g in ContentGroup.values)
                  _Filter(label: g.label, selected: _group == g, onTap: () => _setGroup(g)),
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
      ),
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
