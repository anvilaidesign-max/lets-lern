import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../remote/connectivity_service.dart';
import '../remote/edge_functions_api.dart';

enum GameMode {
  teach('teach', 'Teach me', 'A short lesson, then a question.'),
  quiz('quiz', 'Quiz', 'Multiple choice questions.'),
  trueFalse('true_false', 'True or false', 'Spot the fake statements.');

  const GameMode(this.apiValue, this.label, this.description);
  final String apiValue;
  final String label;
  final String description;
}

class AiGameTurn {
  const AiGameTurn({
    required this.sessionId,
    required this.aiMessage,
    required this.options,
    required this.score,
    required this.finished,
    required this.correct,
  });

  final String sessionId;
  final String aiMessage;
  final List<String>? options;
  final int score;
  final bool finished;
  final bool? correct;

  static AiGameTurn fromJson(Map<String, dynamic> json) {
    final message = json['ai_message'];
    final session = json['session_id'];
    if (message is! String || session is! String) {
      throw const ServerException('The game answer was not understood. Please try again.');
    }
    final options = json['options'];
    return AiGameTurn(
      sessionId: session,
      aiMessage: message,
      options: options is List ? options.whereType<String>().toList() : null,
      score: (json['score'] as num?)?.toInt() ?? 0,
      finished: json['finished'] == true,
      correct: json['correct'] is bool ? json['correct'] as bool : null,
    );
  }
}

/// AI learning game (ARCHITECTURE.md 9.4). Online only.
class AiGameRepository {
  AiGameRepository(this._ref);

  final Ref _ref;

  static const endMessage = '__end__';

  Future<Result<AiGameTurn>> turn({
    String? sessionId,
    required String topicCode,
    required GameMode mode,
    required String message,
  }) =>
      Result.guard(() async {
        if (!await _ref.read(connectivityServiceProvider).isOnline()) {
          throw const OfflineException('The AI game needs internet.');
        }
        final response = await _ref.read(edgeFunctionsApiProvider).call(
              'ai-game-turn',
              {
                'session_id': sessionId,
                'topic_code': topicCode,
                'mode': mode.apiValue,
                'user_message': message,
              },
              timeout: EdgeFunctionsApi.gameTimeout,
            );
        return AiGameTurn.fromJson(response);
      }, context: 'aiGameTurn');
}

final aiGameRepositoryProvider = Provider<AiGameRepository>((ref) => AiGameRepository(ref));
