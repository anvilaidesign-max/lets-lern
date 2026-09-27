/// The user's history with one content item.
class ItemProgress {
  const ItemProgress({
    required this.itemId,
    this.seenCount = 0,
    this.answeredCorrect = 0,
    this.answeredWrong = 0,
    this.lastAnswerCorrect,
    this.lastSeenAt,
    this.saved = false,
    this.savedUpdatedAt,
    this.reported = false,
  });

  final String itemId;
  final int seenCount;
  final int answeredCorrect;
  final int answeredWrong;
  final bool? lastAnswerCorrect;
  final DateTime? lastSeenAt;
  final bool saved;
  final DateTime? savedUpdatedAt;
  final bool reported;

  /// "Answered wrong before" for light spaced repetition (ARCHITECTURE.md 8.2):
  /// the last answer was wrong, or wrong answers outnumber right ones.
  bool get needsReview =>
      lastAnswerCorrect == false || answeredWrong > answeredCorrect;

  static const empty = ItemProgress(itemId: '');
}

/// Progress counters as exchanged with the server. Used by the merge rules.
class ProgressCounters {
  const ProgressCounters({
    required this.itemId,
    required this.seenCount,
    required this.answeredCorrect,
    required this.answeredWrong,
    required this.lastSeenAt,
    required this.saved,
    required this.savedUpdatedAt,
  });

  final String itemId;
  final int seenCount;
  final int answeredCorrect;
  final int answeredWrong;
  final DateTime? lastSeenAt;
  final bool saved;
  final DateTime? savedUpdatedAt;

  @override
  bool operator ==(Object other) =>
      other is ProgressCounters &&
      other.itemId == itemId &&
      other.seenCount == seenCount &&
      other.answeredCorrect == answeredCorrect &&
      other.answeredWrong == answeredWrong &&
      other.lastSeenAt == lastSeenAt &&
      other.saved == saved &&
      other.savedUpdatedAt == savedUpdatedAt;

  @override
  int get hashCode => Object.hash(itemId, seenCount, answeredCorrect, answeredWrong, lastSeenAt, saved, savedUpdatedAt);

  @override
  String toString() =>
      'ProgressCounters($itemId, seen=$seenCount, ok=$answeredCorrect, wrong=$answeredWrong, saved=$saved)';
}

class DailyActivity {
  const DailyActivity({required this.day, required this.topics, required this.itemsCompleted});

  /// Local `yyyy-MM-dd`.
  final String day;
  final List<String> topics;
  final int itemsCompleted;
}

class TopicAccuracy {
  const TopicAccuracy({required this.topicCode, required this.correct, required this.wrong, required this.seen});

  final String topicCode;
  final int correct;
  final int wrong;
  final int seen;

  int get answered => correct + wrong;
  double? get accuracy => answered == 0 ? null : correct / answered;
}
