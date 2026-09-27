import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/logger.dart';
import 'supabase_service.dart';

/// Calls Supabase Edge Functions with a timeout, one retry with backoff on
/// network errors, and friendly error mapping (ARCHITECTURE.md 1.6, 13.4).
/// The app never calls AI providers directly.
class EdgeFunctionsApi {
  EdgeFunctionsApi(this._supabase);

  final SupabaseService _supabase;

  static const essayTimeout = Duration(seconds: 150);
  static const gameTimeout = Duration(seconds: 75);
  static const contentTimeout = Duration(seconds: 45);

  Future<Map<String, dynamic>> call(
    String name,
    Map<String, dynamic> body, {
    Duration timeout = contentTimeout,
  }) async {
    final client = _supabase.client;
    if (client == null) throw const NotConfiguredException('Online features are not set up in this build.');
    if (client.auth.currentUser == null) throw const AppAuthException();

    for (var attempt = 0; ; attempt++) {
      try {
        final response = await client.functions.invoke(name, body: body).timeout(timeout);
        final data = response.data;
        if (data is Map<String, dynamic>) return data;
        if (data is Map) return Map<String, dynamic>.from(data);
        throw const ServerException();
      } on FunctionException catch (e) {
        throw _mapFunctionError(e);
      } on TimeoutException {
        throw const TimeoutAppException();
      } on SocketException catch (e) {
        if (attempt == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 800));
          continue;
        }
        throw NetworkException('We could not reach the server. Check your connection.', e);
      } on AppException {
        rethrow;
      } catch (e) {
        final text = e.toString();
        final looksLikeNetwork = text.contains('ClientException') || text.contains('Connection') || text.contains('Failed host lookup');
        if (looksLikeNetwork && attempt == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 800));
          continue;
        }
        AppLogger.error('Edge function $name failed', e);
        throw looksLikeNetwork ? NetworkException('We could not reach the server.', e) : UnknownException('Something went wrong.', e);
      }
    }
  }

  AppException _mapFunctionError(FunctionException e) {
    final details = e.details;
    final message = details is Map && details['message'] is String ? details['message'] as String : null;
    AppLogger.warn('Edge function error ${e.status}', details);
    return switch (e.status) {
      401 => AppAuthException(message ?? 'Please sign in again.'),
      404 => NotFoundException(message ?? 'We could not find that.'),
      429 => RateLimitException(message ?? 'You have reached today\'s limit. Try again tomorrow.'),
      400 || 422 => ValidationException(message ?? 'That request was not valid.'),
      503 => NotConfiguredException(message ?? 'This feature is not set up yet.'),
      504 => const TimeoutAppException(),
      _ => ServerException(message ?? 'Something went wrong on our side. Please try again later.'),
    };
  }
}

final edgeFunctionsApiProvider = Provider<EdgeFunctionsApi>(
  (ref) => EdgeFunctionsApi(ref.watch(supabaseServiceProvider)),
);
