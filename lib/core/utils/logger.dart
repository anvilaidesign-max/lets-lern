import 'dart:collection';

import 'package:flutter/foundation.dart';

/// Small logger that keeps the last 200 lines in memory (shown in
/// Settings > About for bug reports). Plug Sentry in here later if wanted.
class AppLogger {
  AppLogger._();

  static final Queue<String> _recent = Queue<String>();
  static const int _max = 200;

  static List<String> get recent => List.unmodifiable(_recent);

  static void info(String message) => _add('INFO', message);

  static void warn(String message, [Object? error]) =>
      _add('WARN', error == null ? message : '$message: $error');

  static void error(String message, Object error, [StackTrace? stack]) {
    _add('ERROR', '$message: $error');
    if (stack != null && kDebugMode) debugPrint(stack.toString());
  }

  static void _add(String level, String message) {
    final line = '${DateTime.now().toIso8601String()} [$level] $message';
    _recent.addLast(line);
    while (_recent.length > _max) {
      _recent.removeFirst();
    }
    if (kDebugMode) debugPrint(line);
  }
}
