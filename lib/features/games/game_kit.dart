import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/app_settings.dart';

/// Shared look and pieces for the arcade games: dark playfield, bright
/// accents, HUD, 3-2-1 countdown, particle bursts, shake and game over.
class GameColors {
  GameColors._();

  static const background = Color(0xFF0B1020);
  static const backgroundTop = Color(0xFF1B2450);
  static const panel = Color(0xFF18203F);
  static const accent = Color(0xFF3B82F6);
  static const good = Color(0xFF22C55E);
  static const bad = Color(0xFFEF4444);
  static const gold = Color(0xFFFBBF24);
  static const text = Colors.white;
  static const muted = Color(0xFF9AA4C7);
}

/// Saves the best score per game and counts a finished game towards today's
/// streak. Returns true when this is a new record.
Future<bool> recordGameResult(WidgetRef ref, String gameId, int score) async {
  final notifier = ref.read(settingsProvider.notifier);
  final key = SettingKeys.gameBest(gameId);
  final best = int.tryParse(notifier.raw(key) ?? '') ?? 0;
  final record = score > best;
  if (record) await notifier.set(key, '$score');
  if (score > 0) await ref.read(progressRepositoryProvider).completeActivity('game:$gameId');
  return record;
}

int bestScore(WidgetRef ref, String gameId) =>
    int.tryParse(ref.read(settingsProvider.notifier).raw(SettingKeys.gameBest(gameId)) ?? '') ?? 0;

/// Space playfield used by every game: a tiled starry background (Kenney,
/// CC0) under a dark gradient.
class GameBackground extends StatelessWidget {
  const GameBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          color: GameColors.background,
          image: DecorationImage(
            image: AssetImage('assets/games/bg_space.png'),
            repeat: ImageRepeat.repeat,
            opacity: 0.55,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [GameColors.backgroundTop.withValues(alpha: 0.75), GameColors.background.withValues(alpha: 0.85)],
            ),
          ),
          child: child,
        ),
      );
}

enum MascotMood { idle, cheer, hurt, think }

/// The robot mascot (Kenney Toon Characters, CC0). Cheering alternates two
/// frames and bounces; hurt shakes.
class GameMascot extends StatefulWidget {
  const GameMascot({super.key, this.mood = MascotMood.idle, this.size = 96});
  final MascotMood mood;
  final double size;

  @override
  State<GameMascot> createState() => _GameMascotState();
}

class _GameMascotState extends State<GameMascot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        String frame;
        Offset offset = Offset.zero;
        switch (widget.mood) {
          case MascotMood.cheer:
            frame = t < 0.5 ? 'cheer0' : 'cheer1';
            offset = Offset(0, -sin(t * pi) * widget.size * 0.12);
          case MascotMood.hurt:
            frame = 'hurt';
            offset = Offset(sin(t * pi * 8) * 4, 0);
          case MascotMood.think:
            frame = 'think';
            offset = Offset(0, sin(t * 2 * pi) * 2);
          case MascotMood.idle:
            frame = 'idle';
            offset = Offset(0, sin(t * 2 * pi) * 3);
        }
        return Transform.translate(
          offset: offset,
          child: Image.asset(
            'assets/games/mascot_$frame.png',
            width: widget.size,
            height: widget.size * 4 / 3,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
          ),
        );
      },
    );
  }
}
/// Top bar: close, title, score and an optional extra (lives, timer).
class GameHud extends StatelessWidget {
  const GameHud({super.key, required this.title, required this.score, this.extra, this.onClose});

  final String title;
  final int score;
  final Widget? extra;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Quit game',
            onPressed: onClose ?? () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close, color: GameColors.text),
          ),
          Expanded(
            child: Text(title, style: const TextStyle(color: GameColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          ?extra,
          const SizedBox(width: 12),
          ScorePill(score: score),
        ],
      ),
    );
  }
}

/// Score that pops when it changes.
class ScorePill extends StatelessWidget {
  const ScorePill({super.key, required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(score),
      tween: Tween(begin: 1.35, end: 1.0),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: GameColors.panel, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: GameColors.gold, size: 18),
            const SizedBox(width: 4),
            Text('$score', style: const TextStyle(color: GameColors.text, fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class HeartsRow extends StatelessWidget {
  const HeartsRow({super.key, required this.lives, this.max = 3});
  final int lives;
  final int max;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < max; i++)
            AnimatedScale(
              scale: i < lives ? 1 : 0.7,
              duration: const Duration(milliseconds: 250),
              child: Icon(
                i < lives ? Icons.favorite : Icons.favorite_border,
                color: i < lives ? GameColors.bad : GameColors.muted,
                size: 20,
              ),
            ),
        ],
      );
}

/// Full-screen 3, 2, 1, Go! overlay. Calls [onDone] when finished.
class CountdownOverlay extends StatefulWidget {
  const CountdownOverlay({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))
    ..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value * 4; // 3, 2, 1, Go
        final step = t.floor().clamp(0, 3);
        final local = t - step;
        final label = const ['3', '2', '1', 'Go!'][step];
        return ColoredBox(
          color: Colors.black.withValues(alpha: 0.35 * (1 - _c.value)),
          child: Center(
            child: Opacity(
              opacity: (1 - local).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.6 + local * 0.9,
                child: Text(
                  label,
                  style: TextStyle(
                    color: step == 3 ? GameColors.gold : GameColors.text,
                    fontSize: 96,
                    fontWeight: FontWeight.w900,
                    shadows: const [Shadow(blurRadius: 24, color: Colors.black54)],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Particle burst at a point. Change [trigger] to fire a new burst.
class ParticleBurst extends StatefulWidget {
  const ParticleBurst({super.key, required this.trigger, required this.origin, this.color = GameColors.gold, this.count = 22});

  final int trigger;
  final Offset origin;
  final Color color;
  final int count;

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _Particle {
  _Particle(this.angle, this.speed, this.size, this.color);
  final double angle;
  final double speed;
  final double size;
  final Color color;
}

class _ParticleBurstState extends State<ParticleBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
  final _random = Random();
  List<_Particle> _particles = const [];

  @override
  void didUpdateWidget(ParticleBurst old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger && widget.trigger > 0) {
      final palette = [widget.color, GameColors.text, GameColors.accent, GameColors.good];
      _particles = [
        for (var i = 0; i < widget.count; i++)
          _Particle(
            _random.nextDouble() * 2 * pi,
            80 + _random.nextDouble() * 180,
            3 + _random.nextDouble() * 4,
            palette[_random.nextInt(palette.length)],
          ),
      ];
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _BurstPainter(_particles, widget.origin, _c.value),
          ),
        ),
      );
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.particles, this.origin, this.t);
  final List<_Particle> particles;
  final Offset origin;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t == 0 || t == 1) return;
    final ease = Curves.easeOutCubic.transform(t);
    for (final p in particles) {
      final d = p.speed * ease;
      final pos = origin + Offset(cos(p.angle) * d, sin(p.angle) * d + 60 * t * t);
      canvas.drawCircle(pos, p.size * (1 - t * 0.6), Paint()..color = p.color.withValues(alpha: 1 - t));
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t || old.particles != particles;
}

/// Shakes its child when [trigger] changes (wrong answers).
class Shake extends StatefulWidget {
  const Shake({super.key, required this.trigger, required this.child});
  final int trigger;
  final Widget child;

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void didUpdateWidget(Shake old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger && widget.trigger > 0) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.translate(
          offset: Offset(sin(_c.value * pi * 6) * 12 * (1 - _c.value), 0),
          child: child,
        ),
        child: widget.child,
      );
}

/// End of game: score, stars, best score, play again.
class GameOverView extends StatelessWidget {
  const GameOverView({
    super.key,
    required this.score,
    required this.best,
    required this.isRecord,
    required this.stars,
    required this.onPlayAgain,
    this.message,
  });

  final int score;
  final int best;
  final bool isRecord;
  final int stars;
  final VoidCallback onPlayAgain;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.7, end: 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutBack,
        builder: (context, s, child) => Transform.scale(scale: s, child: child),
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: GameColors.panel, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GameMascot(mood: stars >= 2 ? MascotMood.cheer : MascotMood.think, size: 72),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 400 + i * 200),
                      curve: Curves.elasticOut,
                      builder: (context, v, _) => Transform.scale(
                        scale: v,
                        child: Icon(
                          i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: i == 1 ? 64 : 48,
                          color: i < stars ? GameColors.gold : GameColors.muted,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (isRecord)
                const Text('NEW RECORD!', style: TextStyle(color: GameColors.gold, fontWeight: FontWeight.w900, letterSpacing: 2)),
              Text('$score', style: const TextStyle(color: GameColors.text, fontSize: 56, fontWeight: FontWeight.w900)),
              Text('Best: $best', style: const TextStyle(color: GameColors.muted, fontSize: 16)),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(message!, textAlign: TextAlign.center, style: const TextStyle(color: GameColors.text, fontSize: 15)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: GameColors.accent, foregroundColor: Colors.white),
                  onPressed: onPlayAgain,
                  child: const Text('Play again'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Back to games', style: TextStyle(color: GameColors.muted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Short haptic ticks; ignored on devices without a vibrator.
class GameHaptics {
  GameHaptics._();
  static void good() => HapticFeedback.lightImpact();
  static void bad() => HapticFeedback.heavyImpact();
}

/// Drifting starfield. [speed] is in screen heights per second.
class StarField extends StatefulWidget {
  const StarField({super.key, this.speed = 0.04, this.count = 70});
  final double speed;
  final int count;

  @override
  State<StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarField> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  final _random = Random(7);
  late final List<Offset> _stars = [for (var i = 0; i < widget.count; i++) Offset(_random.nextDouble(), _random.nextDouble())];
  late final List<double> _sizes = [for (var i = 0; i < widget.count; i++) 0.6 + _random.nextDouble() * 1.8];
  double _offset = 0;
  Duration? _last;

  @override
  void initState() {
    super.initState();
    _c.addListener(() {
      final now = _c.lastElapsedDuration;
      if (now == null) return;
      final dt = _last == null ? 0.0 : (now - _last!).inMicroseconds / 1e6;
      _last = now;
      setState(() => _offset = (_offset + dt.abs() * widget.speed) % 1.0);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: CustomPaint(size: Size.infinite, painter: _StarPainter(_stars, _sizes, _offset)),
      );
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.stars, this.sizes, this.offset);
  final List<Offset> stars;
  final List<double> sizes;
  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var i = 0; i < stars.length; i++) {
      final s = stars[i];
      final y = ((s.dy + offset * (0.5 + sizes[i] / 2.4)) % 1.0) * size.height;
      paint.color = Colors.white.withValues(alpha: 0.25 + sizes[i] / 4);
      canvas.drawCircle(Offset(s.dx * size.width, y), sizes[i], paint);
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.offset != offset;
}