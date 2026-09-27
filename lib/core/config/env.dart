/// Build-time configuration, passed with `--dart-define` or
/// `--dart-define-from-file=env.json` (see env.example.json).
///
/// Only public values belong here. The Supabase anon key is public by design
/// and protected by Row Level Security. AI provider keys never reach the app.
class Env {
  const Env({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.googleWebClientId,
    required this.googleIosClientId,
  });

  factory Env.fromEnvironment() => const Env(
        supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
        supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
        googleWebClientId: String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
        googleIosClientId: String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
      );

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String googleWebClientId;
  final String googleIosClientId;

  /// Without Supabase the app still runs fully offline on the seed pack.
  bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  bool get isGoogleConfigured => googleWebClientId.isNotEmpty;
}
