import 'dart:math';

/// A mental maths problem with three answer choices.
class MathProblem {
  const MathProblem({required this.text, required this.answer, required this.options, required this.unit});

  final String text;
  final int answer;
  final List<int> options;

  /// Shown after the number on buttons, e.g. "V" or "W". Empty for plain maths.
  final String unit;
}

/// Generates problems that get harder with [level]:
/// 1 add/subtract, 2 bigger sums and times tables, 3 division,
/// 4 percentages and squares, 5 powers and algebra,
/// 6+ electronics (Ohm's law, power, series and parallel resistors) mixed
/// with harder mental arithmetic.
class MathProblemGenerator {
  MathProblemGenerator(this._random);

  final Random _random;

  int _r(int min, int max) => min + _random.nextInt(max - min + 1);

  MathProblem next(int level) {
    final l = level.clamp(1, 8);
    final kinds = <MathProblem Function()>[
      if (l <= 2) _addSub,
      if (l >= 2 && l <= 4) _times,
      if (l >= 3 && l <= 5) _divide,
      if (l >= 4) _percent,
      if (l >= 4 && l <= 6) _square,
      if (l >= 5) _power,
      if (l >= 5) _algebra,
      if (l >= 6) _ohm,
      if (l >= 6) _electricPower,
      if (l >= 7) _resistors,
      if (l >= 7) _hardTimes,
    ];
    return kinds[_random.nextInt(kinds.length)]();
  }

  MathProblem _make(String text, int answer, {String unit = '', List<int>? near}) {
    final options = <int>{answer};
    final candidates = near ??
        [answer + 1, answer - 1, answer + 2, answer - 2, answer + 10, answer - 10, answer * 2, (answer / 2).round()];
    candidates.shuffle(_random);
    for (final c in candidates) {
      if (options.length == 3) break;
      if (c != answer && c >= 0) options.add(c);
    }
    var fill = answer + 3;
    while (options.length < 3) {
      options.add(fill++);
    }
    final list = options.toList()..shuffle(_random);
    return MathProblem(text: text, answer: answer, options: list, unit: unit);
  }

  MathProblem _addSub() {
    final a = _r(3, 20), b = _r(2, 15);
    if (_random.nextBool()) return _make('$a + $b', a + b);
    final big = max(a, b), small = min(a, b);
    return _make('$big − $small', big - small);
  }

  MathProblem _times() {
    final a = _r(3, 12), b = _r(3, 12);
    return _make('$a × $b', a * b, near: [a * b + a, a * b - a, a * b + b, a * b - b, a * b + 10]);
  }

  MathProblem _divide() {
    final b = _r(3, 12), q = _r(3, 12);
    return _make('${b * q} ÷ $b', q);
  }

  MathProblem _percent() {
    const pcts = [10, 20, 25, 50, 75, 5, 15];
    final p = pcts[_random.nextInt(pcts.length)];
    final base = _r(1, 20) * 20;
    final answer = base * p ~/ 100;
    return _make('$p% of $base', answer, near: [answer + 5, answer - 5, answer * 2, answer + 10, base * p ~/ 10]);
  }

  MathProblem _square() {
    final a = _r(11, 20);
    return _make('$a²', a * a, near: [a * a + a, a * a - a, a * a + 10, a * a - 10, (a + 1) * (a + 1)]);
  }

  MathProblem _power() {
    final e = _r(4, 10);
    final v = 1 << e;
    return _make('2^$e', v, near: [v * 2, v ~/ 2, v + 2, v - 2]);
  }

  MathProblem _algebra() {
    final x = _r(2, 12), a = _r(2, 9), b = _r(1, 20);
    return _make('${a}x + $b = ${a * x + b}   x = ?', x);
  }

  MathProblem _ohm() {
    final i = _r(1, 9), r = _r(2, 12);
    switch (_random.nextInt(3)) {
      case 0:
        return _make('V = I·R   I=$i A, R=$r Ω', i * r, unit: 'V');
      case 1:
        return _make('I = V/R   V=${i * r} V, R=$r Ω', i, unit: 'A', near: [i + 1, i - 1, i * 2, r]);
      default:
        return _make('R = V/I   V=${i * r} V, I=$i A', r, unit: 'Ω', near: [r + 1, r - 1, r * 2, i]);
    }
  }

  MathProblem _electricPower() {
    final v = [5, 9, 12, 24, 48, 230][_random.nextInt(6)];
    final i = _r(1, 5);
    return _make('P = V·I   V=$v V, I=$i A', v * i, unit: 'W', near: [v * i + v, v * i - v, v + i, v * i * 2]);
  }

  MathProblem _resistors() {
    if (_random.nextBool()) {
      final a = _r(1, 20) * 10, b = _r(1, 20) * 10;
      return _make('Series: $a Ω + $b Ω', a + b, unit: 'Ω', near: [a + b + 10, a + b - 10, (a * b) ~/ (a + b), max(a, b)]);
    }
    // Equal resistors in parallel: R / n.
    final n = _r(2, 4), r = [60, 120, 240, 360][_random.nextInt(4)];
    return _make('$n × $r Ω in parallel', r ~/ n, unit: 'Ω', near: [r * n, r, r ~/ n + 10, r ~/ (n + 1)]);
  }

  MathProblem _hardTimes() {
    final a = _r(13, 29), b = _r(3, 9);
    return _make('$a × $b', a * b, near: [a * b + b, a * b - b, a * b + 10, a * b - 10]);
  }
}
