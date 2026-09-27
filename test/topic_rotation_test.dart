import 'package:daily_mind/core/utils/date_utils.dart';
import 'package:daily_mind/domain/models/app_settings.dart';
import 'package:daily_mind/domain/models/topic.dart';
import 'package:daily_mind/domain/services/topic_rotation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final all = Topic.allCodes;

  group('topicsForDay', () {
    test('gives the same topics all day, whatever the time', () {
      final morning = topicsForDay(date: DateTime(2026, 3, 10, 7), userId: 'u1', enabledTopics: all, topicsPerDay: TopicsPerDay.random);
      final night = topicsForDay(date: DateTime(2026, 3, 10, 23, 59), userId: 'u1', enabledTopics: all, topicsPerDay: TopicsPerDay.random);
      expect(night, morning);
    });

    test('does not depend on the order enabled topics are stored in', () {
      final a = topicsForDay(date: DateTime(2026, 3, 10), userId: 'u1', enabledTopics: all, topicsPerDay: TopicsPerDay.two);
      final b = topicsForDay(date: DateTime(2026, 3, 10), userId: 'u1', enabledTopics: all.reversed.toList(), topicsPerDay: TopicsPerDay.two);
      expect(b, a);
    });

    test('changes across days', () {
      final results = <String>{};
      for (var i = 0; i < 30; i++) {
        final day = DateKeys.addDays(DateTime(2026, 1, 1), i);
        results.add(topicsForDay(date: day, userId: 'u1', enabledTopics: all, topicsPerDay: TopicsPerDay.two).join(','));
      }
      expect(results.length, greaterThan(10));
    });

    test('differs between users on the same day', () {
      final results = <String>{
        for (var u = 0; u < 20; u++)
          topicsForDay(date: DateTime(2026, 5, 5), userId: 'user-$u', enabledTopics: all, topicsPerDay: TopicsPerDay.two).join(','),
      };
      expect(results.length, greaterThan(5));
    });

    test('avoids yesterday\'s topics when enough remain', () {
      for (var i = 0; i < 50; i++) {
        final day = DateKeys.addDays(DateTime(2026, 1, 1), i);
        final yesterday = ['math', 'english'];
        final today = topicsForDay(date: day, userId: 'u$i', enabledTopics: all, topicsPerDay: TopicsPerDay.two, yesterdayTopics: yesterday);
        expect(today.any(yesterday.contains), isFalse, reason: 'day $i picked $today');
      }
    });

    test('reuses yesterday\'s topics when too few remain', () {
      final today = topicsForDay(
        date: DateTime(2026, 2, 2),
        userId: 'u1',
        enabledTopics: ['math', 'english'],
        topicsPerDay: TopicsPerDay.two,
        yesterdayTopics: ['math'],
      );
      expect(today.toSet(), {'math', 'english'});
    });

    test('respects the topics-per-day setting', () {
      for (var i = 0; i < 20; i++) {
        final day = DateKeys.addDays(DateTime(2026, 1, 1), i);
        expect(topicsForDay(date: day, userId: 'u', enabledTopics: all, topicsPerDay: TopicsPerDay.one).length, 1);
        expect(topicsForDay(date: day, userId: 'u', enabledTopics: all, topicsPerDay: TopicsPerDay.two).length, 2);
        final random = topicsForDay(date: day, userId: 'u', enabledTopics: all, topicsPerDay: TopicsPerDay.random).length;
        expect(random, inInclusiveRange(1, 2));
      }
    });

    test('only returns enabled topics, and nothing when none are enabled', () {
      final picked = topicsForDay(date: DateTime(2026, 1, 1), userId: 'u', enabledTopics: ['french', 'finance'], topicsPerDay: TopicsPerDay.two);
      expect(picked.toSet(), {'french', 'finance'});
      expect(topicsForDay(date: DateTime(2026, 1, 1), userId: 'u', enabledTopics: const [], topicsPerDay: TopicsPerDay.two), isEmpty);
    });
  });
}
