import '../../core/utils/date_utils.dart';
import '../models/app_settings.dart';
import '../models/topic.dart';
import 'seeded_random.dart';

/// Daily topic rotation (ARCHITECTURE.md 8.1).
///
/// Deterministic: the same user gets the same topics all day, even after a
/// restart, because the random generator is seeded with user id + date.
/// Yesterday's topics are avoided when enough other topics remain.
List<String> topicsForDay({
  required DateTime date,
  required String userId,
  required List<String> enabledTopics,
  required TopicsPerDay topicsPerDay,
  List<String> yesterdayTopics = const [],
}) {
  // Canonical order first, so the result never depends on the order the
  // settings happen to be stored in.
  final pool = [for (final code in Topic.allCodes) if (enabledTopics.contains(code)) code];
  if (pool.isEmpty) return const [];

  final rng = SeededRandom(stableHash('$userId|${DateKeys.dayKey(date)}'));
  final wanted = switch (topicsPerDay) {
    TopicsPerDay.one => 1,
    TopicsPerDay.two => 2,
    TopicsPerDay.random => rng.nextInt(2) + 1,
  };
  final n = wanted.clamp(1, pool.length);

  final fresh = pool.where((code) => !yesterdayTopics.contains(code)).toList();
  final candidates = fresh.length >= n ? fresh : pool;
  candidates.shuffle(rng);
  return candidates.take(n).toList();
}
