import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/math_problems.dart';
import 'game_kit.dart';

/// Falling Numbers: a problem falls like a meteor; tap the right answer
/// before it lands. Faster and harder every 5 correct answers, up to
/// electronics formulas.
class NumberRushScreen extends ConsumerStatefulWidget {
  const NumberRushScreen({super.key});

  static const id = 'number_rush';

  @override
  ConsumerState<NumberRushScreen> createState() => _NumberRushScreenState();
}

enum _Phase { countdown, playing, over }

class _NumberRushScreenState extends ConsumerState<NumberRushScreen> with SingleTickerProviderStateMixin {
  final _generator = MathProblemGenerator(Random());
  late final AnimationController _fall = AnimationController(vsync: this)..addStatusListener(_onFallStatus);

  _Phase _phase = _Phase.countdown;
  MathProblem? _problem;
  int _score = 0;
  int _lives = 3;
  int _level = 1;
  int _correctInLevel = 0;
  int _combo = 0;
  int _burst = 0;
  int _shake = 0;
  int? _flashWrong;
  Offset _burstAt = Offset.zero;
  Size _field = Size.zero;
  static const _cardHeight = 150.0;
  static const _shipSize = 64.0;
  int _meteor = 1;
  int _laser = 0;
  double _laserTop = 0;
  bool _record = false;
  int _best = 0;
  String? _levelBanner;

  @override
  void dispose() {
    _fall.dispose();
    super.dispose();
  }

  Duration get _fallTime => Duration(milliseconds: (8000 - _level * 650).clamp(2800, 8000));

  void _start() {
    setState(() {
      _phase = _Phase.playing;
      _score = 0;
      _lives = 3;
      _level = 1;
      _correctInLevel = 0;
      _combo = 0;
      _flashWrong = null;
    });
    _nextProblem();
  }

  void _nextProblem() {
    setState(() {
      _problem = _generator.next(_level);
      _meteor = 1 + Random().nextInt(4);
      _flashWrong = null;
    });
    _fall
      ..duration = _fallTime
      ..forward(from: 0);
  }

  void _onFallStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _phase == _Phase.playing) _miss();
  }

  void _miss() {
    GameHaptics.bad();
    setState(() {
      _lives--;
      _combo = 0;
      _shake++;
    });
    if (_lives <= 0) {
      _gameOver();
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _phase == _Phase.playing) _nextProblem();
      });
    }
  }

  void _answer(int value) {
    final problem = _problem;
    if (problem == null || _phase != _Phase.playing || !_fall.isAnimating) return;
    _fall.stop();
    if (value == problem.answer) {
      GameHaptics.good();
      final speedBonus = ((1 - _fall.value) * 10).round();
      setState(() {
        _combo++;
        _score += 10 * _level + speedBonus + (_combo >= 3 ? _combo * 2 : 0);
        _burst++;
        _burstAt = Offset(_field.width / 2, _fall.value * (_field.height - _cardHeight - _shipSize - 12) + 50);
        _laserTop = _burstAt.dy;
        _laser++;
        _correctInLevel++;
        if (_correctInLevel >= 5) {
          _level++;
          _correctInLevel = 0;
          _levelBanner = _level >= 6 ? 'Level $_level · Electronics!' : 'Level $_level';
        }
      });
      if (_levelBanner != null) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) setState(() => _levelBanner = null);
        });
      }
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted && _phase == _Phase.playing) _nextProblem();
      });
    } else {
      setState(() => _flashWrong = value);
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) _miss();
      });
    }
  }

  Future<void> _gameOver() async {
    _fall.stop();
    setState(() => _phase = _Phase.over);
    final record = await recordGameResult(ref, NumberRushScreen.id, _score);
    if (!mounted) return;
    setState(() {
      _record = record;
      _best = bestScore(ref, NumberRushScreen.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: GameBackground(
        child: Stack(
          children: [
            StarField(speed: 0.02 + _level * 0.01),
            SafeArea(
              child: Column(
                children: [
                  GameHud(title: 'Falling Numbers', score: _score, extra: HeartsRow(lives: _lives)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text('Level $_level', style: const TextStyle(color: GameColors.muted, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        if (_combo >= 3)
                          Text('Combo x$_combo 🔥', style: const TextStyle(color: GameColors.gold, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  Expanded(child: _playfield()),
                  _answers(),
                ],
              ),
            ),
            if (_levelBanner != null)
              IgnorePointer(
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(_levelBanner),
                    tween: Tween(begin: 0.5, end: 1),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (context, s, child) => Transform.scale(scale: s, child: child),
                    child: Text(
                      _levelBanner!,
                      style: const TextStyle(color: GameColors.gold, fontSize: 40, fontWeight: FontWeight.w900, shadows: [Shadow(blurRadius: 20, color: Colors.black)]),
                    ),
                  ),
                ),
              ),
            if (_phase == _Phase.countdown) CountdownOverlay(onDone: _start),
            if (_phase == _Phase.over)
              ColoredBox(
                color: Colors.black54,
                child: GameOverView(
                  score: _score,
                  best: max(_best, _score),
                  isRecord: _record,
                  stars: _level >= 7 ? 3 : _level >= 4 ? 2 : _level >= 2 ? 1 : 0,
                  message: 'You reached level $_level.',
                  onPlayAgain: () => setState(() => _phase = _Phase.countdown),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _playfield() {
    return LayoutBuilder(builder: (context, constraints) {
      _field = constraints.biggest;
      const cardHeight = _cardHeight;
      final width = min(constraints.maxWidth - 32, 360.0);
      final problem = _problem;
      final travel = constraints.maxHeight - cardHeight - _shipSize - 12;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          // Your ship guards the ground.
          Positioned(
            bottom: 4,
            left: (constraints.maxWidth - _shipSize) / 2,
            child: Shake(
              trigger: _shake,
              child: Image.asset('assets/games/ship.png', width: _shipSize, height: _shipSize * 0.76),
            ),
          ),
          // Laser shot on a correct answer.
          if (_laser > 0)
            TweenAnimationBuilder<double>(
              key: ValueKey(_laser),
              tween: Tween(begin: 1, end: 0),
              duration: const Duration(milliseconds: 260),
              builder: (context, v, _) => Positioned(
                left: constraints.maxWidth / 2 - 5,
                top: _laserTop,
                bottom: _shipSize * 0.7,
                child: Opacity(
                  opacity: v,
                  child: Image.asset('assets/games/laser.png', width: 10, fit: BoxFit.fill),
                ),
              ),
            ),
          if (problem != null && _phase != _Phase.countdown)
            AnimatedBuilder(
              animation: _fall,
              builder: (context, child) => Positioned(
                top: _fall.value * travel,
                left: (constraints.maxWidth - width) / 2,
                width: width,
                height: cardHeight,
                child: child!,
              ),
              child: Shake(
                trigger: _shake,
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _fall,
                      builder: (context, child) => Transform.rotate(angle: _fall.value * pi, child: child),
                      child: Image.asset('assets/games/meteor_$_meteor.png', width: 96, height: 80),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GameColors.accent, width: 2),
                        boxShadow: [BoxShadow(color: GameColors.accent.withValues(alpha: 0.45), blurRadius: 18)],
                      ),
                      child: FittedBox(
                        child: Text(
                          problem.text,
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ParticleBurst(trigger: _burst, origin: _burstAt),
        ],
      );
    });
  }
  Widget _answers() {
    final problem = _problem;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      child: Row(
        children: [
          for (final option in problem?.options ?? const <int>[])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Builder(builder: (context) {
                  final wrong = _flashWrong == option;
                  return SizedBox(
                    height: 72,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: wrong ? GameColors.bad : GameColors.panel,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () => _answer(option),
                      child: FittedBox(
                        child: Text(
                          problem!.unit.isEmpty ? '$option' : '$option ${problem.unit}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
