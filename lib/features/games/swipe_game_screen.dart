import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../data/local/daos/content_dao.dart';
import '../../data/local/database.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/content_item.dart';
import '../../domain/models/topic.dart';
import '../../domain/services/next_item_picker.dart';
import 'game_kit.dart';

/// Swipe It: true/false statements as a card stack. Swipe right for true,
/// left for false. 60 seconds, combos multiply points.
class SwipeGameScreen extends ConsumerStatefulWidget {
  const SwipeGameScreen({super.key});

  static const id = 'swipe';
  static const roundTime = Duration(seconds: 60);

  @override
  ConsumerState<SwipeGameScreen> createState() => _SwipeGameScreenState();
}

enum _Phase { loading, countdown, playing, over }

class _SwipeGameScreenState extends ConsumerState<SwipeGameScreen> with TickerProviderStateMixin {
  late final AnimationController _timer = AnimationController(vsync: this, duration: SwipeGameScreen.roundTime)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed && _phase == _Phase.playing) _gameOver();
    });
  late final AnimationController _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));

  _Phase _phase = _Phase.loading;
  List<ContentItem> _deck = const [];
  int _index = 0;
  Offset _drag = Offset.zero;
  Offset _flyFrom = Offset.zero;
  Offset _flyTo = Offset.zero;
  int _score = 0;
  int _combo = 0;
  int _correct = 0;
  int _answered = 0;
  int _shake = 0;
  int _burst = 0;
  String? _feedback;
  bool _feedbackGood = true;
  bool _record = false;
  int _best = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer.dispose();
    _fly.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final settings = ref.read(settingsProvider);
    final all = await ContentDao(ref.read(databaseProvider)).activeForTopics(settings.effectiveTopics);
    final challenges = filterByLevel(all.where((i) => i.isChallenge).toList(), settings.level)..shuffle(Random());
    if (!mounted) return;
    setState(() {
      _deck = challenges.take(80).toList();
      _phase = _deck.isEmpty ? _Phase.over : _Phase.countdown;
    });
  }

  void _start() {
    setState(() {
      _phase = _Phase.playing;
      _index = 0;
      _score = 0;
      _combo = 0;
      _correct = 0;
      _answered = 0;
      _drag = Offset.zero;
      _feedback = null;
      _deck.shuffle(Random());
    });
    _timer.forward(from: 0);
  }

  ContentItem? get _current => _index < _deck.length ? _deck[_index] : null;

  Future<void> _decide(bool saidTrue, Size size) async {
    final item = _current;
    if (item == null || _phase != _Phase.playing || _fly.isAnimating) return;
    final correct = saidTrue == item.isTrue;

    _flyFrom = _drag;
    _flyTo = Offset((saidTrue ? 1 : -1) * size.width * 1.4, _drag.dy + 80);
    _fly.forward(from: 0);

    setState(() {
      _answered++;
      if (correct) {
        _combo++;
        _correct++;
        final multiplier = 1 + _combo ~/ 4;
        _score += 10 * multiplier;
        _burst++;
        _feedback = multiplier > 1 ? 'Correct! x$multiplier' : 'Correct!';
        _feedbackGood = true;
      } else {
        _combo = 0;
        _shake++;
        _feedback = item.isTrue! ? 'It was TRUE' : 'False: ${item.correctAnswer ?? 'not true'}';
        _feedbackGood = false;
      }
    });
    correct ? GameHaptics.good() : GameHaptics.bad();
    ref.read(progressRepositoryProvider).recordAnswer(item, correct: correct);

    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    setState(() {
      _index++;
      _drag = Offset.zero;
      _fly.value = 0;
      if (_index >= _deck.length) _deck.shuffle(Random());
      if (_index >= _deck.length) _index = 0;
    });
    Future.delayed(Duration(milliseconds: correct ? 700 : 1600), () {
      if (mounted) setState(() => _feedback = null);
    });
  }

  Future<void> _gameOver() async {
    setState(() => _phase = _Phase.over);
    final record = await recordGameResult(ref, SwipeGameScreen.id, _score);
    if (!mounted) return;
    setState(() {
      _record = record;
      _best = bestScore(ref, SwipeGameScreen.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: GameBackground(
        child: Stack(
          children: [
            const StarField(speed: 0.015),
            SafeArea(
              child: Column(
                children: [
                  GameHud(title: 'Swipe It', score: _score),
                  _timerBar(),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 28,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _feedback == null
                          ? (_combo >= 3
                              ? Text('Combo $_combo 🔥', key: const ValueKey('combo'), style: const TextStyle(color: GameColors.gold, fontWeight: FontWeight.w800, fontSize: 16))
                              : const SizedBox.shrink())
                          : Text(
                              _feedback!,
                              key: ValueKey('$_feedback$_answered'),
                              style: TextStyle(
                                color: _feedbackGood ? GameColors.good : GameColors.bad,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  Expanded(child: _cardArea()),
                  _buttons(),
                ],
              ),
            ),
            if (_phase == _Phase.loading) const Center(child: CircularProgressIndicator(color: Colors.white)),
            if (_phase == _Phase.countdown) CountdownOverlay(onDone: _start),
            if (_phase == _Phase.over)
              ColoredBox(
                color: Colors.black54,
                child: _deck.isEmpty
                    ? const Center(child: Text('No true/false cards yet for your topics.', style: TextStyle(color: Colors.white)))
                    : GameOverView(
                        score: _score,
                        best: max(_best, _score),
                        isRecord: _record,
                        stars: _score >= 300 ? 3 : _score >= 160 ? 2 : _score >= 60 ? 1 : 0,
                        message: '$_correct of $_answered correct.',
                        onPlayAgain: () => setState(() => _phase = _Phase.countdown),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _timerBar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AnimatedBuilder(
          animation: _timer,
          builder: (context, _) {
            final left = 1 - _timer.value;
            final seconds = (SwipeGameScreen.roundTime.inSeconds * left).ceil();
            return Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: left,
                      minHeight: 10,
                      backgroundColor: GameColors.panel,
                      color: left < 0.2 ? GameColors.bad : GameColors.good,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${seconds}s', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ],
            );
          },
        ),
      );

  Widget _cardArea() => LayoutBuilder(builder: (context, constraints) {
        final size = constraints.biggest;
        final item = _current;
        final next = _deck.isEmpty ? null : _deck[(_index + 1) % _deck.length];
        return Stack(
          alignment: Alignment.center,
          children: [
            if (next != null && _phase != _Phase.loading)
              Transform.scale(scale: 0.92, child: Opacity(opacity: 0.55, child: _StatementCard(item: next, size: size))),
            if (item != null && _phase != _Phase.loading)
              AnimatedBuilder(
                animation: _fly,
                builder: (context, child) {
                  final offset = _fly.isAnimating || _fly.value > 0 ? Offset.lerp(_flyFrom, _flyTo, Curves.easeIn.transform(_fly.value))! : _drag;
                  return Transform.translate(
                    offset: offset,
                    child: Transform.rotate(angle: offset.dx / size.width * 0.5, child: child),
                  );
                },
                child: GestureDetector(
                  onPanUpdate: _phase == _Phase.playing ? (d) => setState(() => _drag += d.delta) : null,
                  onPanEnd: _phase == _Phase.playing
                      ? (d) {
                          final vx = d.velocity.pixelsPerSecond.dx;
                          if (_drag.dx.abs() > size.width * 0.22 || vx.abs() > 900) {
                            _decide((_drag.dx + vx * 0.1) > 0, size);
                          } else {
                            setState(() => _drag = Offset.zero);
                          }
                        }
                      : null,
                  child: Shake(
                    trigger: _shake,
                    child: _StatementCard(item: item, size: size, drag: _drag.dx / (size.width * 0.3)),
                  ),
                ),
              ),
            ParticleBurst(trigger: _burst, origin: Offset(size.width / 2, size.height / 2), color: GameColors.good),
            Positioned(
              left: 4,
              bottom: 0,
              child: IgnorePointer(
                child: GameMascot(
                  size: 64,
                  mood: _feedback == null ? MascotMood.idle : (_feedbackGood ? MascotMood.cheer : MascotMood.hurt),
                ),
              ),
            ),
          ],
        );
      });

  Widget _buttons() => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: LayoutBuilder(builder: (context, c) {
          final size = Size(c.maxWidth, 400);
          return Row(
            children: [
              Expanded(
                child: _RoundButton(
                  label: 'False',
                  icon: Icons.close_rounded,
                  color: GameColors.bad,
                  onTap: _phase == _Phase.playing ? () => _decide(false, size) : null,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _RoundButton(
                  label: 'True',
                  icon: Icons.check_rounded,
                  color: GameColors.good,
                  onTap: _phase == _Phase.playing ? () => _decide(true, size) : null,
                ),
              ),
            ],
          );
        }),
      );
}

class _StatementCard extends StatelessWidget {
  const _StatementCard({required this.item, required this.size, this.drag = 0});

  final ContentItem item;
  final Size size;

  /// -1 (full left) to 1 (full right).
  final double drag;

  @override
  Widget build(BuildContext context) {
    final width = min(size.width - 48, 380.0);
    final color = AppColors.forTopic(item.topicCode);
    final right = drag.clamp(0.0, 1.0);
    final left = (-drag).clamp(0.0, 1.0);
    return Container(
      width: width,
      height: min(size.height - 24, 360.0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 24, offset: Offset(0, 12))],
        border: Border.all(
          width: 4,
          color: Color.lerp(Color.lerp(Colors.white, GameColors.good, right)!, GameColors.bad, left)!,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Topic.byCode(item.topicCode)?.icon, color: color, size: 18),
                  const SizedBox(width: 6),
                  Text(Topic.shortNameOf(item.topicCode).toUpperCase(),
                      style: TextStyle(color: color, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ],
              ),
              const Spacer(),
              Text(
                item.statement ?? '',
                style: const TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.w700, height: 1.25),
              ),
              const Spacer(),
              const Text('True or false?', style: TextStyle(color: Colors.black54, fontSize: 15)),
            ],
          ),
          Positioned(top: 30, right: 0, child: _Stamp(text: 'TRUE', color: GameColors.good, opacity: right)),
          Positioned(top: 30, left: 0, child: _Stamp(text: 'FALSE', color: GameColors.bad, opacity: left)),
        ],
      ),
    );
  }
}

class _Stamp extends StatelessWidget {
  const _Stamp({required this.text, required this.color, required this.opacity});
  final String text;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: text == 'TRUE' ? 0.3 : -0.3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: color, width: 3), borderRadius: BorderRadius.circular(8)),
            child: Text(text, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w900)),
          ),
        ),
      );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.label, required this.icon, required this.color, required this.onTap});
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 64,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
          onPressed: onTap,
          icon: Icon(icon, size: 28),
          label: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ),
      );
}
