import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/sync/sync_service.dart';
import '../../domain/models/app_settings.dart';
import '../common/widgets.dart';

/// "Continue with Google", or try offline first with the seed pack
/// (ARCHITECTURE.md 11.2 #2).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _busy = false;

  Future<void> _google() async {
    setState(() => _busy = true);
    final result = await ref.read(authRepositoryProvider).signInWithGoogle();
    if (!mounted) return;
    setState(() => _busy = false);
    result.when(
      success: (_) {
        ref.read(settingsProvider.notifier).set(SettingKeys.guestMode, 'false');
        ref.read(syncServiceProvider).run();
      },
      failure: (e) => showError(context, e),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guest = ref.watch(settingsProvider.select((s) => s.guestMode));
    return Scaffold(
      appBar: guest ? AppBar() : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),
              const Text('🧠', style: TextStyle(fontSize: 72)),
              const SizedBox(height: AppSpacing.lg),
              Text('Daily Mind', style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Sign in to keep your progress safe across phones and to use the AI game and essay scoring.',
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (_busy)
                const Padding(padding: EdgeInsets.all(AppSpacing.md), child: CircularProgressIndicator())
              else ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _google,
                    icon: const Text('G', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    label: const Text('Continue with Google'),
                  ),
                ),
                if (!guest) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => ref.read(settingsProvider.notifier).set(SettingKeys.guestMode, 'true'),
                      child: const Text('Try offline first'),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: AppSpacing.md),
              Text(
                'You can sign in later from Settings. Progress made offline is kept.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
