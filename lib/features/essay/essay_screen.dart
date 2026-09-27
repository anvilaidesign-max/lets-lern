import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/date_utils.dart';
import '../../data/repositories/essay_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/essay.dart';
import '../common/widgets.dart';

final essaysProvider = StreamProvider<List<Essay>>((ref) => ref.watch(essayRepositoryProvider).watchAll());

final essayPromptProvider = FutureProvider<String>(
  (ref) => ref.watch(essayRepositoryProvider).currentPrompt(DateTime.now()),
);

/// Weekend essay challenge (ARCHITECTURE.md 9.3, 11.2 #7).
class EssayScreen extends ConsumerStatefulWidget {
  const EssayScreen({super.key});

  @override
  ConsumerState<EssayScreen> createState() => _EssayScreenState();
}

class _EssayScreenState extends ConsumerState<EssayScreen> {
  bool _busy = false;

  Future<void> _pick(ImageSource source, String prompt) async {
    setState(() => _busy = true);
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );
      if (file == null || !mounted) return;
      final repo = ref.read(essayRepositoryProvider);
      final created = await repo.createFromPhoto(file.path, prompt);
      if (!mounted) return;
      await created.when(
        success: (id) async {
          context.push('/essay/$id');
          final submitted = await repo.submit(id);
          final error = submitted.errorOrNull;
          if (error != null && mounted) showError(context, error);
        },
        failure: (e) async => showError(context, e),
      );
    } catch (e) {
      if (mounted) showMessage(context, 'Could not open the camera or photos.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekendOnly = ref.watch(settingsProvider.select((s) => s.essayWeekendOnly));
    final now = DateTime.now();
    final open = !weekendOnly || DateKeys.isWeekend(now);
    final prompt = ref.watch(essayPromptProvider);
    final essays = ref.watch(essaysProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Essay challenge')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (!open)
            _Countdown(now: now)
          else
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('THIS WEEKEND\'S PROMPT', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(prompt.value ?? '…', style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        await ref.read(essayRepositoryProvider).anotherPrompt();
                        ref.invalidate(essayPromptProvider);
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Another prompt'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Write your essay by hand on paper, then take a clear photo in good light. '
                    'We read your handwriting, you check the text, and AI scores it out of 20.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_busy)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: prompt.hasValue ? () => _pick(ImageSource.camera, prompt.value!) : null,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Take photo'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: prompt.hasValue ? () => _pick(ImageSource.gallery, prompt.value!) : null,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Choose photo'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          _ScoreChart(essays: essays),
          SectionTitle('Your essays'),
          if (essays.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: EmptyState(
                icon: Icons.edit_note,
                title: 'No essays yet',
                message: 'Your scores will appear here.',
              ),
            )
          else
            for (final e in essays) ...[
              _EssayTile(essay: e),
              const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.now});
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final saturday = DateKeys.nextSaturday(now);
    final left = saturday.difference(now);
    final days = left.inDays;
    final hours = left.inHours % 24;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Opens Saturday', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            days > 0 ? '$days day${days == 1 ? '' : 's'} $hours h to go' : '$hours hours to go',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'The essay challenge runs on weekends. You can turn this off in Settings.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _EssayTile extends StatelessWidget {
  const _EssayTile({required this.essay});
  final Essay essay;

  String get _status => switch (essay.status) {
        EssayStatus.queued => 'Waiting for internet',
        EssayStatus.transcribing => 'Reading your handwriting…',
        EssayStatus.transcribed => 'Ready for you to check',
        EssayStatus.scoring => 'Scoring…',
        EssayStatus.done => 'Scored',
        EssayStatus.failed => 'Needs attention',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: () => context.push('/essay/${essay.id}'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(essay.prompt, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat.yMMMd().format(essay.createdAt)} · $_status',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (essay.scoreTotal != null)
            Text('${essay.scoreTotal}/20', style: theme.textTheme.titleLarge)
          else
            const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

/// Line chart of essay scores over time.
class _ScoreChart extends StatelessWidget {
  const _ScoreChart({required this.essays});
  final List<Essay> essays;

  @override
  Widget build(BuildContext context) {
    final scored = essays.where((e) => e.scoreTotal != null).toList().reversed.toList();
    if (scored.length < 2) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Score trend'),
        EssayScoreChart(scores: [for (final e in scored) e.scoreTotal!]),
      ],
    );
  }
}

class EssayScoreChart extends StatelessWidget {
  const EssayScoreChart({super.key, required this.scores});
  final List<int> scores;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;
    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 20,
          minX: 0,
          maxX: (scores.length - 1).toDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (_) => FlLine(color: theme.colorScheme.outline, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                reservedSize: 28,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(value.toInt().toString(), style: theme.textTheme.bodySmall),
                ),
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < scores.length; i++) FlSpot(i.toDouble(), scores[i].toDouble())],
              color: color,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}
