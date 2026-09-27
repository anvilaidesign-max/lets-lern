import '../../core/utils/date_utils.dart';

/// Streaks (ARCHITECTURE.md 8.4). A day counts when at least 3 items were
/// completed. The streak is the run of counted days ending today or
/// yesterday, so it does not reset in the morning before the user starts.
///
/// Days are local calendar keys and stepped with calendar arithmetic, so
/// daylight saving changes and time zone travel do not break the count.
class StreakCalculator {
  StreakCalculator._();

  static const minItemsPerDay = 3;

  static bool _counted(Map<String, int> itemsByDay, DateTime day) =>
      (itemsByDay[DateKeys.dayKey(day)] ?? 0) >= minItemsPerDay;

  static int current(Map<String, int> itemsByDay, DateTime now) {
    var day = DateKeys.startOfDay(now);
    if (!_counted(itemsByDay, day)) {
      day = DateKeys.addDays(day, -1);
      if (!_counted(itemsByDay, day)) return 0;
    }
    var streak = 0;
    while (_counted(itemsByDay, day)) {
      streak++;
      day = DateKeys.addDays(day, -1);
    }
    return streak;
  }

  static int longest(Map<String, int> itemsByDay) {
    final days = itemsByDay.entries
        .where((e) => e.value >= minItemsPerDay)
        .map((e) => DateKeys.parseDayKey(e.key))
        .toList()
      ..sort();
    var best = 0;
    var run = 0;
    DateTime? previous;
    for (final day in days) {
      final isNext = previous != null &&
          DateKeys.dayKey(DateKeys.addDays(previous, 1)) == DateKeys.dayKey(day);
      run = isNext ? run + 1 : 1;
      if (run > best) best = run;
      previous = day;
    }
    return best;
  }

  /// True when today already counts towards the streak.
  static bool todayCounts(Map<String, int> itemsByDay, DateTime now) =>
      _counted(itemsByDay, now);
}
