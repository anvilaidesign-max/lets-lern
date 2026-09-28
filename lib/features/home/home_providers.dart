import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_utils.dart';
import '../../data/repositories/chapter_repository.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/daily_plan_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/content_item.dart';
import '../../domain/services/streak_service.dart';

/// Today's `yyyy-MM-dd`. Refreshed when the app comes back to the foreground,
/// so everything keyed on the day rolls over at midnight.
class TodayNotifier extends Notifier<String> {
  @override
  String build() => DateKeys.dayKey(DateTime.now());

  void refresh() {
    final now = DateKeys.dayKey(DateTime.now());
    if (now != state) state = now;
  }
}

final todayProvider = NotifierProvider<TodayNotifier, String>(TodayNotifier.new);

final todayTopicsProvider = FutureProvider<List<String>>((ref) async {
  ref.watch(todayProvider);
  ref.watch(settingsProvider.select((s) => (s.effectiveTopics.join(','), s.topicsPerDay)));
  return ref.read(dailyPlanRepositoryProvider).topicsFor(DateTime.now());
});

/// The big "next item" card on Home. Stays the same until the user moves on.
class HomeItemNotifier extends AsyncNotifier<ContentItem?> {
  @override
  Future<ContentItem?> build() async {
    await ref.watch(todayTopicsProvider.future);
    return ref.read(dailyPlanRepositoryProvider).nextItem();
  }

  Future<void> advance() async {
    final current = state.value;
    state = AsyncData(await ref.read(dailyPlanRepositoryProvider).nextItem(
          exclude: {if (current != null) current.id},
        ));
  }
}

final homeItemProvider = AsyncNotifierProvider<HomeItemNotifier, ContentItem?>(HomeItemNotifier.new);

final itemsByDayProvider = StreamProvider<Map<String, int>>(
  (ref) => ref.watch(progressRepositoryProvider).watchItemsByDay(),
);

final streakProvider = Provider<int>((ref) {
  ref.watch(todayProvider);
  final days = ref.watch(itemsByDayProvider).value ?? const {};
  return StreakCalculator.current(days, DateTime.now());
});

final todayCompletedProvider = Provider<int>((ref) {
  final today = ref.watch(todayProvider);
  return ref.watch(itemsByDayProvider).value?[today] ?? 0;
});

final itemProvider = FutureProvider.family<ContentItem?, String>(
  (ref, id) => ref.read(contentRepositoryProvider).item(id),
);

final chapterCountsProvider = StreamProvider<({int read, int total})>(
  (ref) => ref.watch(chapterRepositoryProvider).watchCounts(),
);

/// The chapter to continue with on Home. Recomputed when reading progress changes.
final continueReadingProvider = FutureProvider<ChapterEntry?>((ref) async {
  ref.watch(chapterCountsProvider);
  final topics = await ref.watch(todayTopicsProvider.future);
  return ref.read(chapterRepositoryProvider).continueReading(topics);
});
