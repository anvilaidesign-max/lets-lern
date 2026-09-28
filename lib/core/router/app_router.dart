import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/remote/supabase_service.dart';
import '../../data/repositories/settings_repository.dart';
import '../../features/ai_game/ai_game_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/card/card_screen.dart';
import '../../features/essay/essay_detail_screen.dart';
import '../../features/essay/essay_screen.dart';
import '../../features/games/games_hub_screen.dart';
import '../../features/games/memory_game_screen.dart';
import '../../features/games/number_rush_screen.dart';
import '../../features/games/rocket_quiz_screen.dart';
import '../../features/games/swipe_game_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/library/topic_items_screen.dart';
import '../../features/news/news_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/quiz/quick_quiz_screen.dart';
import '../../features/reader/chapter_quiz_screen.dart';
import '../../features/reader/chapter_reader_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/app_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(settingsProvider.select((s) => (s.onboardingDone, s.guestMode)), (_, _) => refresh.value++);
  ref.listen(authUserProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final settings = ref.read(settingsProvider);
      final signedIn = ref.read(supabaseServiceProvider).isSignedIn;
      final location = state.matchedLocation;
      if (!settings.onboardingDone) return location == '/onboarding' ? null : '/onboarding';
      if (location == '/login') return signedIn ? '/' : null;
      if (!signedIn && !settings.guestMode) return '/login';
      if (location == '/onboarding') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/news', builder: (context, state) => const NewsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) => const LibraryScreen(),
              routes: [
                GoRoute(
                  path: 'topic/:code',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => TopicItemsScreen(topicCode: state.pathParameters['code']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/progress', builder: (context, state) => const ProgressScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
          ]),
        ],
      ),
      GoRoute(
        path: '/card/:itemId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final answer = state.uri.queryParameters['answer'];
          return CardScreen(
            itemId: state.pathParameters['itemId']!,
            presetAnswer: answer == null ? null : answer == 'true',
          );
        },
      ),
      GoRoute(
        path: '/read/:chapterId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => ChapterReaderScreen(chapterId: state.pathParameters['chapterId']!),
        routes: [
          GoRoute(
            path: 'quiz',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => ChapterQuizScreen(chapterId: state.pathParameters['chapterId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/games',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const GamesHubScreen(),
        routes: [
          GoRoute(path: 'number-rush', parentNavigatorKey: rootNavigatorKey, builder: (context, state) => const NumberRushScreen()),
          GoRoute(path: 'swipe', parentNavigatorKey: rootNavigatorKey, builder: (context, state) => const SwipeGameScreen()),
          GoRoute(path: 'memory', parentNavigatorKey: rootNavigatorKey, builder: (context, state) => const MemoryGameScreen()),
          GoRoute(path: 'rocket', parentNavigatorKey: rootNavigatorKey, builder: (context, state) => const RocketQuizScreen()),
        ],
      ),
      GoRoute(path: '/profile', parentNavigatorKey: rootNavigatorKey, builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/quiz', parentNavigatorKey: rootNavigatorKey, builder: (context, state) => const QuickQuizScreen()),
      GoRoute(
        path: '/essay',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const EssayScreen(),
        routes: [
          GoRoute(
            path: ':id',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => EssayDetailScreen(essayId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(path: '/ai-game', parentNavigatorKey: rootNavigatorKey, builder: (context, state) => const AiGameScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('That page does not exist.')),
    ),
  );
  ref.onDispose(router.dispose);
  return router;
});
