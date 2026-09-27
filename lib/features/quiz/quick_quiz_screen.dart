import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../data/repositories/daily_plan_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/models/content_item.dart';
import '../card/card_screen.dart';
import '../common/widgets.dart';

/// 5 challenges in a row from today's topics, score at the end.
class QuickQuizScreen extends ConsumerStatefulWidget {
  const QuickQuizScreen({super.key});

  static const length = 5;

  @override
  ConsumerState<QuickQuizScreen> createState() => _QuickQuizScreenState();
}

class _QuickQuizScreenState extends ConsumerState<QuickQuizScreen> {
  List<ContentItem>? _items;
  int _index = 0;
  bool? _answer;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final items = await ref.read(dailyPlanRepositoryProvider).quizItems(QuickQuizScreen.length);
    if (!mounted) return;
    setState(() {
      _items = items;
      _index = 0;
      _answer = null;
      _score = 0;
    });
    if (items.isNotEmpty) await ref.read(progressRepositoryProvider).recordView(items.first);
  }

  Future<void> _onAnswer(bool value) async {
    final item = _items![_index];
    final correct = value == item.isTrue;
    setState(() {
      _answer = value;
      if (correct) _score++;
    });
    await ref.read(progressRepositoryProvider).recordAnswer(item, correct: correct);
  }

  Future<void> _next() async {
    setState(() {
      _index++;
      _answer = null;
    });
    final items = _items!;
    if (_index < items.length) await ref.read(progressRepositoryProvider).recordView(items[_index]);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final theme = Theme.of(context);
    final done = items != null && _index >= items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick quiz'),
        bottom: items == null || items.isEmpty || done
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(value: (_index + (_answer == null ? 0 : 1)) / items.length),
              ),
      ),
      body: SafeArea(
        child: items == null
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
                ? const EmptyState(
                    icon: Icons.quiz_outlined,
                    title: 'No challenges yet',
                    message: 'There are no true or false questions for your topics yet.',
                  )
                : done
                    ? _Result(score: _score, total: items.length, onAgain: _start)
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Question ${_index + 1} of ${items.length}',
                                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  ChallengeView(
                                    key: ValueKey(items[_index].id),
                                    item: items[_index],
                                    answer: _answer,
                                    onAnswer: _onAnswer,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_answer != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                              child: SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _next,
                                  child: Text(_index == items.length - 1 ? 'See my score' : 'Next question'),
                                ),
                              ),
                            ),
                        ],
                      ),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.score, required this.total, required this.onAgain});

  final int score;
  final int total;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = total == 0 ? 0 : score / total;
    final message = ratio == 1
        ? 'Perfect score! 🎉'
        : ratio >= 0.6
            ? 'Nice work! 👏'
            : 'Every mistake is a lesson. Try again!';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$score / $total', style: theme.textTheme.displaySmall?.copyWith(fontSize: 56)),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: onAgain, child: const Text('Play again'))),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Done')),
            ),
          ],
        ),
      ),
    );
  }
}
