import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../data/repositories/essay_repository.dart';
import '../../domain/models/essay.dart';
import '../common/widgets.dart';

final _essayProvider = StreamProvider.family<Essay?, String>(
  (ref, id) => ref.watch(essayRepositoryProvider).watch(id),
);

/// One essay through its states: waiting, reading, check text, scoring,
/// result (ARCHITECTURE.md 9.2, 9.3).
class EssayDetailScreen extends ConsumerWidget {
  const EssayDetailScreen({super.key, required this.essayId});

  final String essayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final essay = ref.watch(_essayProvider(essayId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Essay'),
        actions: [
          if (essay.value != null && !essay.value!.status.isBusy)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete this essay?'),
                    content: const Text('It will be removed from this phone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  await ref.read(essayRepositoryProvider).delete(essayId);
                  if (context.mounted) Navigator.of(context).maybePop();
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: essay.when(
          data: (e) => e == null
              ? const EmptyState(icon: Icons.search_off, title: 'Essay not found')
              : switch (e.status) {
                  EssayStatus.queued => _Waiting(essay: e),
                  EssayStatus.transcribing => const _Busy(
                      title: 'Reading your handwriting…',
                      message: 'This can take up to a minute.',
                    ),
                  EssayStatus.transcribed => _CheckText(essay: e),
                  EssayStatus.scoring => const _Busy(
                      title: 'Scoring your essay…',
                      message: 'Our strict examiner is reading every word.',
                    ),
                  EssayStatus.done when e.result != null => EssayResultView(essay: e),
                  _ => _Failed(essay: e),
                },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const ErrorView(message: 'Could not load this essay.'),
        ),
      ),
    );
  }
}

class _Busy extends StatelessWidget {
  const _Busy({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _Waiting extends ConsumerWidget {
  const _Waiting({required this.essay});
  final Essay essay;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (essay.localImagePath != null && File(essay.localImagePath!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Image.file(File(essay.localImagePath!), height: 260, fit: BoxFit.cover),
            ),
          const SizedBox(height: AppSpacing.lg),
          EmptyState(
            icon: Icons.cloud_upload_outlined,
            title: 'Saved on your phone',
            message: essay.errorMessage ?? 'Waiting for internet. It will be sent automatically when you are online.',
            action: OutlinedButton(
              onPressed: () async {
                final result = await ref.read(essayRepositoryProvider).submit(essay.id);
                final error = result.errorOrNull;
                if (error != null && context.mounted) showError(context, error);
              },
              child: const Text('Send now'),
            ),
          ),
        ],
      );
}

class _Failed extends ConsumerWidget {
  const _Failed({required this.essay});
  final Essay essay;

  @override
  Widget build(BuildContext context, WidgetRef ref) => EmptyState(
        icon: Icons.error_outline,
        title: 'That did not work',
        message: essay.errorMessage ?? 'Something went wrong. Please try again.',
        action: FilledButton(
          onPressed: () async {
            final repo = ref.read(essayRepositoryProvider);
            final result = essay.extractedText != null
                ? await repo.confirm(essay.id, essay.extractedText!)
                : await repo.submit(essay.id);
            final error = result.errorOrNull;
            if (error != null && context.mounted) showError(context, error);
          },
          child: const Text('Try again'),
        ),
      );
}

/// Shows the transcription so the user can fix reading mistakes before
/// scoring. Spelling mistakes they really made should be left as written.
class _CheckText extends ConsumerStatefulWidget {
  const _CheckText({required this.essay});
  final Essay essay;

  @override
  ConsumerState<_CheckText> createState() => _CheckTextState();
}

class _CheckTextState extends ConsumerState<_CheckText> {
  late final TextEditingController _controller = TextEditingController(text: widget.essay.extractedText ?? '');
  bool _editing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _score() async {
    final result = await ref.read(essayRepositoryProvider).confirm(widget.essay.id, _controller.text);
    final error = result.errorOrNull;
    if (error != null && mounted) showError(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text('Check the text', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This is what we read from your photo. If a word was read wrongly, tap Edit and fix it. '
                'Keep your own spelling mistakes as they are, so the score is fair.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              if (widget.essay.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(widget.essay.errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (_editing)
                TextField(
                  controller: _controller,
                  maxLines: null,
                  minLines: 10,
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(hintText: 'Your essay'),
                )
              else
                AppCard(child: Text(_controller.text, style: theme.textTheme.bodyLarge)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _editing = !_editing),
                  child: Text(_editing ? 'Done editing' : 'Edit'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: FilledButton(onPressed: _score, child: const Text('Score my essay'))),
            ],
          ),
        ),
      ],
    );
  }
}

class EssayResultView extends StatelessWidget {
  const EssayResultView({super.key, required this.essay});
  final Essay essay;

  static const _labels = {
    'ideas': 'Ideas and content',
    'structure': 'Structure',
    'grammar': 'Grammar and punctuation',
    'spelling_vocab': 'Spelling and vocabulary',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = essay.result!;
    final scores = {
      'ideas': r.breakdown.ideas,
      'structure': r.breakdown.structure,
      'grammar': r.breakdown.grammar,
      'spelling_vocab': r.breakdown.spellingVocab,
    };
    final dark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(essay.prompt, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${r.scoreTotal}', style: theme.textTheme.displaySmall?.copyWith(fontSize: 64, height: 1)),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4),
              child: Text('/ 20', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ),
          ],
        ),
        const SectionTitle('Breakdown'),
        for (final key in EssayResult.categories) ...[
          Row(
            children: [
              Expanded(child: Text(_labels[key]!, style: theme.textTheme.bodyLarge)),
              Text('${scores[key]}/5', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: scores[key]! / 5, minHeight: 8),
          ),
          if ((r.comments[key] ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(r.comments[key]!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
          const SizedBox(height: AppSpacing.md),
        ],
        if (r.biggestHabit.isNotEmpty) ...[
          const SectionTitle('Biggest habit to fix'),
          AppCard(
            color: theme.colorScheme.surfaceContainer,
            child: Text(r.biggestHabit, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
        if (r.mistakes.isNotEmpty) ...[
          SectionTitle('Mistakes (${r.mistakes.length})'),
          for (final m in r.mistakes)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.original,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: dark ? AppColors.errorDark : AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      m.correction,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: dark ? AppColors.successDark : AppColors.success,
                      ),
                    ),
                    if (m.reason.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(m.reason, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ],
                ),
              ),
            ),
        ],
        if (r.correctedVersion.isNotEmpty)
          Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text('Corrected version', style: theme.textTheme.titleMedium),
              children: [Text(r.correctedVersion, style: theme.textTheme.bodyLarge)],
            ),
          ),
        if (r.nextExercise.isNotEmpty) ...[
          const SectionTitle('Next exercise'),
          Text(r.nextExercise, style: theme.textTheme.bodyLarge),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
