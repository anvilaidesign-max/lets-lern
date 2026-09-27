import 'dart:convert';

import '../../core/errors/app_exception.dart';

/// Local essay states. The server only knows pending / done / failed; the app
/// tracks the finer steps of the two-step flow (ARCHITECTURE.md 9.3).
enum EssayStatus {
  /// Photo saved on the phone, waiting for internet to upload.
  queued,

  /// Uploading and reading the handwriting.
  transcribing,

  /// Text is ready for the user to check and edit.
  transcribed,

  /// Waiting for the score.
  scoring,

  done,
  failed;

  static EssayStatus parse(String value) =>
      EssayStatus.values.firstWhere((s) => s.name == value, orElse: () => EssayStatus.failed);

  bool get isBusy => this == transcribing || this == scoring;
}

class Essay {
  const Essay({
    required this.id,
    required this.prompt,
    required this.status,
    required this.createdAt,
    this.localImagePath,
    this.imagePath,
    this.extractedText,
    this.scoreTotal,
    this.result,
    this.errorMessage,
  });

  final String id;
  final String prompt;
  final EssayStatus status;
  final DateTime createdAt;
  final String? localImagePath;
  final String? imagePath;
  final String? extractedText;
  final int? scoreTotal;
  final EssayResult? result;
  final String? errorMessage;
}

class EssayMistake {
  const EssayMistake({required this.original, required this.correction, required this.reason});

  final String original;
  final String correction;
  final String reason;

  Map<String, dynamic> toJson() => {'original': original, 'correction': correction, 'reason': reason};
}

class EssayBreakdown {
  const EssayBreakdown({
    required this.ideas,
    required this.structure,
    required this.grammar,
    required this.spellingVocab,
  });

  final int ideas;
  final int structure;
  final int grammar;
  final int spellingVocab;

  int get total => ideas + structure + grammar + spellingVocab;
}

/// The scored result (schema in ARCHITECTURE.md 9.3). Parsed defensively:
/// anything malformed throws a [ValidationException].
class EssayResult {
  const EssayResult({
    required this.scoreTotal,
    required this.breakdown,
    required this.comments,
    required this.mistakes,
    required this.biggestHabit,
    required this.correctedVersion,
    required this.nextExercise,
  });

  final int scoreTotal;
  final EssayBreakdown breakdown;

  /// Keys: ideas, structure, grammar, spelling_vocab.
  final Map<String, String> comments;
  final List<EssayMistake> mistakes;
  final String biggestHabit;
  final String correctedVersion;
  final String nextExercise;

  static const categories = ['ideas', 'structure', 'grammar', 'spelling_vocab'];

  static EssayResult fromJson(Object? json) {
    if (json is! Map) throw const ValidationException('The essay result is missing.');

    int score(Object? map, String key) {
      if (map is! Map) throw const ValidationException('The essay breakdown is missing.');
      final value = map[key];
      if (value is! num) throw ValidationException('The "$key" score is missing.');
      final rounded = value.round();
      if (rounded < 0 || rounded > 5) throw ValidationException('The "$key" score is out of range.');
      return rounded;
    }

    final breakdownJson = json['breakdown'];
    final breakdown = EssayBreakdown(
      ideas: score(breakdownJson, 'ideas'),
      structure: score(breakdownJson, 'structure'),
      grammar: score(breakdownJson, 'grammar'),
      spellingVocab: score(breakdownJson, 'spelling_vocab'),
    );

    final commentsJson = json['breakdown_comments'];
    final comments = <String, String>{
      for (final key in categories)
        key: commentsJson is Map && commentsJson[key] is String ? commentsJson[key] as String : '',
    };

    final mistakesJson = json['mistakes'];
    final mistakes = <EssayMistake>[
      if (mistakesJson is List)
        for (final m in mistakesJson)
          if (m is Map && m['original'] is String && m['correction'] is String)
            EssayMistake(
              original: m['original'] as String,
              correction: m['correction'] as String,
              reason: m['reason'] is String ? m['reason'] as String : '',
            ),
    ];

    String text(String key) => json[key] is String ? json[key] as String : '';

    return EssayResult(
      // The total always equals the sum of the four categories.
      scoreTotal: breakdown.total,
      breakdown: breakdown,
      comments: comments,
      mistakes: mistakes,
      biggestHabit: text('biggest_habit'),
      correctedVersion: text('corrected_version'),
      nextExercise: text('next_exercise'),
    );
  }

  static EssayResult? tryDecode(String? source) {
    if (source == null || source.isEmpty) return null;
    try {
      return fromJson(jsonDecode(source));
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
        'score_total': scoreTotal,
        'breakdown': {
          'ideas': breakdown.ideas,
          'structure': breakdown.structure,
          'grammar': breakdown.grammar,
          'spelling_vocab': breakdown.spellingVocab,
        },
        'breakdown_comments': comments,
        'mistakes': [for (final m in mistakes) m.toJson()],
        'biggest_habit': biggestHabit,
        'corrected_version': correctedVersion,
        'next_exercise': nextExercise,
      };
}
