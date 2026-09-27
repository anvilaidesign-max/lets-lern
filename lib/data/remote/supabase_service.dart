import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';
import '../../core/utils/logger.dart';

final envProvider = Provider<Env>((ref) => Env.fromEnvironment());

/// Thin wrapper so the rest of the app works when Supabase is not configured
/// (offline-only builds) or not reachable.
class SupabaseService {
  SupabaseService(this.env);

  final Env env;
  static bool _initialized = false;

  bool get isAvailable => _initialized;

  SupabaseClient? get client => _initialized ? Supabase.instance.client : null;

  User? get currentUser => client?.auth.currentUser;

  String? get userId => currentUser?.id;

  bool get isSignedIn => currentUser != null;

  /// Safe to call more than once and from the background isolate.
  static Future<void> initialize(Env env) async {
    if (_initialized || !env.isSupabaseConfigured) return;
    try {
      await Supabase.initialize(url: env.supabaseUrl, publishableKey: env.supabaseAnonKey);
      _initialized = true;
    } catch (e, st) {
      AppLogger.error('Supabase.initialize failed', e, st);
    }
  }
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) => SupabaseService(ref.watch(envProvider)));

/// Emits the signed-in user (or null) and updates on sign in/out.
final authUserProvider = StreamProvider<User?>((ref) async* {
  final service = ref.watch(supabaseServiceProvider);
  final client = service.client;
  yield client?.auth.currentUser;
  if (client == null) return;
  await for (final state in client.auth.onAuthStateChange) {
    yield state.session?.user;
  }
});
