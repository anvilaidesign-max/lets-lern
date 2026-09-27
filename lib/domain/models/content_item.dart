/// Content types (ARCHITECTURE.md 5.1).
enum ContentType {
  fact,
  lesson,
  challenge,
  vocab,
  phrase;

  static ContentType? tryParse(String? value) {
    for (final t in values) {
      if (t.name == value) return t;
    }
    return null;
  }

  /// The three groups used for the 40/30/30 mix (ARCHITECTURE.md 8.2).
  ContentGroup get group => switch (this) {
        ContentType.challenge => ContentGroup.challenge,
        ContentType.fact || ContentType.lesson => ContentGroup.knowledge,
        ContentType.vocab || ContentType.phrase => ContentGroup.words,
      };

  String get label => switch (this) {
        ContentType.fact => 'Fact',
        ContentType.lesson => 'Lesson',
        ContentType.challenge => 'True or false',
        ContentType.vocab => 'Word',
        ContentType.phrase => 'Phrase',
      };
}

enum ContentGroup {
  challenge(0.4, 'Challenges'),
  knowledge(0.3, 'Facts & lessons'),
  words(0.3, 'Words & phrases');

  const ContentGroup(this.targetShare, this.label);
  final double targetShare;
  final String label;
}

class ContentItem {
  const ContentItem({
    required this.id,
    required this.topicCode,
    required this.type,
    required this.title,
    required this.body,
    this.statement,
    this.isTrue,
    this.correctAnswer,
    this.explanation,
    this.term,
    this.translation,
    this.exampleSentence,
    this.difficulty = 1,
    this.sourceName,
    this.sourceUrl,
    this.verified = false,
    this.inOfflinePack = false,
    this.isActive = true,
    this.updatedAt,
  });

  final String id;
  final String topicCode;
  final ContentType type;
  final String title;
  final String body;
  final String? statement;
  final bool? isTrue;
  final String? correctAnswer;
  final String? explanation;
  final String? term;
  final String? translation;
  final String? exampleSentence;
  final int difficulty;
  final String? sourceName;
  final String? sourceUrl;
  final bool verified;
  final bool inOfflinePack;
  final bool isActive;
  final DateTime? updatedAt;

  bool get isChallenge => type == ContentType.challenge && statement != null && isTrue != null;

  /// Text shown when the item is the preview on the home card.
  String get preview => switch (type) {
        ContentType.challenge => statement ?? title,
        ContentType.vocab || ContentType.phrase => term ?? title,
        _ => title,
      };
}
