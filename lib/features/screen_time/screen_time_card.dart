import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../platform/screen_time_channel.dart';
import '../common/widgets.dart';

class ScreenTimeSnapshot {
  const ScreenTimeSnapshot({required this.hasPermission, required this.totalMinutes, required this.topApps});
  final bool hasPermission;
  final int totalMinutes;
  final List<AppUsage> topApps;
}

final screenTimeSnapshotProvider = FutureProvider.autoDispose<ScreenTimeSnapshot?>((ref) async {
  final channel = ref.watch(screenTimeChannelProvider);
  if (!channel.isSupported) return null;
  if (!await channel.hasPermission()) {
    return const ScreenTimeSnapshot(hasPermission: false, totalMinutes: 0, topApps: []);
  }
  final usage = await channel.getTodayUsage();
  return ScreenTimeSnapshot(
    hasPermission: true,
    totalMinutes: usage.fold(0, (sum, a) => sum + a.minutes),
    topApps: usage.take(5).toList(),
  );
});

String formatMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}m';
  return '${h}h ${m}m';
}

/// Today's screen time and top 5 apps (Android only; hidden on iOS).
class ScreenTimeCard extends ConsumerWidget {
  const ScreenTimeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(screenTimeSnapshotProvider).value;
    if (snapshot == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'Screen time today',
          trailing: IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(screenTimeSnapshotProvider),
          ),
        ),
        if (!snapshot.hasPermission)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Allow "Usage access" to see your screen time and get brain break reminders.'),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: () => ref.read(screenTimeChannelProvider).openPermissionSettings(),
                  child: const Text('Open settings'),
                ),
              ],
            ),
          )
        else
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatMinutes(snapshot.totalMinutes), style: theme.textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.md),
                if (snapshot.topApps.isEmpty)
                  Text('No app use recorded yet today.', style: theme.textTheme.bodyMedium)
                else
                  for (final app in snapshot.topApps)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(app.appName, overflow: TextOverflow.ellipsis)),
                              Text(formatMinutes(app.minutes), style: theme.textTheme.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: snapshot.totalMinutes == 0 ? 0 : app.minutes / snapshot.totalMinutes,
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
      ],
    );
  }
}
