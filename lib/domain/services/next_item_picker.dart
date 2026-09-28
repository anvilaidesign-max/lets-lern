import 'dart:math';

import '../models/app_settings.dart';
import '../models/content_item.dart';
import '../models/progress.dart';

/// Keeps the items that match the learner's level. Falls back to the whole
/// pool when nothing matches, so a topic never looks empty.
List<ContentItem> filterByLevel(List<ContentItem> pool, LearningLevel level) {
  if (level == LearningLevel.mixed) return pool;
  final matching = [for (final i in pool) if (level.allows(i.difficulty)) i];
  return matching.isEmpty ? pool : matching;
}

/// Picks the next item to show (ARCHITECTURE.md 8.2):
///  * aim for ~40% challenges, 30% facts/lessons, 30% words/phrases;
///  * inside a group prefer never-seen items, then items answered wrong
///    before, then the item seen longest ago;
///  * never repeat an item seen in the last 7 days unless the pool is
///    exhausted.
class NextItemPicker {
  NextItemPicker._();

  static const repeatWindow = Duration(days: 7);

  static ContentItem? pick({
    required List<ContentItem> pool,
    required Map<String, ItemProgress> progress,
    required DateTime now,
    required Random random,
    Set<String> exclude = const {},
    ContentGroup? onlyGroup,
  }) {
    final items = [
      for (final item in pool)
        if (item.isActive &&
            !exclude.contains(item.id) &&
            (onlyGroup == null || item.type.group == onlyGroup))
          item,
    ];
    if (items.isEmpty) return null;

    ItemProgress p(ContentItem item) => progress[item.id] ?? ItemProgress(itemId: item.id);

    bool recentlySeen(ContentItem item) {
      final seen = p(item).lastSeenAt;
      return seen != null && now.difference(seen) < repeatWindow;
    }

    var candidates = items.where((i) => !recentlySeen(i)).toList();
    if (candidates.isEmpty) candidates = items; // pool exhausted

    final group = onlyGroup ?? _chooseGroup(candidates, random);
    final inGroup = candidates.where((i) => i.type.group == group).toList();
    final choices = inGroup.isEmpty ? candidates : inGroup;

    final unseen = choices.where((i) => p(i).seenCount == 0).toList();
    if (unseen.isNotEmpty) return unseen[random.nextInt(unseen.length)];

    final review = choices.where((i) => p(i).needsReview).toList();
    if (review.isNotEmpty) return _oldest(review, p);

    return _oldest(choices, p);
  }

  /// Picks up to [count] different items, e.g. for notifications or a quiz.
  static List<ContentItem> pickMany({
    required int count,
    required List<ContentItem> pool,
    required Map<String, ItemProgress> progress,
    required DateTime now,
    required Random random,
    Set<String> exclude = const {},
    ContentGroup? onlyGroup,
  }) {
    final picked = <ContentItem>[];
    final used = {...exclude};
    while (picked.length < count) {
      final next = pick(
        pool: pool,
        progress: progress,
        now: now,
        random: random,
        exclude: used,
        onlyGroup: onlyGroup,
      );
      if (next == null) break;
      picked.add(next);
      used.add(next.id);
    }
    return picked;
  }

  /// Weighted choice between the groups that still have items.
  static ContentGroup _chooseGroup(List<ContentItem> candidates, Random random) {
    final available = {for (final i in candidates) i.type.group};
    final groups = ContentGroup.values.where(available.contains).toList();
    final total = groups.fold<double>(0, (sum, g) => sum + g.targetShare);
    var roll = random.nextDouble() * total;
    for (final g in groups) {
      roll -= g.targetShare;
      if (roll < 0) return g;
    }
    return groups.last;
  }

  static ContentItem _oldest(List<ContentItem> items, ItemProgress Function(ContentItem) p) {
    final sorted = [...items]..sort((a, b) {
        final sa = p(a).lastSeenAt;
        final sb = p(b).lastSeenAt;
        if (sa == null && sb == null) return a.id.compareTo(b.id);
        if (sa == null) return -1;
        if (sb == null) return 1;
        final byTime = sa.compareTo(sb);
        return byTime != 0 ? byTime : a.id.compareTo(b.id);
      });
    return sorted.first;
  }
}
