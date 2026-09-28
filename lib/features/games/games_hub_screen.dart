import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/models/app_settings.dart';
import 'game_kit.dart';
import 'memory_game_screen.dart';
import 'number_rush_screen.dart';
import 'rocket_quiz_screen.dart';
import 'swipe_game_screen.dart';

class _GameInfo {
  const _GameInfo(this.id, this.title, this.subtitle, this.icon, this.colors, this.route, {this.unit = ''});
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final String route;
  final String unit;
}

const _games = [
  _GameInfo(NumberRushScreen.id, 'Falling Numbers', 'Stop the falling sums. Levels up to electronics formulas.', Icons.bolt,
      [Color(0xFF6366F1), Color(0xFF3B82F6)], '/games/number-rush'),
  _GameInfo(SwipeGameScreen.id, 'Swipe It', 'True or false? Swipe fast. 60 seconds, combos.', Icons.swipe,
      [Color(0xFF10B981), Color(0xFF059669)], '/games/swipe'),
  _GameInfo(MemoryGameScreen.id, 'Memory Match', 'Flip tiles to pair words with meanings.', Icons.grid_view_rounded,
      [Color(0xFF8B5CF6), Color(0xFFEC4899)], '/games/memory'),
  _GameInfo(RocketQuizScreen.id, 'Rocket Quiz', 'Answer to boost your rocket. Wrong answers burn fuel.', Icons.rocket_launch,
      [Color(0xFFF97316), Color(0xFFEF4444)], '/games/rocket', unit: ' m'),
];

/// All games in one place. They work offline and count towards the streak.
class GamesHubScreen extends ConsumerWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider); // refresh best scores after a game
    final notifier = ref.read(settingsProvider.notifier);
    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        backgroundColor: GameColors.background,
        foregroundColor: Colors.white,
        title: const Text('Games'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Learn by playing', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                    SizedBox(height: 4),
                    Text('Offline games built from your topics. Every game counts towards your streak.',
                        style: TextStyle(color: GameColors.muted, fontSize: 15)),
                  ],
                ),
              ),
              GameMascot(mood: MascotMood.cheer, size: 72),
            ],
          ),
          const SizedBox(height: 16),
          for (final g in _games) ...[
            _GameTile(info: g, best: int.tryParse(notifier.raw(SettingKeys.gameBest(g.id)) ?? '') ?? 0),
            const SizedBox(height: 12),
          ],
          _GameTile(
            info: const _GameInfo('ai', 'AI Tutor', 'Chat with an AI teacher: lessons, quizzes, true or false. Needs internet.',
                Icons.auto_awesome, [Color(0xFF0EA5E9), Color(0xFF6366F1)], '/ai-game'),
            best: null,
          ),
        ],
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({required this.info, required this.best});
  final _GameInfo info;
  final int? best;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(info.route),
        child: Ink(
          decoration: BoxDecoration(gradient: LinearGradient(colors: info.colors, begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                  child: Icon(info.icon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(info.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(info.subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                      if (best != null && best! > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.emoji_events, color: GameColors.gold, size: 16),
                            const SizedBox(width: 4),
                            Text('Best $best${info.unit}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
