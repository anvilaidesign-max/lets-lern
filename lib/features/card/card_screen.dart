import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../data/repositories/daily_plan_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/models/content_item.dart';
import '../../domain/models/progress.dart';
import '../../domain/models/topic.dart';
import '../common/widgets.dart';
import '../home/home_providers.dart';

final _progressProvider = StreamProvider.family<ItemProgress?, String>(
  (ref, id) => ref.watch(progressRepositoryProvider).watch(id),
);

/// Single item view (ARCHITECTURE.md 11.2 #4). `itemId` may be `next`.
class CardScreen extends ConsumerStatefulWidget {
  const CardScreen({super.key, required this.itemId, this.presetAnswer});

  final String itemId;

  /// Answer chosen from a notification action button.
  final bool? presetAnswer;

  @override
  ConsumerState<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends ConsumerState<CardScreen> {
  ContentItem? _item;
  bool _loading = true;
  bool? _answer;
  bool _recorded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ContentItem? item = widget.itemId == 'next'
        ? await ref.read(dailyPlanRepositoryProvider).nextItem()
        : await ref.read(itemProvider(widget.itemId).future);
    if (!mounted) return;
    setState(() {
      _item = item;
      _loading = false;
    });
    if (item != null && !_recorded) {
      _recorded = true;
      await ref.read(progressRepositoryProvider).recordView(item);
      if (widget.presetAnswer != null && item.isChallenge) _submit(widget.presetAnswer!);
    }
  }

  Future<void> _submit(bool answer) async {
    final item = _item;
    if (item == null || _answer != null) return;
    setState(() => _answer = answer);
    await ref.read(progressRepositoryProvider).recordAnswer(item, correct: answer == item.isTrue);
  }

  Future<void> _next() async {
    final next = await ref.read(dailyPlanRepositoryProvider).nextItem(exclude: {if (_item != null) _item!.id});
    if (!mounted) return;
    if (next == null) {
      showMessage(context, 'You have seen everything for today. Great work!');
      return;
    }
    context.pushReplacement('/card/${next.id}');
  }

  Future<void> _report() async {
    final item = _item;
    if (item == null) return;
    final reason = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
              child: Text('What is wrong with this card?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
            for (final r in const ['The answer is wrong', 'A fact is out of date', 'Spelling or grammar mistake', 'It is confusing', 'Something else'])
              ListTile(title: Text(r), onTap: () => Navigator.pop(context, r)),
          ],
        ),
      ),
    );
    if (reason == null || !mounted) return;
    await ref.read(progressRepositoryProvider).report(item.id, reason);
    if (mounted) showMessage(context, 'Thanks. We will check this card.');
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    final progress = item == null ? null : ref.watch(_progressProvider(item.id)).value;
    final saved = progress?.saved ?? false;

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (item != null) ...[
            IconButton(
              tooltip: saved ? 'Remove from saved' : 'Save',
              icon: Icon(saved ? Icons.star_rounded : Icons.star_outline_rounded),
              onPressed: () => ref.read(progressRepositoryProvider).toggleSaved(item.id, saved: !saved),
            ),
            IconButton(
              tooltip: progress?.reported == true ? 'Reported' : 'Report a problem',
              icon: Icon(progress?.reported == true ? Icons.flag : Icons.outlined_flag),
              onPressed: _report,
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : item == null
                ? EmptyState(
                    icon: Icons.search_off,
                    title: 'Card not found',
                    message: 'It may have been removed. Try the next one.',
                    action: FilledButton(onPressed: _next, child: const Text('Next card')),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
                          child: _CardBody(item: item, answer: _answer, onAnswer: _submit),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                        child: SizedBox(
                          width: double.infinity,
                          child: item.isChallenge && _answer == null
                              ? TextButton(onPressed: _next, child: const Text('Skip'))
                              : FilledButton.icon(
                                  onPressed: _next,
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('Next'),
                                  iconAlignment: IconAlignment.end,
                                ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.item, required this.answer, required this.onAnswer});

  final ContentItem item;
  final bool? answer;
  final ValueChanged<bool> onAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.forTopicOn(theme.brightness, item.topicCode);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Topic.byCode(item.topicCode)?.icon, size: 18, color: color),
            const SizedBox(width: 6),
            TypeLabel(text: '${Topic.nameOf(item.topicCode)} · ${item.type.label}', color: color),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (item.isChallenge)
          ChallengeView(item: item, answer: answer, onAnswer: onAnswer)
        else if (item.type == ContentType.vocab || item.type == ContentType.phrase)
          _WordView(item: item)
        else
          _FactView(item: item),
        if (item.sourceName != null && (!item.isChallenge || answer != null)) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Source: ${item.sourceName}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

/// True/false challenge: statement, two big buttons, then the explanation.
class ChallengeView extends StatelessWidget {
  const ChallengeView({super.key, required this.item, required this.answer, required this.onAnswer});

  final ContentItem item;
  final bool? answer;
  final ValueChanged<bool> onAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final answered = answer != null;
    final correct = answered && answer == item.isTrue;
    final good = dark ? AppColors.successDark : AppColors.success;
    final bad = dark ? AppColors.errorDark : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('True or false?', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: AppSpacing.sm),
        Text(item.statement!, style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            for (final value in [true, false]) ...[
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: OutlinedButton(
                    onPressed: answered ? null : () => onAnswer(value),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        width: 2,
                        color: !answered
                            ? theme.colorScheme.outline
                            : value == item.isTrue
                                ? good
                                : (value == answer ? bad : theme.colorScheme.outline),
                      ),
                    ),
                    child: Text(value ? 'True' : 'False', style: theme.textTheme.titleLarge),
                  ),
                ),
              ),
              if (value) const SizedBox(width: AppSpacing.md),
            ],
          ],
        ),
        AnimatedSwitcher(
          duration: AppDurations.normal,
          child: !answered
              ? const SizedBox.shrink()
              : Padding(
                  key: const ValueKey('result'),
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(correct ? Icons.check_circle : Icons.cancel, color: correct ? good : bad),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            correct ? 'Correct!' : 'Not quite',
                            style: theme.textTheme.titleLarge?.copyWith(color: correct ? good : bad),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        item.isTrue! ? 'The statement is true.' : 'The statement is false.',
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (item.correctAnswer != null && item.isTrue == false) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text('Correct answer: ${item.correctAnswer}', style: theme.textTheme.bodyLarge),
                      ],
                      if (item.explanation != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(item.explanation!, style: theme.textTheme.bodyLarge),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _FactView extends StatelessWidget {
  const _FactView({required this.item});
  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.md),
        Text(item.body, style: theme.textTheme.bodyLarge?.copyWith(fontSize: AppTextSizes.card, height: 1.5)),
      ],
    );
  }
}

class _WordView extends StatelessWidget {
  const _WordView({required this.item});
  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.term ?? item.title, style: theme.textTheme.displaySmall),
        if (item.translation != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(item.translation!, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(item.body, style: theme.textTheme.bodyLarge?.copyWith(fontSize: AppTextSizes.card - 2)),
        if (item.exampleSentence != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Example', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text('“${item.exampleSentence}”', style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
