import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OAuthProvider;

import '../../core/errors/app_exception.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../remote/connectivity_service.dart';
import '../remote/supabase_service.dart';

/// Google sign-in: native Google account picker, then the ID token is
/// exchanged with Supabase via `signInWithIdToken`.
class AuthRepository {
  AuthRepository(this._ref);

  final Ref _ref;
  static bool _googleInitialized = false;

  Future<Result<void>> signInWithGoogle() => Result.guard(() async {
        final env = _ref.read(envProvider);
        final client = _ref.read(supabaseServiceProvider).client;
        if (client == null) {
          throw const NotConfiguredException('Online features are not set up in this build. Use "Try offline first".');
        }
        if (!env.isGoogleConfigured) {
          throw const NotConfiguredException('Google sign-in is not set up yet. Use "Try offline first" for now.');
        }
        if (!await _ref.read(connectivityServiceProvider).isOnline()) {
          throw const OfflineException('You need internet the first time you sign in.');
        }

        final google = GoogleSignIn.instance;
        if (!_googleInitialized) {
          await google.initialize(
            serverClientId: env.googleWebClientId,
            clientId: Platform.isIOS && env.googleIosClientId.isNotEmpty ? env.googleIosClientId : null,
          );
          _googleInitialized = true;
        }

        final GoogleSignInAccount account;
        try {
          account = await google.authenticate();
        } on GoogleSignInException catch (e) {
          if (e.code == GoogleSignInExceptionCode.canceled) throw const CancelledException();
          AppLogger.warn('Google sign-in failed', e);
          throw AppAuthException('Google sign-in failed. Please try again.', e);
        }

        final idToken = account.authentication.idToken;
        if (idToken == null) throw const AppAuthException('Google did not return a sign-in token.');

        try {
          await client.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken);
        } catch (e) {
          AppLogger.warn('Supabase signInWithIdToken failed', e);
          throw AppAuthException('We could not sign you in. Please try again.', e);
        }
      }, context: 'signInWithGoogle');

  Future<void> signOut() async {
    try {
      await _ref.read(supabaseServiceProvider).client?.auth.signOut();
    } catch (e) {
      AppLogger.warn('Supabase sign out failed', e);
    }
    if (_googleInitialized) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref));
