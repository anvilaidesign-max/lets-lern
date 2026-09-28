import 'dart:math';

import '../models/content_item.dart';

class MemoryPair {
  const MemoryPair({required this.id, required this.term, required this.meaning, required this.topicCode});

  final String id;
  final String term;
  final String meaning;
  final String topicCode;
}

/// Turns vocabulary and phrase cards into short term/meaning pairs that fit
/// on a game tile. French uses the translation; other words use the first
/// clause of the "Meaning: ..." body.
List<MemoryPair> buildMemoryPairs(List<ContentItem> items, int count, Random random, {int maxLength = 42}) {
  String? shorten(String text) {
    var t = text.trim();
    if (t.toLowerCase().startsWith('meaning:')) t = t.substring(8).trim();
    final cut = RegExp(r'[;.]').firstMatch(t);
    if (cut != null && cut.start > 3) t = t.substring(0, cut.start);
    t = t.trim();
    if (t.isEmpty) return null;
    if (t.length > maxLength) {
      final space = t.lastIndexOf(' ', maxLength - 1);
      t = '${t.substring(0, space > 10 ? space : maxLength - 1)}…';
    }
    return t;
  }

  final pairs = <MemoryPair>[];
  final seenTerms = <String>{};
  final shuffled = [...items]..shuffle(random);
  for (final item in shuffled) {
    if (item.type != ContentType.vocab && item.type != ContentType.phrase) continue;
    final term = item.term?.trim();
    if (term == null || term.isEmpty || term.length > 36 || !seenTerms.add(term.toLowerCase())) continue;
    final meaning = item.translation != null ? shorten(item.translation!) : shorten(item.body);
    if (meaning == null || meaning.toLowerCase() == term.toLowerCase()) continue;
    pairs.add(MemoryPair(id: item.id, term: term, meaning: meaning, topicCode: item.topicCode));
    if (pairs.length == count) break;
  }
  return pairs;
}
