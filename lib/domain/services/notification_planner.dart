import '../../core/utils/date_utils.dart';
import '../models/content_item.dart';
import '../models/topic.dart';
import 'seeded_random.dart';

/// One planned learning notification time.
class PlannedSlot implements Comparable<PlannedSlot> {
  const PlannedSlot({required this.time, required this.day});

  final DateTime time;

  /// The day whose awake window this slot belongs to. It decides which day's
  /// topics are used (a window can run past midnight).
  final DateTime day;

  @override
  int compareTo(PlannedSlot other) => time.compareTo(other.time);

  @override
  String toString() => 'PlannedSlot($time, day ${DateKeys.dayKey(day)})';
}

/// Notification planning (ARCHITECTURE.md 8.3).
///
/// Slots run from `quietEnd` to `quietStart` every `intervalHours`, each moved
/// by up to +/- [jitterMinutes] so they feel natural, and never inside quiet
/// hours. Only the next [horizon] (2 days) is planned.
///
/// The jitter is derived from [seed] and the slot, so re-planning on every app
/// open gives the same times: a notification that already fired is never
/// pushed into the future and shown twice.
class NotificationPlanner {
  NotificationPlanner._();

  static const horizon = Duration(days: 2);
  static const jitterMinutes = 15;

  static List<PlannedSlot> plan({
    required DateTime now,
    required int intervalHours,
    required ClockTime quietStart,
    required ClockTime quietEnd,
    required String seed,
    Duration horizon = NotificationPlanner.horizon,
  }) {
    final interval = Duration(hours: intervalHours.clamp(1, 24));
    final end = now.add(horizon);
    final slots = <PlannedSlot>[];
    final today = DateKeys.startOfDay(now);

    // Start one day back: yesterday's window may still be open after midnight.
    for (var offset = -1; offset <= horizon.inDays + 1; offset++) {
      final day = DateKeys.addDays(today, offset);
      final windowStart = quietEnd.onDay(day);
      var windowEnd = quietStart.onDay(day);
      if (!windowEnd.isAfter(windowStart)) {
        windowEnd = quietStart.onDay(DateKeys.addDays(day, 1));
      }

      for (var base = windowStart; !base.isAfter(windowEnd); base = base.add(interval)) {
        final rng = SeededRandom(stableHash('$seed|${base.toIso8601String()}'));
        final jitter = rng.nextInt(jitterMinutes * 2 + 1) - jitterMinutes;
        var time = base.add(Duration(minutes: jitter));
        if (time.isBefore(windowStart)) time = windowStart;
        if (time.isAfter(windowEnd)) time = windowEnd;
        if (time.isAfter(now) && !time.isAfter(end)) {
          slots.add(PlannedSlot(time: time, day: day));
        }
      }
    }
    slots.sort();
    return slots;
  }
}

class NotificationText {
  const NotificationText(this.title, this.body);
  final String title;
  final String body;
}

/// Notification wording by content type (ARCHITECTURE.md 8.3).
NotificationText notificationTextFor(ContentItem item) {
  if (item.type == ContentType.challenge) {
    return NotificationText('True or false? 🧠', item.statement ?? item.title);
  }
  if (item.topicCode == 'french') {
    return NotificationText('En français 🇫🇷', item.term ?? item.title);
  }
  return switch (item.type) {
    ContentType.vocab || ContentType.phrase =>
      NotificationText('Word of the moment (${Topic.shortNameOf(item.topicCode)})', item.term ?? item.title),
    _ => NotificationText('Did you know? (${Topic.nameOf(item.topicCode)})', item.title),
  };
}
