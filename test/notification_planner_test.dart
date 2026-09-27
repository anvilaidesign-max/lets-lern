import 'package:daily_mind/core/utils/date_utils.dart';
import 'package:daily_mind/domain/models/content_item.dart';
import 'package:daily_mind/domain/services/notification_planner.dart';
import 'package:flutter_test/flutter_test.dart';

bool inQuietHours(DateTime t, ClockTime start, ClockTime end) {
  final m = t.hour * 60 + t.minute;
  final s = start.minutesOfDay;
  final e = end.minutesOfDay;
  return s > e ? (m > s || m < e) : (m > s && m < e);
}

void main() {
  const quietStart = ClockTime(21, 30);
  const quietEnd = ClockTime(7, 0);

  group('NotificationPlanner', () {
    test('never schedules inside quiet hours', () {
      final slots = NotificationPlanner.plan(
        now: DateTime(2026, 4, 1, 6, 0),
        intervalHours: 2,
        quietStart: quietStart,
        quietEnd: quietEnd,
        seed: 'u1',
      );
      expect(slots, isNotEmpty);
      for (final s in slots) {
        expect(inQuietHours(s.time, quietStart, quietEnd), isFalse, reason: '${s.time}');
      }
    });

    test('never plans more than 2 days ahead, and nothing in the past', () {
      final now = DateTime(2026, 4, 1, 13, 17);
      final slots = NotificationPlanner.plan(now: now, intervalHours: 3, quietStart: quietStart, quietEnd: quietEnd, seed: 'u1');
      for (final s in slots) {
        expect(s.time.isAfter(now), isTrue);
        expect(s.time.isAfter(now.add(const Duration(days: 2))), isFalse);
      }
    });

    test('follows the interval, within the +/- 15 minute jitter', () {
      final slots = NotificationPlanner.plan(
        now: DateTime(2026, 4, 1, 0, 0),
        intervalHours: 3,
        quietStart: quietStart,
        quietEnd: quietEnd,
        seed: 'u1',
      );
      final firstDay = slots.where((s) => s.day == DateTime(2026, 4, 1)).toList();
      // 07:00, 10:00, 13:00, 16:00, 19:00 (22:00 is in quiet hours).
      expect(firstDay.length, 5);
      final bases = [7, 10, 13, 16, 19];
      for (var i = 0; i < firstDay.length; i++) {
        final base = DateTime(2026, 4, 1, bases[i]);
        expect(firstDay[i].time.difference(base).inMinutes.abs(), lessThanOrEqualTo(15));
      }
      for (var i = 1; i < firstDay.length; i++) {
        final gap = firstDay[i].time.difference(firstDay[i - 1].time).inMinutes;
        expect(gap, inInclusiveRange(150, 210));
      }
    });

    test('gives the same times when re-planned, so fired slots never repeat', () {
      final a = NotificationPlanner.plan(now: DateTime(2026, 4, 1, 8), intervalHours: 2, quietStart: quietStart, quietEnd: quietEnd, seed: 'u1');
      final b = NotificationPlanner.plan(now: DateTime(2026, 4, 1, 8, 30), intervalHours: 2, quietStart: quietStart, quietEnd: quietEnd, seed: 'u1');
      final bTimes = b.map((s) => s.time).toSet();
      for (final s in a.where((s) => s.time.isAfter(DateTime(2026, 4, 1, 8, 30)))) {
        expect(bTimes.contains(s.time), isTrue);
      }
    });

    test('handles quiet hours that end after midnight', () {
      const lateStart = ClockTime(1, 0);
      const lateEnd = ClockTime(9, 0);
      final slots = NotificationPlanner.plan(now: DateTime(2026, 4, 1, 12), intervalHours: 4, quietStart: lateStart, quietEnd: lateEnd, seed: 'x');
      expect(slots, isNotEmpty);
      for (final s in slots) {
        expect(inQuietHours(s.time, lateStart, lateEnd), isFalse, reason: '${s.time}');
      }
    });
  });

  group('notificationTextFor', () {
    test('uses the wording for each content type', () {
      const challenge = ContentItem(id: '1', topicCode: 'math', type: ContentType.challenge, title: 't', body: 'b', statement: '7 × 7 = 45', isTrue: false);
      const fact = ContentItem(id: '2', topicCode: 'science', type: ContentType.fact, title: 'Light is fast', body: 'b');
      const vocab = ContentItem(id: '3', topicCode: 'english', type: ContentType.vocab, title: 't', body: 'b', term: 'meticulous');
      const french = ContentItem(id: '4', topicCode: 'french', type: ContentType.phrase, title: 't', body: 'b', term: 'Bonjour');

      expect(notificationTextFor(challenge).title, 'True or false? 🧠');
      expect(notificationTextFor(challenge).body, '7 × 7 = 45');
      expect(notificationTextFor(fact).title, 'Did you know? (Science)');
      expect(notificationTextFor(fact).body, 'Light is fast');
      expect(notificationTextFor(vocab).title, 'Word of the moment (English)');
      expect(notificationTextFor(vocab).body, 'meticulous');
      expect(notificationTextFor(french).title, 'En français 🇫🇷');
      expect(notificationTextFor(french).body, 'Bonjour');
    });
  });
}
