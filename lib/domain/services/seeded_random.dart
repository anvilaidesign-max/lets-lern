import 'dart:convert';
import 'dart:math';

/// FNV-1a 32-bit hash. Stable across runs, devices and Dart versions, unlike
/// `String.hashCode`.
int stableHash(String input) {
  var hash = 0x811c9dc5;
  for (final unit in utf8.encode(input)) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}

/// Mulberry32 PRNG. Deterministic for a given seed on every platform, which
/// `dart:math` [Random] does not promise.
class SeededRandom implements Random {
  SeededRandom(int seed) : _state = seed & 0xFFFFFFFF;

  int _state;

  static int _imul(int a, int b) => (a * b) & 0xFFFFFFFF;

  int nextUint32() {
    _state = (_state + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = _state;
    t = _imul(t ^ (t >> 15), t | 1);
    t = (t ^ ((t + _imul(t ^ (t >> 7), t | 61)) & 0xFFFFFFFF)) & 0xFFFFFFFF;
    return (t ^ (t >> 14)) & 0xFFFFFFFF;
  }

  @override
  int nextInt(int max) {
    if (max <= 0) throw RangeError.range(max, 1, null, 'max');
    return nextUint32() % max;
  }

  @override
  double nextDouble() => nextUint32() / 4294967296.0;

  @override
  bool nextBool() => nextUint32() & 1 == 1;
}
