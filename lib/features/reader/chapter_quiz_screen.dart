import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../data/repositories/chapter_repository.dart';
import '../../domain/models/chapter.dart';
import '../common/widgets.dart';
import 'chapter_reader_screen.dart';

/// The quiz at the end of a chapter: multiple choice, one question at a
/// time, with an explanation after each answer.
class ChapterQuizScreen extends ConsumerStatefulWidget {
  const ChapterQuizScreen({super.key, required this.chapterId});

  final String chapterId;

  @override
  ConsumerState<ChapterQuizScreen> createState() => _ChapterQuizScreenState();
}

class _ChapterQuizScreenState extends ConsumerState<ChapterQuizScreen> {
  int _index = 0;
  int? _selected;
  int _score = 0;
  bool _saved = false;

  void _choose(QuizQuestion q, int option) {
    if (_selected != null) return;
    setState(() {
      _selected = option;
      if (option == q.answerIndex) _score++;
    });
  }

  Future<void> _nextQuestion(Chapter chapter) async {
    final last = _index >= chapter.quiz.length - 1;
    setState(() {
      _index++;
      _selected = null;
    });
    if (last && !_saved) {
      _saved = true;
      await ref.read(chapterRepositoryProvider).recordQuiz(chapter, score: _score, total: chapter.quiz.length);
    }
  }

  void _retake() => setState(() {
        _index = 0;
        _selected = null;
        _score = 0;
        _saved = false;
      });

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(chapterProvider(widget.chapterId));
    return Scaffold(
      appBar: AppBar(title: const Text('Chapter quiz')),
      body: SafeArea(
        child: chapterAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const ErrorView(message: 'Could not load the quiz.'),
          data: (chapter) {
            if (chapter == null || chapter.quiz.isEmpty) {
              return const EmptyState(icon: Icons.quiz_outlined, title: 'No quiz for this chapter');
            }
            if (_index >= chapter.quiz.length) return _result(context, chapter);
            return _question(context, chapter, chapter.quiz[_index]);
          },
        ),
      ),
    );
  }

  Widget _question(BuildContext context, Chapter chapter, QuizQuestion q) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final good = dark ? AppColors.successDark : AppColors.success;
    final bad = dark ? AppColors.errorDark : AppColors.error;
    final answered = _selected != null;

    return Column(
      children: [
        LinearProgressIndicator(value: (_index + (answered ? 1 : 0)) / chapter.quiz.length),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                '${chapter.title} · Question ${_index + 1} of ${chapter.quiz.length}',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(q.question, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.lg),
              for (var i = 0; i < q.options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: OutlinedButton(
                    onPressed: answered ? null : () => _choose(q, i),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
                      side: BorderSide(
                        width: 2,
                        color: !answered
                            ? theme.colorScheme.outline
                            : i == q.answerIndex
                                ? good
                                : (i == _selected ? bad : theme.colorScheme.outline),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text('${String.fromCharCode(65 + i)}.  ', style: theme.textTheme.titleMedium),
                        Expanded(child: Text(q.options[i], style: theme.textTheme.bodyLarge)),
                        if (answered && i == q.answerIndex) Icon(Icons.check_circle, color: good),
                        if (answered && i == _selected && i != q.answerIndex) Icon(Icons.cancel, color: bad),
                      ],
                    ),
                  ),
                ),
              if (answered) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _selected == q.answerIndex ? 'Correct!' : 'Not quite.',
                  style: theme.textTheme.titleMedium?.copyWith(color: _selected == q.answerIndex ? good : bad),
                ),
                if (q.explanation.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(q.explanation, style: theme.textTheme.bodyLarge),
                ],
              ],
            ],
          ),
        ),
        if (answered)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _nextQuestion(chapter),
                child: Text(_index == chapter.quiz.length - 1 ? 'See my score' : 'Next question'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _result(BuildContext context, Chapter chapter) {
    final theme = Theme.of(context);
    final total = chapter.quiz.length;
    final passed = _score / total >= 0.6;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Text('$_score / $total', style: theme.textTheme.displaySmall?.copyWith(fontSize: 56)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              passed ? 'Chapter passed ✓' : 'Read it once more, then try again.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (passed)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final next = await ref.read(chapterRepositoryProvider).nextChapter(chapter);
                    if (!context.mounted) return;
                    if (next == null) {
                      showMessage(context, 'You finished this book. Well done!');
                      context.pop();
                    } else {
                      context.pushReplacement('/read/${next.id}');
                    }
                  },
                  child: const Text('Next chapter'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: () => context.pop(), child: const Text('Back to the chapter')),
              ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _retake, child: const Text('Retake quiz'))),
          ],
        ),
      ),
    );
  }
}
