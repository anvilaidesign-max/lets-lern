import 'package:daily_mind/features/reader/chapter_markup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChapterMarkup.inline', () {
    List<TextSpan> spans(String text) =>
        ChapterMarkup.inline(text, const TextStyle(fontSize: 16)).children!.cast<TextSpan>();

    test('bold, italic, struck and code become styled spans without markers', () {
      final s = spans('A **bold** word, *Conradie v Rossouw*, ~~wrong~~ and `V = IR`.');
      final text = s.map((e) => e.text).join();
      expect(text, 'A bold word, Conradie v Rossouw, wrong and V = IR.');
      expect(s.firstWhere((e) => e.text == 'bold').style!.fontWeight, FontWeight.w700);
      expect(s.firstWhere((e) => e.text == 'Conradie v Rossouw').style!.fontStyle, FontStyle.italic);
      expect(s.firstWhere((e) => e.text == 'wrong').style!.decoration, TextDecoration.lineThrough);
      expect(s.firstWhere((e) => e.text == 'V = IR').style!.fontFamily, 'monospace');
    });

    test('a lone asterisk with spaces around it stays literal', () {
      final s = spans('2 * 3 is not markup');
      expect(s.map((e) => e.text).join(), '2 * 3 is not markup');
    });
  });
}
