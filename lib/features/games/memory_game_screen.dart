import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/daos/content_dao.dart';
import '../../data/local/database.dart';
import '../../domain/models/topic.dart';
import '../../domain/services/memory_pairs.dart';
import 'game_kit.dart';

/// Memory Match: flip tiles to pair each word with its meaning.
class MemoryGameScreen extends ConsumerStatefulWidget {
  const MemoryGameScreen({super.key});

  static const id = 'memory';
  static const pairCount = 6;

  @override
  ConsumerState<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

enum _Deck {
  mixed('Mixed', null),
  french('French', ['french']),
  english('English words', ['english']),
  stem('Science & tech', ['science', 'tech', 'engineering', 'medicine']),
  world('Money & world', ['economics', 'finance', 'business', 'politics', 'relations', 'law']);

  const _Deck(this.label, this.topics);
  final String label;
  final List<String>? topics;
}

class _Tile {
  _Tile(this.pairId, this.text, this.isTerm, this.topicCode);
  final String pairId;
  final String text;
  final bool isTerm;
  final String topicCode;
  bool matched = false;
}

enum _Phase { choose, countdown, playing, over }

class _MemoryGameScreenState extends ConsumerState<MemoryGameScreen> {
  _Deck _deck = _Deck.mixed;
  _Phase _phase = _Phase.choose;
  List<_Tile> _tiles = const [];
  final Set<int> _faceUp = {};
  int _moves = 0;
  int _burst = 0;
  Offset _burstAt = Offset.zero;
  bool _busy = false;
  final _watch = Stopwatch();
  int _score = 0;
  bool _record = false;
  int _best = 0;
  String? _error;

  Future<void> _prepare() async {
    final topics = _deck.topics ?? Topic.allCodes;
    final items = await ContentDao(ref.read(databaseProvider)).activeForTopics(topics);
    final pairs = buildMemoryPairs(items, MemoryGameScreen.pairCount, Random());
    if (!mounted) return;
    if (pairs.length < 3) {
      setState(() => _error = 'Not enough words in this deck yet. Try another deck.');
      return;
    }
    final tiles = [
      for (final p in pairs) ...[
        _Tile(p.id, p.term, true, p.topicCode),
        _Tile(p.id, p.meaning, false, p.topicCode),
      ],
    ]..shuffle(Random());
    setState(() {
      _tiles = tiles;
      _faceUp.clear();
      _moves = 0;
      _error = null;
      _phase = _Phase.countdown;
    });
  }

  void _start() {
    _watch
      ..reset()
      ..start();
    setState(() => _phase = _Phase.playing);
  }

  Future<void> _tap(int index, Offset center) async {
    if (_busy || _phase != _Phase.playing) return;
    final tile = _tiles[index];
    if (tile.matched || _faceUp.contains(index)) return;
    setState(() => _faceUp.add(index));
    if (_faceUp.length < 2) return;

    _busy = true;
    _moves++;
    final open = _faceUp.toList();
    final a = _tiles[open[0]], b = _tiles[open[1]];
    if (a.pairId == b.pairId && a.isTerm != b.isTerm) {
      GameHaptics.good();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      setState(() {
        a.matched = true;
        b.matched = true;
        _faceUp.clear();
        _burst++;
        _burstAt = center;
      });
      if (_tiles.every((t) => t.matched)) await _gameOver();
    } else {
      GameHaptics.bad();
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (mounted) setState(() => _faceUp.clear());
    }
    _busy = false;
  }

  Future<void> _gameOver() async {
    _watch.stop();
    final seconds = _watch.elapsed.inSeconds;
    final score = max(50, 1000 - seconds * 6 - max(0, _moves - MemoryGameScreen.pairCount) * 25);
    setState(() {
      _score = score;
      _phase = _Phase.over;
    });
    final record = await recordGameResult(ref, MemoryGameScreen.id, score);
    if (!mounted) return;
    setState(() {
      _record = record;
      _best = bestScore(ref, MemoryGameScreen.id);
    });
  }

  int get _stars {
    final extra = _moves - MemoryGameScreen.pairCount;
    return extra <= 3 ? 3 : extra <= 7 ? 2 : 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: GameBackground(
        child: Stack(
          children: [
            const StarField(speed: 0.01),
            SafeArea(
              child: Column(
                children: [
                  GameHud(
                    title: 'Memory Match',
                    score: _phase == _Phase.over ? _score : _tiles.where((t) => t.matched).length ~/ 2,
                    extra: _phase == _Phase.playing
                        ? Text('Moves $_moves', style: const TextStyle(color: GameColors.muted, fontWeight: FontWeight.w700))
                        : null,
                  ),
                  Expanded(child: _phase == _Phase.choose ? _chooser() : _grid()),
                ],
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
                  stars: _stars,
                  message: 'All pairs in $_moves moves and ${_watch.elapsed.inSeconds} s.',
                  onPlayAgain: () => setState(() => _phase = _Phase.choose),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chooser() => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(child: GameMascot(mood: MascotMood.idle, size: 84)),
          const SizedBox(height: 8),
          const Text('Pick a deck', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Flip two tiles at a time. Match each word with its meaning.', style: TextStyle(color: GameColors.muted, fontSize: 15)),
          const SizedBox(height: 20),
          for (final d in _Deck.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: d == _deck ? GameColors.accent : GameColors.panel,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _deck = d),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(d == _deck ? Icons.radio_button_checked : Icons.radio_button_off, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(d.label, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: GameColors.bad)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: GameColors.gold, foregroundColor: Colors.black),
              onPressed: _prepare,
              child: const Text('Start', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      );

  Widget _grid() => LayoutBuilder(builder: (context, constraints) {
        const columns = 3;
        final rows = (_tiles.length / columns).ceil();
        const gap = 10.0;
        final tileW = (constraints.maxWidth - 24 - gap * (columns - 1)) / columns;
        final tileH = min((constraints.maxHeight - 24 - gap * (rows - 1)) / rows, tileW * 1.2);
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (var i = 0; i < _tiles.length; i++)
                    Builder(builder: (tileContext) {
                      return GestureDetector(
                        onTap: () {
                          final box = tileContext.findRenderObject() as RenderBox?;
                          final stackBox = context.findRenderObject() as RenderBox?;
                          var center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
                          if (box != null && stackBox != null) {
                            center = stackBox.globalToLocal(box.localToGlobal(box.size.center(Offset.zero)));
                          }
                          _tap(i, center);
                        },
                        child: _FlipTile(
                          width: tileW,
                          height: tileH,
                          tile: _tiles[i],
                          faceUp: _tiles[i].matched || _faceUp.contains(i),
                        ),
                      );
                    }),
                ],
              ),
            ),
            ParticleBurst(trigger: _burst, origin: _burstAt, color: GameColors.good, count: 16),
          ],
        );
      });
}

class _FlipTile extends StatelessWidget {
  const _FlipTile({required this.width, required this.height, required this.tile, required this.faceUp});

  final double width;
  final double height;
  final _Tile tile;
  final bool faceUp;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: faceUp ? 1 : 0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
      builder: (context, t, _) {
        final showFront = t >= 0.5;
        final angle = t * pi;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(angle),
          child: showFront
              ? Transform(alignment: Alignment.center, transform: Matrix4.rotationY(pi), child: _front())
              : _back(),
        );
      },
    );
  }

  Widget _back() => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF312E81), Color(0xFF1E3A8A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: const Center(child: Text('?', style: TextStyle(color: Colors.white70, fontSize: 36, fontWeight: FontWeight.w900))),
      );

  Widget _front() => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: width,
        height: height,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: tile.matched ? const Color(0xFFDCFCE7) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tile.matched ? GameColors.good : (tile.isTerm ? GameColors.accent : const Color(0xFF8B5CF6)), width: 3),
          boxShadow: tile.matched ? [BoxShadow(color: GameColors.good.withValues(alpha: 0.5), blurRadius: 12)] : null,
        ),
        child: Center(
          child: Text(
            tile.text,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black,
              fontSize: tile.text.length > 24 ? 13 : 16,
              fontWeight: tile.isTerm ? FontWeight.w800 : FontWeight.w500,
              fontStyle: tile.isTerm ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ),
      );
}
