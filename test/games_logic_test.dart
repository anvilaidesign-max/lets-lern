import 'dart:math';

import 'package:daily_mind/domain/models/app_settings.dart';
import 'package:daily_mind/domain/models/content_item.dart';
import 'package:daily_mind/domain/services/math_problems.dart';
import 'package:daily_mind/domain/services/memory_pairs.dart';
import 'package:daily_mind/domain/services/next_item_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MathProblemGenerator', () {
    test('every problem has three distinct options including the answer', () {
      final gen = MathProblemGenerator(Random(1));
      for (var level = 1; level <= 8; level++) {
        for (var i = 0; i < 200; i++) {
          final p = gen.next(level);
          expect(p.options.length, 3, reason: p.text);
          expect(p.options.toSet().length, 3, reason: p.text);
          expect(p.options, contains(p.answer), reason: p.text);
          expect(p.options.every((o) => o >= 0), isTrue, reason: p.text);
        }
      }
    });

    test('answers are mathematically correct', () {
      final gen = MathProblemGenerator(Random(2));
      final plain = RegExp(r'^(\d+) ([+−×÷]) (\d+)$');
      var checked = 0;
      for (var i = 0; i < 500; i++) {
        final p = gen.next(1 + i % 4);
        final m = plain.firstMatch(p.text);
        if (m == null) continue;
        final a = int.parse(m.group(1)!), b = int.parse(m.group(3)!);
        final expected = switch (m.group(2)) {
          '+' => a + b,
          '−' => a - b,
          '×' => a * b,
          _ => a ~/ b,
        };
        expect(p.answer, expected, reason: p.text);
        checked++;
      }
      expect(checked, greaterThan(100));
    });

    test('higher levels bring electronics problems with units', () {
      final gen = MathProblemGenerator(Random(3));
      final units = {for (var i = 0; i < 300; i++) gen.next(7).unit};
      expect(units, containsAll(['V', 'W', 'Ω']));
    });
  });

  group('buildMemoryPairs', () {
    test('uses translations for French and trims meanings for words', () {
      final items = [
        const ContentItem(id: '1', topicCode: 'french', type: ContentType.phrase, title: 't', body: 'b', term: 'Bonjour', translation: 'Hello / Good day'),
        const ContentItem(id: '2', topicCode: 'english', type: ContentType.vocab, title: 't', body: 'Meaning: showing great attention to detail; very careful.', term: 'meticulous'),
        const ContentItem(id: '3', topicCode: 'math', type: ContentType.fact, title: 't', body: 'not a word'),
      ];
      final pairs = buildMemoryPairs(items, 6, Random(1));
      expect(pairs.length, 2);
      final byTerm = {for (final p in pairs) p.term: p.meaning};
      expect(byTerm['Bonjour'], 'Hello / Good day');
      expect(byTerm['meticulous'], 'showing great attention to detail');
    });
  });

  group('filterByLevel', () {
    ContentItem item(String id, int d) => ContentItem(id: id, topicCode: 'math', type: ContentType.fact, title: id, body: 'b', difficulty: d);

    test('keeps matching difficulties and falls back when nothing matches', () {
      final pool = [item('a', 1), item('b', 2), item('c', 3)];
      expect(filterByLevel(pool, LearningLevel.basics).map((i) => i.id), ['a', 'b']);
      expect(filterByLevel(pool, LearningLevel.advanced).map((i) => i.id), ['b', 'c']);
      expect(filterByLevel(pool, LearningLevel.mixed).length, 3);
      expect(filterByLevel([item('x', 1)], LearningLevel.advanced).single.id, 'x');
    });
  });
}
