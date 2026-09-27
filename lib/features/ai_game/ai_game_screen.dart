import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../data/remote/connectivity_service.dart';
import '../../data/remote/supabase_service.dart';
import '../../data/repositories/ai_game_repository.dart';
import '../../domain/models/topic.dart';
import '../common/widgets.dart';
import '../home/home_providers.dart';

class _Message {
  const _Message({required this.fromAi, required this.text, this.correct});
  final bool fromAi;
  final String text;
  final bool? correct;
}

/// Chat-style AI game (ARCHITECTURE.md 9.4, 11.2 #8). Online only; offline it
/// offers the offline quick quiz instead.
class AiGameScreen extends ConsumerStatefulWidget {
  const AiGameScreen({super.key});

  @override
  ConsumerState<AiGameScreen> createState() => _AiGameScreenState();
}

class _AiGameScreenState extends ConsumerState<AiGameScreen> {
  String? _topic;
  GameMode _mode = GameMode.trueFalse;
  String? _sessionId;
  final _messages = <_Message>[];
  List<String>? _options;
  int _score = 0;
  bool _finished = false;
  bool _waiting = false;
  final _input = TextEditingController();
  final _scroll = ScrollController();

  bool get _started => _sessionId != null || _waiting && _messages.isEmpty;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text, {bool showAsUser = true}) async {
    final topic = _topic ?? ref.read(todayTopicsProvider).value?.first ?? 'science';
    setState(() {
      _topic = topic;
      if (showAsUser && text.isNotEmpty && text != AiGameRepository.endMessage) {
        _messages.add(_Message(fromAi: false, text: text));
      }
      _options = null;
      _waiting = true;
    });
    _scrollDown();
    final result = await ref.read(aiGameRepositoryProvider).turn(
          sessionId: _sessionId,
          topicCode: topic,
          mode: _mode,
          message: text,
        );
    if (!mounted) return;
    result.when(
      success: (turn) => setState(() {
        _sessionId = turn.sessionId;
        _messages.add(_Message(fromAi: true, text: turn.aiMessage, correct: turn.correct));
        _options = turn.options;
        _score = turn.score;
        _finished = turn.finished;
        _waiting = false;
      }),
      failure: (e) {
        setState(() => _waiting = false);
        showError(context, e);
      },
    );
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent + 200, duration: AppDurations.normal, curve: Curves.easeOut);
      }
    });
  }

  void _reset() => setState(() {
        _sessionId = null;
        _messages.clear();
        _options = null;
        _score = 0;
        _finished = false;
      });

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(isOnlineProvider).value ?? true;
    final signedIn = ref.watch(authUserProvider).value != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_started ? 'Score: $_score' : 'AI game'),
        actions: [
          if (_sessionId != null && !_finished)
            TextButton(onPressed: _waiting ? null : () => _send(AiGameRepository.endMessage, showAsUser: false), child: const Text('End')),
        ],
      ),
      body: SafeArea(
        child: !online
            ? EmptyState(
                icon: Icons.wifi_off,
                title: 'The AI game needs internet',
                message: 'You can still practise with an offline quiz.',
                action: FilledButton(onPressed: () => context.pushReplacement('/quiz'), child: const Text('Do an offline quiz')),
              )
            : !signedIn
                ? EmptyState(
                    icon: Icons.lock_outline,
                    title: 'Sign in to play',
                    message: 'The AI game needs an account so your games stay private.',
                    action: FilledButton(onPressed: () => context.push('/login'), child: const Text('Sign in')),
                  )
                : !_started
                    ? _Setup(
                        topic: _topic ?? ref.watch(todayTopicsProvider).value?.first,
                        mode: _mode,
                        onTopic: (t) => setState(() => _topic = t),
                        onMode: (m) => setState(() => _mode = m),
                        onStart: () => _send('', showAsUser: false),
                      )
                    : _chat(context),
      ),
    );
  }

  Widget _chat(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: _messages.length + (_waiting ? 1 : 0),
            itemBuilder: (context, i) {
              if (i >= _messages.length) {
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                );
              }
              final m = _messages[i];
              return Align(
                alignment: m.fromAi ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: m.fromAi ? theme.colorScheme.surfaceContainer : theme.colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    m.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: m.fromAi ? theme.colorScheme.onSurface : theme.colorScheme.surface,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_finished)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(width: double.infinity, child: FilledButton(onPressed: _reset, child: const Text('New game'))),
          )
        else ...[
          if (_options != null && !_waiting)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final o in _options!)
                    OutlinedButton(
                      onPressed: () => _send(o),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(64, 44)),
                      child: Text(o),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    enabled: !_waiting,
                    textInputAction: TextInputAction.send,
                    maxLength: 500,
                    decoration: const InputDecoration(hintText: 'Type an answer or question', counterText: ''),
                    onSubmitted: (text) {
                      if (text.trim().isEmpty) return;
                      _input.clear();
                      _send(text.trim());
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filled(
                  tooltip: 'Send',
                  onPressed: _waiting
                      ? null
                      : () {
                          final text = _input.text.trim();
                          if (text.isEmpty) return;
                          _input.clear();
                          _send(text);
                        },
                  icon: const Icon(Icons.arrow_upward),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Setup extends StatelessWidget {
  const _Setup({
    required this.topic,
    required this.mode,
    required this.onTopic,
    required this.onMode,
    required this.onStart,
  });

  final String? topic;
  final GameMode mode;
  final ValueChanged<String> onTopic;
  final ValueChanged<GameMode> onMode;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Play with your AI tutor', style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Pick a topic and a game. Your tutor teaches, asks and keeps score. 10 questions per game.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SectionTitle('Topic'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final t in Topic.all) TopicChip(code: t.code, selected: t.code == topic, onTap: () => onTopic(t.code)),
          ],
        ),
        const SectionTitle('Game'),
        for (final m in GameMode.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              onTap: () => onMode(m),
              color: m == mode ? theme.colorScheme.surfaceContainer : null,
              child: Row(
                children: [
                  Icon(m == mode ? Icons.radio_button_checked : Icons.radio_button_off),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.label, style: theme.textTheme.titleMedium),
                        Text(m.description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(onPressed: onStart, child: const Text('Start')),
      ],
    );
  }
}
