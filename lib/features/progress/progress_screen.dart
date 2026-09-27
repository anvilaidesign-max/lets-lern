import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/models/progress.dart';
import '../../domain/models/topic.dart';
import '../../domain/services/streak_service.dart';
import '../essay/essay_screen.dart';
import '../home/home_providers.dart';
import '../screen_time/screen_time_card.dart';
import '../common/widgets.dart';

final topicAccuracyProvider = StreamProvider<List<TopicAccuracy>>(
  (ref) => ref.watch(progressRepositoryProvider).watchTopicAccuracy(),
);

final itemsLearnedProvider = StreamProvider<int>(
  (ref) => ref.watch(progressRepositoryProvider).watchItemsLearned(),
);

/// Streak, totals, accuracy per topic, essay trend, screen time
/// (ARCHITECTURE.md 11.2 #9).
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final days = ref.watch(itemsByDayProvider).value ?? const {};
    final learned = ref.watch(itemsLearnedProvider).value ?? 0;
    final accuracy = ref.watch(topicAccuracyProvider).value ?? const [];
    final essays = ref.watch(essaysProvider).value ?? const [];
    final scores = [for (final e in essays.reversed) if (e.scoreTotal != null) e.scoreTotal!];

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Row(
            children: [
              Expanded(child: _Stat(value: '🔥 $streak', label: 'Day streak')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _Stat(value: '${StreakCalculator.longest(days)}', label: 'Best streak')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _Stat(value: '$learned', label: 'Cards learned')),
            ],
          ),
          const SectionTitle('Accuracy by topic'),
          if (accuracy.every((a) => a.answered == 0))
            const AppCard(
              child: Text('Answer some true or false challenges to see your accuracy here.'),
            )
          else
            _AccuracyChart(data: accuracy),
          if (scores.length >= 2) ...[
            const SectionTitle('Essay scores'),
            EssayScoreChart(scores: scores),
          ],
          const ScreenTimeCard(),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(child: Text(value, style: theme.textTheme.headlineSmall)),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _AccuracyChart extends StatelessWidget {
  const _AccuracyChart({required this.data});
  final List<TopicAccuracy> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final byTopic = {for (final a in data) a.topicCode: a};
    final topics = Topic.all.where((t) => (byTopic[t.code]?.answered ?? 0) > 0).toList();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: 100,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (_) => FlLine(color: theme.colorScheme.outline, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                '${Topic.shortNameOf(topics[group.x].code)}\n${rod.toY.round()}%',
                TextStyle(color: theme.colorScheme.surface, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text('${value.toInt()}%', style: theme.textTheme.bodySmall),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Icon(
                    topics[value.toInt()].icon,
                    size: 18,
                    color: AppColors.forTopicOn(theme.brightness, topics[value.toInt()].code),
                  ),
                ),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < topics.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: (byTopic[topics[i].code]!.accuracy ?? 0) * 100,
                    color: AppColors.forTopicOn(theme.brightness, topics[i].code),
                    width: 18,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
