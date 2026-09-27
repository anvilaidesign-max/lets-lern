import 'dart:math';

import '../models/progress.dart';

/// Conflict rules (ARCHITECTURE.md 7.3). The server applies the same rules in
/// `sync_user_progress()`; this copy is used when pulling progress onto a
/// device (new phone or reinstall).
class SyncMerge {
  SyncMerge._();

  static final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  /// Counters take the higher value; `saved` is last write wins by
  /// `savedUpdatedAt` (ties keep the local value).
  static ProgressCounters progress(ProgressCounters local, ProgressCounters remote) {
    assert(local.itemId == remote.itemId);
    final localSavedAt = local.savedUpdatedAt ?? _epoch;
    final remoteSavedAt = remote.savedUpdatedAt ?? _epoch;
    final remoteWins = remoteSavedAt.isAfter(localSavedAt);

    return ProgressCounters(
      itemId: local.itemId,
      seenCount: max(local.seenCount, remote.seenCount),
      answeredCorrect: max(local.answeredCorrect, remote.answeredCorrect),
      answeredWrong: max(local.answeredWrong, remote.answeredWrong),
      lastSeenAt: _latest(local.lastSeenAt, remote.lastSeenAt),
      saved: remoteWins ? remote.saved : local.saved,
      savedUpdatedAt: remoteWins ? remote.savedUpdatedAt : local.savedUpdatedAt,
    );
  }

  /// Items completed on a day: the higher count wins.
  static int itemsCompleted(int local, int remote) => max(local, remote);

  static DateTime? _latest(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }
}
