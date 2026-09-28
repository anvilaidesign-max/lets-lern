import 'dart:convert';

/// One multiple-choice question at the end of a chapter.
class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;

  /// Returns null when the question is malformed, so one bad question never
  /// breaks a chapter.
  static QuizQuestion? tryParse(Object? json) {
    if (json is! Map) return null;
    final question = json['question'];
    final options = json['options'];
    final answer = json['answer'];
    if (question is! String || options is! List || answer is! num) return null;
    final opts = options.whereType<String>().toList();
    final index = answer.toInt();
    if (opts.length < 2 || index < 0 || index >= opts.length) return null;
    return QuizQuestion(
      question: question,
      options: opts,
      answerIndex: index,
      explanation: json['explanation'] is String ? json['explanation'] as String : '',
    );
  }
}

class ChapterSource {
  const ChapterSource(this.name, this.url);
  final String name;
  final String url;
}

/// A chapter of a topic's book: reading, key points, sources and a quiz.
class Chapter {
  const Chapter({
    required this.id,
    required this.topicCode,
    required this.position,
    required this.title,
    required this.summary,
    required this.body,
    required this.keyPoints,
    required this.quiz,
    required this.difficulty,
    required this.sources,
  });

  final String id;
  final String topicCode;
  final int position;
  final String title;
  final String summary;

  /// Light markup: `## heading`, `### subheading`, `- bullet`, `> callout`,
  /// blank lines between paragraphs, `**bold**` inline.
  final String body;
  final List<String> keyPoints;
  final List<QuizQuestion> quiz;
  final int difficulty;
  final List<ChapterSource> sources;

  /// About 200 words a minute.
  int get readingMinutes {
    final words = body.split(RegExp(r'\s+')).length;
    return (words / 200).ceil().clamp(1, 60);
  }

  static List<String> decodeStrings(String? source) {
    if (source == null || source.isEmpty) return const [];
    try {
      final value = jsonDecode(source);
      return value is List ? value.whereType<String>().toList() : const [];
    } catch (_) {
      return const [];
    }
  }

  static List<QuizQuestion> decodeQuiz(String? source) {
    if (source == null || source.isEmpty) return const [];
    try {
      final value = jsonDecode(source);
      if (value is! List) return const [];
      return value.map(QuizQuestion.tryParse).whereType<QuizQuestion>().toList();
    } catch (_) {
      return const [];
    }
  }

  static List<ChapterSource> decodeSources(String? source) {
    if (source == null || source.isEmpty) return const [];
    try {
      final value = jsonDecode(source);
      if (value is! List) return const [];
      return [
        for (final s in value)
          if (s is Map && s['name'] is String && s['url'] is String) ChapterSource(s['name'] as String, s['url'] as String),
      ];
    } catch (_) {
      return const [];
    }
  }
}

class ChapterProgress {
  const ChapterProgress({
    required this.chapterId,
    this.readAt,
    this.bestScore,
    this.lastScore,
    this.attempts = 0,
    this.totalQuestions,
  });

  final String chapterId;
  final DateTime? readAt;
  final int? bestScore;
  final int? lastScore;
  final int attempts;
  final int? totalQuestions;

  bool get isRead => readAt != null;
  bool get quizTaken => attempts > 0;

  /// A quiz counts as passed at 60% or more.
  bool get passed => bestScore != null && totalQuestions != null && totalQuestions! > 0 && bestScore! / totalQuestions! >= 0.6;
}

/// A chapter with the user's progress, for lists.
class ChapterEntry {
  const ChapterEntry(this.chapter, this.progress);
  final Chapter chapter;
  final ChapterProgress? progress;
}
