import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/tokens.dart';
import '../../data/repositories/chapter_repository.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/topic.dart';
import '../common/widgets.dart';
import 'chapter_markup.dart';

final chapterProvider = FutureProvider.family<Chapter?, String>(
  (ref, id) => ref.read(chapterRepositoryProvider).chapter(id),
);

final chapterProgressProvider = StreamProvider.family<ChapterProgress?, String>(
  (ref, id) => ref.watch(chapterRepositoryProvider).watchProgress(id),
);

/// Reads one chapter like a book page. Marked as read when you reach the end
/// or start the quiz.
class ChapterReaderScreen extends ConsumerStatefulWidget {
  const ChapterReaderScreen({super.key, required this.chapterId});

  final String chapterId;

  @override
  ConsumerState<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends ConsumerState<ChapterReaderScreen> {
  final _scroll = ScrollController();
  double _scale = 1.0;
  bool _marked = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_marked || !_scroll.hasClients) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 240) _markRead();
  }

  Future<void> _markRead() async {
    final chapter = ref.read(chapterProvider(widget.chapterId)).value;
    if (chapter == null || _marked) return;
    _marked = true;
    await ref.read(chapterRepositoryProvider).markRead(chapter);
  }

  Future<void> _next(Chapter chapter) async {
    final next = await ref.read(chapterRepositoryProvider).nextChapter(chapter);
    if (!mounted) return;
    if (next == null) {
      showMessage(context, 'You finished this book. Well done!');
      context.pop();
    } else {
      context.pushReplacement('/read/${next.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(chapterProvider(widget.chapterId));
    final progress = ref.watch(chapterProgressProvider(widget.chapterId)).value;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(chapterAsync.value == null ? 'Read' : Topic.nameOf(chapterAsync.value!.topicCode)),
        actions: [
          IconButton(
            tooltip: 'Smaller text',
            onPressed: _scale <= 0.85 ? null : () => setState(() => _scale -= 0.1),
            icon: const Icon(Icons.text_decrease),
          ),
          IconButton(
            tooltip: 'Larger text',
            onPressed: _scale >= 1.45 ? null : () => setState(() => _scale += 0.1),
            icon: const Icon(Icons.text_increase),
          ),
        ],
      ),
      body: chapterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const ErrorView(message: 'Could not open this chapter.'),
        data: (chapter) {
          if (chapter == null) {
            return const EmptyState(icon: Icons.menu_book_outlined, title: 'Chapter not found');
          }
          final accent = AppColors.forTopicOn(theme.brightness, chapter.topicCode);
          final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
          return SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TypeLabel(text: 'Chapter ${chapter.position}', color: accent),
                const SizedBox(height: AppSpacing.sm),
                Text(chapter.title, style: theme.textTheme.headlineMedium?.copyWith(fontSize: 28 * _scale)),
                const SizedBox(height: AppSpacing.sm),
                Text(chapter.summary, style: muted?.copyWith(fontSize: 16 * _scale)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${chapter.readingMinutes} min read · ${const ['', 'Basics', 'Intermediate', 'Advanced'][chapter.difficulty]}'
                  '${progress?.isRead == true ? ' · Read ✓' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const Divider(height: AppSpacing.xl),
                if (const {'medicine', 'law', 'finance', 'business'}.contains(chapter.topicCode))
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      'For learning only. This is not medical, legal or financial advice.',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
                    ),
                  ),
                ChapterMarkup(body: chapter.body, scale: _scale, accent: accent),
                if (chapter.keyPoints.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    color: theme.colorScheme.surfaceContainer,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Key points', style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        for (final p in chapter.keyPoints)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check, size: 18, color: accent),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(child: Text(p, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16 * _scale))),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                if (chapter.sources.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text('Sources and further reading', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                  for (final s in chapter.sources)
                    InkWell(
                      onTap: () => launchUrl(Uri.parse(s.url), mode: LaunchMode.inAppBrowserView).catchError((_) => false),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          s.name,
                          style: theme.textTheme.bodySmall?.copyWith(color: accent, decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: AppSpacing.xl),
                if (chapter.quiz.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await _markRead();
                        if (context.mounted) context.push('/read/${chapter.id}/quiz');
                      },
                      icon: const Icon(Icons.quiz_outlined),
                      label: Text(progress?.quizTaken == true
                          ? 'Retake the quiz (best ${progress!.bestScore}/${progress.totalQuestions})'
                          : 'Take the chapter quiz (${chapter.quiz.length} questions)'),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await _markRead();
                      await _next(chapter);
                    },
                    child: const Text('Next chapter'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
