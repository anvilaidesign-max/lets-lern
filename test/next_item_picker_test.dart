import 'dart:math';

import 'package:daily_mind/domain/models/content_item.dart';
import 'package:daily_mind/domain/models/progress.dart';
import 'package:daily_mind/domain/services/next_item_picker.dart';
import 'package:flutter_test/flutter_test.dart';

ContentItem item(String id, ContentType type) => ContentItem(
      id: id,
      topicCode: 'math',
      type: type,
      title: 'Item $id',
      body: 'Body',
      statement: type == ContentType.challenge ? 'Statement $id' : null,
      isTrue: type == ContentType.challenge ? true : null,
      term: type == ContentType.vocab ? 'term$id' : null,
    );

void main() {
  final now = DateTime(2026, 6, 15, 12);

  group('NextItemPicker', () {
    test('prefers items never seen', () {
      final pool = [item('a', ContentType.fact), item('b', ContentType.fact), item('c', ContentType.fact)];
      final progress = {
        'a': ItemProgress(itemId: 'a', seenCount: 3, lastSeenAt: now.subtract(const Duration(days: 30))),
        'c': ItemProgress(itemId: 'c', seenCount: 1, lastSeenAt: now.subtract(const Duration(days: 20))),
      };
      for (var seed = 0; seed < 20; seed++) {
        expect(NextItemPicker.pick(pool: pool, progress: progress, now: now, random: Random(seed))!.id, 'b');
      }
    });

    test('then items answered wrong before', () {
      final pool = [item('a', ContentType.challenge), item('b', ContentType.challenge), item('c', ContentType.challenge)];
      final old = now.subtract(const Duration(days: 10));
      final progress = {
        'a': ItemProgress(itemId: 'a', seenCount: 1, answeredCorrect: 1, lastAnswerCorrect: true, lastSeenAt: old.subtract(const Duration(days: 5))),
        'b': ItemProgress(itemId: 'b', seenCount: 1, answeredWrong: 1, lastAnswerCorrect: false, lastSeenAt: old),
        'c': ItemProgress(itemId: 'c', seenCount: 1, answeredCorrect: 1, lastAnswerCorrect: true, lastSeenAt: old),
      };
      expect(NextItemPicker.pick(pool: pool, progress: progress, now: now, random: Random(1))!.id, 'b');
    });

    test('then the item seen longest ago', () {
      final pool = [item('a', ContentType.fact), item('b', ContentType.fact)];
      final progress = {
        'a': ItemProgress(itemId: 'a', seenCount: 1, lastSeenAt: now.subtract(const Duration(days: 9))),
        'b': ItemProgress(itemId: 'b', seenCount: 1, lastSeenAt: now.subtract(const Duration(days: 20))),
      };
      expect(NextItemPicker.pick(pool: pool, progress: progress, now: now, random: Random(1))!.id, 'b');
    });

    test('does not repeat items seen in the last 7 days', () {
      final pool = [item('a', ContentType.fact), item('b', ContentType.fact)];
      final progress = {
        // 'a' was wrong recently, but it is inside the 7 day window.
        'a': ItemProgress(itemId: 'a', seenCount: 1, answeredWrong: 1, lastAnswerCorrect: false, lastSeenAt: now.subtract(const Duration(days: 2))),
        'b': ItemProgress(itemId: 'b', seenCount: 1, lastSeenAt: now.subtract(const Duration(days: 8))),
      };
      expect(NextItemPicker.pick(pool: pool, progress: progress, now: now, random: Random(1))!.id, 'b');
    });

    test('repeats recent items only when the pool is exhausted', () {
      final pool = [item('a', ContentType.fact), item('b', ContentType.fact)];
      final progress = {
        'a': ItemProgress(itemId: 'a', seenCount: 1, lastSeenAt: now.subtract(const Duration(days: 1))),
        'b': ItemProgress(itemId: 'b', seenCount: 1, lastSeenAt: now.subtract(const Duration(days: 3))),
      };
      expect(NextItemPicker.pick(pool: pool, progress: progress, now: now, random: Random(1))!.id, 'b');
    });

    test('respects exclusions and returns null for an empty pool', () {
      final pool = [item('a', ContentType.fact)];
      expect(NextItemPicker.pick(pool: pool, progress: const {}, now: now, random: Random(1), exclude: {'a'}), isNull);
      expect(NextItemPicker.pick(pool: const [], progress: const {}, now: now, random: Random(1)), isNull);
    });

    test('mixes types at roughly 40% challenges, 30% facts, 30% words', () {
      final pool = [
        for (var i = 0; i < 50; i++) item('c$i', ContentType.challenge),
        for (var i = 0; i < 50; i++) item('f$i', ContentType.fact),
        for (var i = 0; i < 50; i++) item('v$i', ContentType.vocab),
      ];
      final random = Random(42);
      final counts = <ContentGroup, int>{};
      for (var i = 0; i < 3000; i++) {
        final picked = NextItemPicker.pick(pool: pool, progress: const {}, now: now, random: random)!;
        counts.update(picked.type.group, (v) => v + 1, ifAbsent: () => 1);
      }
      expect(counts[ContentGroup.challenge]! / 3000, closeTo(0.4, 0.05));
      expect(counts[ContentGroup.knowledge]! / 3000, closeTo(0.3, 0.05));
      expect(counts[ContentGroup.words]! / 3000, closeTo(0.3, 0.05));
    });

    test('pickMany returns distinct items', () {
      final pool = [for (var i = 0; i < 10; i++) item('x$i', ContentType.challenge)];
      final picked = NextItemPicker.pickMany(count: 5, pool: pool, progress: const {}, now: now, random: Random(3));
      expect(picked.length, 5);
      expect(picked.map((i) => i.id).toSet().length, 5);
    });
  });
}
