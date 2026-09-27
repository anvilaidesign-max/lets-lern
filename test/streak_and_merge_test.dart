import 'package:daily_mind/domain/models/progress.dart';
import 'package:daily_mind/domain/services/streak_service.dart';
import 'package:daily_mind/domain/services/sync_merge.dart';
import 'package:daily_mind/features/screen_time/screen_time_service.dart';
import 'package:daily_mind/core/utils/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StreakCalculator', () {
    test('counts consecutive days ending today', () {
      final days = {'2026-03-08': 3, '2026-03-09': 5, '2026-03-10': 4};
      expect(StreakCalculator.current(days, DateTime(2026, 3, 10, 20)), 3);
    });

    test('keeps the streak alive until today is done (ends yesterday)', () {
      final days = {'2026-03-08': 3, '2026-03-09': 5, '2026-03-10': 1};
      expect(StreakCalculator.current(days, DateTime(2026, 3, 10, 8)), 2);
    });

    test('resets after a missed day', () {
      final days = {'2026-03-06': 3, '2026-03-07': 3, '2026-03-09': 3};
      expect(StreakCalculator.current(days, DateTime(2026, 3, 10)), 1);
      expect(StreakCalculator.current(days, DateTime(2026, 3, 11)), 0);
    });

    test('days with fewer than 3 items do not count', () {
      final days = {'2026-03-09': 2, '2026-03-10': 3};
      expect(StreakCalculator.current(days, DateTime(2026, 3, 10)), 1);
    });

    test('works across month, year and daylight saving boundaries', () {
      final days = {'2025-12-30': 3, '2025-12-31': 3, '2026-01-01': 3};
      expect(StreakCalculator.current(days, DateTime(2026, 1, 1, 23, 59)), 3);
      // Last Sunday of March: clocks change in many time zones.
      final dst = {'2026-03-28': 4, '2026-03-29': 4, '2026-03-30': 4};
      expect(StreakCalculator.current(dst, DateTime(2026, 3, 30, 0, 30)), 3);
    });

    test('longest streak', () {
      final days = {'2026-01-01': 3, '2026-01-02': 3, '2026-01-03': 3, '2026-01-05': 3, '2026-01-06': 3};
      expect(StreakCalculator.longest(days), 3);
      expect(StreakCalculator.longest(const {}), 0);
    });

    test('day keys are local calendar days', () {
      expect(DateKeys.dayKey(DateTime(2026, 7, 4, 23, 59)), '2026-07-04');
      expect(DateKeys.dayKey(DateKeys.addDays(DateTime(2026, 2, 28), 1)), '2026-03-01');
    });
  });

  group('SyncMerge (ARCHITECTURE.md 7.3)', () {
    final t1 = DateTime.utc(2026, 1, 1);
    final t2 = DateTime.utc(2026, 1, 2);

    ProgressCounters counters({int seen = 0, int ok = 0, int wrong = 0, DateTime? lastSeen, bool saved = false, DateTime? savedAt}) =>
        ProgressCounters(itemId: 'x', seenCount: seen, answeredCorrect: ok, answeredWrong: wrong, lastSeenAt: lastSeen, saved: saved, savedUpdatedAt: savedAt);

    test('counters take the higher value of each', () {
      final merged = SyncMerge.progress(counters(seen: 5, ok: 1, wrong: 4), counters(seen: 3, ok: 2, wrong: 1));
      expect(merged.seenCount, 5);
      expect(merged.answeredCorrect, 2);
      expect(merged.answeredWrong, 4);
    });

    test('last seen takes the latest time', () {
      expect(SyncMerge.progress(counters(lastSeen: t1), counters(lastSeen: t2)).lastSeenAt, t2);
      expect(SyncMerge.progress(counters(lastSeen: t2), counters()).lastSeenAt, t2);
    });

    test('saved flag is last write wins', () {
      expect(SyncMerge.progress(counters(saved: true, savedAt: t1), counters(saved: false, savedAt: t2)).saved, isFalse);
      expect(SyncMerge.progress(counters(saved: true, savedAt: t2), counters(saved: false, savedAt: t1)).saved, isTrue);
      // Ties keep the local value.
      expect(SyncMerge.progress(counters(saved: true, savedAt: t1), counters(saved: false, savedAt: t1)).saved, isTrue);
    });

    test('merging is idempotent', () {
      final a = counters(seen: 2, ok: 1, lastSeen: t1, saved: true, savedAt: t2);
      final b = counters(seen: 4, wrong: 2, lastSeen: t2, saved: false, savedAt: t1);
      final once = SyncMerge.progress(a, b);
      expect(SyncMerge.progress(once, b), once);
    });

    test('items completed per day take the higher count', () {
      expect(SyncMerge.itemsCompleted(3, 7), 7);
      expect(SyncMerge.itemsCompleted(9, 2), 9);
    });
  });

  group('BreakReminderRule', () {
    test('fires when screen time grew by the limit since the last reminder', () {
      expect(BreakReminderRule.isDue(totalToday: 100, baseline: 50, continuous: 0, minutesSinceLastReminder: 10, limit: 45), isTrue);
      expect(BreakReminderRule.isDue(totalToday: 80, baseline: 50, continuous: 0, minutesSinceLastReminder: 10, limit: 45), isFalse);
    });

    test('fires on a long continuous session, but not twice in a row', () {
      expect(BreakReminderRule.isDue(totalToday: 50, baseline: 40, continuous: 50, minutesSinceLastReminder: null, limit: 45), isTrue);
      expect(BreakReminderRule.isDue(totalToday: 50, baseline: 40, continuous: 50, minutesSinceLastReminder: 20, limit: 45), isFalse);
    });

    test('knows quiet hours, including across midnight', () {
      const start = ClockTime(21, 30);
      const end = ClockTime(7, 0);
      expect(BreakReminderRule.isQuietTime(DateTime(2026, 1, 1, 23), start, end), isTrue);
      expect(BreakReminderRule.isQuietTime(DateTime(2026, 1, 1, 6, 59), start, end), isTrue);
      expect(BreakReminderRule.isQuietTime(DateTime(2026, 1, 1, 12), start, end), isFalse);
    });
  });
}
