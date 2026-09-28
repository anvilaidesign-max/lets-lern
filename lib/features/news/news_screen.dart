import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/tokens.dart';
import '../../data/remote/connectivity_service.dart';
import '../../data/repositories/news_repository.dart';
import '../../domain/models/news.dart';
import '../common/widgets.dart';

final newsListProvider = StreamProvider.family<List<NewsItem>, NewsCategory>(
  (ref, category) => ref.watch(newsRepositoryProvider).watch(category),
);

String timeAgo(DateTime time, DateTime now) {
  final diff = now.difference(time.toLocal());
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays < 7) return '${diff.inDays} d ago';
  return DateFormat.MMMd().format(time.toLocal());
}

/// Real news from Zimbabwe, Africa, the world, tech, engineering, business
/// and science. Works offline with the last saved stories.
class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  NewsCategory _category = NewsCategory.zimbabwe;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshIfStale());
  }

  Future<void> _refreshIfStale() async {
    if (ref.read(newsRepositoryProvider).isStale(_category)) await _refresh(quiet: true);
  }

  Future<void> _refresh({bool quiet = false}) async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    final result = await ref.read(newsRepositoryProvider).refresh(_category);
    if (!mounted) return;
    setState(() => _refreshing = false);
    final error = result.errorOrNull;
    if (error != null && !quiet) showError(context, error);
  }

  void _select(NewsCategory category) {
    setState(() => _category = category);
    _refreshIfStale();
  }

  Future<void> _open(NewsItem item) async {
    final uri = Uri.tryParse(item.link);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView).catchError((_) => false);
    if (!opened && mounted) showMessage(context, 'Could not open the story.');
  }

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(isOnlineProvider).value ?? true;
    final items = ref.watch(newsListProvider(_category));
    final last = ref.read(newsRepositoryProvider).lastRefreshed(_category);

    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              children: [
                for (final c in NewsCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(label: Text(c.label), selected: c == _category, onSelected: (_) => _select(c)),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: items.when(
          data: (list) => ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: list.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              if (i == 0) {
                return _StatusLine(online: online, refreshing: _refreshing, last: last, empty: list.isEmpty);
              }
              return _NewsCard(item: list[i - 1], online: online, onTap: () => _open(list[i - 1]));
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => ErrorView(message: 'Could not load saved news.', onRetry: _refresh),
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.online, required this.refreshing, required this.last, required this.empty});

  final bool online;
  final bool refreshing;
  final DateTime? last;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    if (empty && !refreshing) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: EmptyState(
          icon: online ? Icons.newspaper_outlined : Icons.wifi_off,
          title: online ? 'No stories yet' : 'No saved news',
          message: online ? 'Pull down to load the latest news.' : 'Connect to the internet once and stories will be saved for offline reading.',
        ),
      );
    }
    return Row(
      children: [
        if (refreshing) ...[
          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: AppSpacing.sm),
          Text('Updating…', style: muted),
        ] else if (!online) ...[
          const OfflinePill(),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(last == null ? 'Saved stories' : 'Saved ${timeAgo(last!, DateTime.now())}', style: muted)),
        ] else
          Text(last == null ? 'Pull down to refresh' : 'Updated ${timeAgo(last!, DateTime.now())}', style: muted),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item, required this.online, required this.onTap});

  final NewsItem item;
  final bool online;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = item.imageUrl;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item.source} · ${timeAgo(item.publishedAt, DateTime.now())}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.open_in_new, size: 14, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: theme.textTheme.titleMedium),
                    if (item.summary.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.summary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
              if (online && image != null) ...[
                const SizedBox(width: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    image,
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    cacheWidth: 252,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
