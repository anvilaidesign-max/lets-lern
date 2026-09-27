import 'dart:convert';

import 'package:daily_mind/core/errors/app_exception.dart';
import 'package:daily_mind/domain/models/essay.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> validJson() => {
      'score_total': 11,
      'breakdown': {'ideas': 3, 'structure': 3, 'grammar': 2, 'spelling_vocab': 3},
      'breakdown_comments': {'ideas': 'Clear.', 'structure': 'OK.', 'grammar': 'Comma splices.', 'spelling_vocab': 'Some errors.'},
      'mistakes': [
        {'original': 'I recieve', 'correction': 'I receive', 'reason': 'i before e except after c'},
      ],
      'biggest_habit': 'Joining sentences with commas.',
      'corrected_version': 'I receive a lot of letters.',
      'next_exercise': 'Rewrite five sentences.',
    };

void main() {
  group('EssayResult.fromJson', () {
    test('parses a valid result', () {
      final r = EssayResult.fromJson(validJson());
      expect(r.scoreTotal, 11);
      expect(r.breakdown.grammar, 2);
      expect(r.comments['grammar'], 'Comma splices.');
      expect(r.mistakes.single.correction, 'I receive');
      expect(r.biggestHabit, isNotEmpty);
    });

    test('recomputes the total from the breakdown', () {
      final json = validJson()..['score_total'] = 19;
      expect(EssayResult.fromJson(json).scoreTotal, 11);
    });

    test('rejects missing or out of range scores', () {
      final missing = validJson()..['breakdown'] = {'ideas': 3};
      expect(() => EssayResult.fromJson(missing), throwsA(isA<ValidationException>()));

      final tooHigh = validJson();
      (tooHigh['breakdown'] as Map)['ideas'] = 7;
      expect(() => EssayResult.fromJson(tooHigh), throwsA(isA<ValidationException>()));

      expect(() => EssayResult.fromJson('not a map'), throwsA(isA<ValidationException>()));
    });

    test('skips malformed mistakes instead of failing', () {
      final json = validJson()
        ..['mistakes'] = [
          {'original': 'a'},
          'nonsense',
          {'original': 'teh', 'correction': 'the'},
        ];
      final r = EssayResult.fromJson(json);
      expect(r.mistakes.length, 1);
      expect(r.mistakes.single.reason, '');
    });

    test('round-trips through toJson', () {
      final r = EssayResult.fromJson(validJson());
      final again = EssayResult.tryDecode(jsonEncode(r.toJson()))!;
      expect(again.scoreTotal, r.scoreTotal);
      expect(again.mistakes.length, r.mistakes.length);
      expect(EssayResult.tryDecode('{broken'), isNull);
    });
  });
}
