import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/daos/content_dao.dart';
import '../../data/local/database.dart';
import '../../data/repositories/chapter_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/chapter.dart';
import 'game_kit.dart';

/// Rocket Quiz: answer to boost the rocket higher. Wrong answers and slow
/// answers cost fuel. Score is the altitude reached.
class RocketQuizScreen extends ConsumerStatefulWidget {
  const RocketQuizScreen({super.key});

  static const id = 'rocket';
  static const questionCount = 10;
  static const questionTime = Duration(seconds: 15);

  @override
  ConsumerState<RocketQuizScreen> createState() => _RocketQuizScreenState();
}

enum _Phase { loading, countdown, playing, over }

class _RocketQuizScreenState extends ConsumerState<RocketQuizScreen> with TickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this, duration: RocketQuizScreen.questionTime)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed && _phase == _Phase.playing && _chosen == null) _choose(-1);
    });
  late final AnimationController _flame = AnimationController(vsync: this, duration: const Duration(milliseconds: 140))..repeat(reverse: true);
  late final AnimationController _lift = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  _Phase _phase = _Phase.loading;
  List<QuizQuestion> _pool = const [];
  List<QuizQuestion> _questions = const [];
  int _index = 0;
  int? _chosen;
  int _altitude = 0;
  double _fuel = 1.0;
  int _correct = 0;
  int _shake = 0;
  int _burst = 0;
  bool _boosting = false;
  bool _record = false;
  int _best = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _clock.dispose();
    _flame.dispose();
    _lift.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final settings = ref.read(settingsProvider);
    final chapters = await ref.read(chapterRepositoryProvider).chaptersFor(settings.effectiveTopics);
    final pool = <QuizQuestion>[for (final c in chapters) ...c.quiz];
    if (pool.length < RocketQuizScreen.questionCount) {
      final items = await ContentDao(ref.read(databaseProvider)).activeForTopics(settings.effectiveTopics);
      for (final i in items.where((i) => i.isChallenge)) {
        pool.add(QuizQuestion(
          question: 'True or false: ${i.statement}',
          options: const ['True', 'False'],
          answerIndex: i.isTrue! ? 0 : 1,
          explanation: i.explanation ?? '',
        ));
      }
    }
    if (!mounted) return;
    setState(() {
      _pool = pool;
      _phase = pool.isEmpty ? _Phase.over : _Phase.countdown;
    });
  }

  void _start() {
    final questions = [..._pool]..shuffle(Random());
    setState(() {
      _questions = questions.take(RocketQuizScreen.questionCount).toList();
      _index = 0;
      _chosen = null;
      _altitude = 0;
      _fuel = 1.0;
      _correct = 0;
      _phase = _Phase.playing;
    });
    _clock.forward(from: 0);
  }

  Future<void> _choose(int option) async {
    if (_chosen != null || _phase != _Phase.playing) return;
    _clock.stop();
    final q = _questions[_index];
    final right = option == q.answerIndex;
    setState(() {
      _chosen = option;
      if (right) {
        _correct++;
        final speedBonus = ((1 - _clock.value) * 100).round();
        _altitude += 150 + speedBonus;
        _fuel = min(1.0, _fuel + 0.08);
        _boosting = true;
        _burst++;
      } else {
        _fuel = max(0.0, _fuel - 0.34);
        _shake++;
      }
    });
    right ? GameHaptics.good() : GameHaptics.bad();
    if (right) _lift.forward(from: 0);

    await Future<void>.delayed(Duration(milliseconds: right ? 1100 : 2200));
    if (!mounted) return;
    setState(() => _boosting = false);
    if (_fuel <= 0 || _index >= _questions.length - 1) {
      await _gameOver();
      return;
    }
    setState(() {
      _index++;
      _chosen = null;
    });
    _clock.forward(from: 0);
  }

  Future<void> _gameOver() async {
    setState(() => _phase = _Phase.over);
    final record = await recordGameResult(ref, RocketQuizScreen.id, _altitude);
    if (!mounted) return;
    setState(() {
      _record = record;
      _best = bestScore(ref, RocketQuizScreen.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _phase == _Phase.playing || (_phase == _Phase.over && _questions.isNotEmpty)
        ? _questions[min(_index, _questions.length - 1)]
        : null;
    return Scaffold(
      backgroundColor: GameColors.background,
      body: GameBackground(
        child: Stack(
          children: [
            StarField(speed: _boosting ? 0.9 : 0.05, count: 90),
            SafeArea(
              child: Column(
                children: [
                  GameHud(title: 'Rocket Quiz', score: _altitude, extra: _fuelGauge()),
                  if (q != null && _phase == _Phase.playing) _questionCard(q),
                  Expanded(child: _rocketArea()),
                  if (q != null && _phase == _Phase.playing) _options(q),
                ],
              ),
            ),
            if (_phase == _Phase.loading) const Center(child: CircularProgressIndicator(color: Colors.white)),
            if (_phase == _Phase.countdown) CountdownOverlay(onDone: _start),
            if (_phase == _Phase.over)
              ColoredBox(
                color: Colors.black54,
                child: _pool.isEmpty
                    ? const Center(child: Text('No questions yet for your topics.', style: TextStyle(color: Colors.white)))
                    : GameOverView(
                        score: _altitude,
                        best: max(_best, _altitude),
                        isRecord: _record,
                        stars: _correct >= 9 ? 3 : _correct >= 6 ? 2 : _correct >= 3 ? 1 : 0,
                        message: _fuel <= 0
                            ? 'Out of fuel at $_altitude m. $_correct correct.'
                            : 'Reached $_altitude m with $_correct of ${_questions.length} correct.',
                        onPlayAgain: () => setState(() => _phase = _Phase.countdown),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fuelGauge() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_gas_station, color: GameColors.muted, size: 18),
          const SizedBox(width: 4),
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: _fuel),
                duration: const Duration(milliseconds: 400),
                builder: (context, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 8,
                  backgroundColor: GameColors.panel,
                  color: v < 0.35 ? GameColors.bad : GameColors.gold,
                ),
              ),
            ),
          ),
        ],
      );

  Widget _questionCard(QuizQuestion q) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Shake(
          trigger: _shake,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: GameColors.panel.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Question ${_index + 1}/${_questions.length}', style: const TextStyle(color: GameColors.muted, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    AnimatedBuilder(
                      animation: _clock,
                      builder: (context, _) => SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          value: 1 - _clock.value,
                          strokeWidth: 4,
                          backgroundColor: Colors.white12,
                          color: _clock.value > 0.75 ? GameColors.bad : GameColors.good,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(q.question, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.3)),
                if (_chosen != null && q.explanation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    q.explanation,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _chosen == q.answerIndex ? GameColors.good : const Color(0xFFFCA5A5), fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ),
      );

  Widget _rocketArea() => LayoutBuilder(builder: (context, constraints) {
        final h = constraints.maxHeight;
        final w = constraints.maxWidth;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Planets drift down as the rocket climbs (parallax).
            TweenAnimationBuilder<double>(
              tween: Tween(end: _altitude.toDouble()),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (context, a, _) {
                double y(double speed, double phase) => ((a * speed + phase) % (h + 260)) - 200;
                return Stack(
                  children: [
                    Positioned(left: -40, top: y(0.35, 60), child: Opacity(opacity: 0.85, child: Image.asset('assets/games/planet_1.png', width: 150))),
                    Positioned(right: -30, top: y(0.22, h * 0.7), child: Opacity(opacity: 0.7, child: Image.asset('assets/games/planet_3.png', width: 110))),
                    Positioned(left: w * 0.55, top: y(0.5, h * 0.35), child: Opacity(opacity: 0.6, child: Image.asset('assets/games/planet_2.png', width: 70))),
                  ],
                );
              },
            ),
            AnimatedBuilder(
              animation: Listenable.merge([_flame, _lift]),
              builder: (context, _) {
                final lift = sin(_lift.value * pi) * 40;
                final bob = sin(DateTime.now().millisecondsSinceEpoch / 400) * 4;
                return Positioned(
                  left: w / 2 - 30,
                  top: h / 2 - 110 - lift + bob,
                  child: Column(
                    children: [
                      Image.asset('assets/games/rocket_1.png', height: 150, width: 60, fit: BoxFit.contain),
                      CustomPaint(
                        size: const Size(60, 80),
                        painter: _FlamePainter(flicker: _flame.value, boost: _boosting ? 1.0 : 0.35, fuel: _fuel),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              right: 16,
              top: 8,
              child: Text('$_altitude m', style: const TextStyle(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w800)),
            ),
            ParticleBurst(trigger: _burst, origin: Offset(w / 2, h / 2 + 60), color: GameColors.gold),
          ],
        );
      });
  Widget _options(QuizQuestion q) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            for (var i = 0; i < q.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      backgroundColor: _chosen == null
                          ? GameColors.panel
                          : i == q.answerIndex
                              ? GameColors.good
                              : i == _chosen
                                  ? GameColors.bad
                                  : GameColors.panel,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: i == q.answerIndex && _chosen != null
                          ? GameColors.good
                          : i == _chosen
                              ? GameColors.bad
                              : GameColors.panel.withValues(alpha: 0.6),
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _chosen == null ? () => _choose(i) : null,
                    child: Text(q.options[i], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
          ],
        ),
      );
}

/// Flickering rocket flame; longer when boosting, a sputter when out of fuel.
class _FlamePainter extends CustomPainter {
  _FlamePainter({required this.flicker, required this.boost, required this.fuel});
  final double flicker;
  final double boost;
  final double fuel;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final len = (20 + 55 * boost) * (0.85 + flicker * 0.3) * (fuel <= 0 ? 0.2 : 1);
    final outer = Path()
      ..moveTo(cx - 14, 0)
      ..quadraticBezierTo(cx, len * 1.25, cx + 14, 0)
      ..close();
    canvas.drawPath(outer, Paint()..color = const Color(0xFFF97316));
    final inner = Path()
      ..moveTo(cx - 7, 0)
      ..quadraticBezierTo(cx, len * 0.8, cx + 7, 0)
      ..close();
    canvas.drawPath(inner, Paint()..color = const Color(0xFFFDE047));
  }

  @override
  bool shouldRepaint(_FlamePainter old) => old.flicker != flicker || old.boost != boost || old.fuel != fuel;
}