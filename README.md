# Daily Mind

Short learning moments instead of endless scrolling: facts, words, true or false challenges, a handwritten essay scored by AI, an AI tutor game, and brain break reminders. Flutter + Supabase, offline first.

The full specification is in [ARCHITECTURE.md](ARCHITECTURE.md). Where the build differs from it, and why, is in [CHANGES.md](CHANGES.md).

## Project layout

```
lib/                 Flutter app (core, data, domain, features, platform)
packages/screen_time Android UsageStatsManager plugin (Kotlin)
assets/seed/         Offline seed pack (329 items, generated)
supabase/            SQL migrations + Edge Functions (score-essay, ai-game-turn, get-content-updates)
content-pipeline/    Content files, schema, validate / check-links / upload / export-seed scripts
test/                Unit and integration tests
```

## Run the app

1. Copy `env.example.json` to `env.json` and fill in the values. `env.json` is gitignored.
   - `SUPABASE_URL`, `SUPABASE_ANON_KEY`: public by design and protected by Row Level Security.
   - `GOOGLE_WEB_CLIENT_ID`: the **Web** OAuth client ID (see Google sign-in below).
2. Run it:

```sh
flutter pub get
flutter run --dart-define-from-file=env.json
flutter build apk --release --dart-define-from-file=env.json
```

Without `env.json` the app still works fully offline on the seed pack.

> **Folder name:** the apostrophe in `lets learn'` breaks `flutter test` on Windows. Rename the folder, for example to `lets-learn`.

## Google sign-in setup

1. In Google Cloud Console, create an OAuth consent screen, then these OAuth clients:
   - **Android**: package `com.dailymind.daily_mind`, plus the SHA-1 of your signing key. Get it with `keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android` (and the release keystore later).
   - **Web application**: its client ID goes in `env.json` as `GOOGLE_WEB_CLIENT_ID`.
   - **iOS** (when building for iOS): put its client ID in `GOOGLE_IOS_CLIENT_ID`, and add `GIDClientID` plus the reversed client ID URL scheme to `ios/Runner/Info.plist`.
2. In Supabase: **Authentication → Sign In / Providers → Google**. Enable it and enter the **Web** client ID and secret. Add the Android and iOS client IDs to "Client IDs" (comma separated) so native ID tokens are accepted.

## Backend (Supabase)

Already deployed to project `piieduhkrnrcwfgxwypz`: both migrations, the three functions and the secrets. To redeploy:

```sh
# Apply migrations (Supabase CLI linked to the project)
npx supabase db push
# Deploy functions
npx supabase functions deploy score-essay --use-api
npx supabase functions deploy ai-game-turn --use-api
npx supabase functions deploy get-content-updates --use-api
# Secrets (server only, never in the app)
npx supabase secrets set DEEPSEEK_API_KEY=... DEEPSEEK_MODEL=deepseek-flash VISION_PROVIDER=deepseek VISION_MODEL=deepseek-flash
```

Optional secrets: `DEEPSEEK_THINKING=enabled`, `VISION_API_KEY`, `VISION_FALLBACK_PROVIDER` / `VISION_FALLBACK_MODEL` / `VISION_FALLBACK_API_KEY` (providers: `deepseek`, `together`, `openai`, `gemini`), and `TOGETHER_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`.

## Content pipeline

Needs Node 22.18+ and has no dependencies. Put `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` in `content-pipeline/.env` (gitignored, never commit it).

```sh
cd content-pipeline
node scripts/validate.ts          # schema, lengths, sources, duplicates, arithmetic
node scripts/check-links.ts       # every source_url responds
node scripts/upload.ts            # upsert as verified=false (default)
node scripts/upload.ts --verified --offline-pack   # after review
node scripts/export-seed.ts       # regenerate assets/seed/content_seed.json before a release
```

Item IDs are deterministic (a hash of topic, type, title and statement or term). Re-uploading updates items instead of duplicating them, and the seed pack and server share the same IDs.

## Tests

```sh
flutter test                                          # 50 tests: core logic + offline/essay integration
node --test supabase/functions/tests/edge_functions.test.ts   # 15 Edge Function tests
```

## Manual checklist before release

- Airplane mode on first launch: onboarding, "Try offline first", home card, quiz and library all work.
- Deny all permissions: the app still works and shows gentle prompts only.
- Dark mode on every screen.
- Sign in, answer cards, reinstall, sign in again: progress, streak and essays come back.
- Notifications arrive in waking hours and open the right card; True/False buttons work.
- Screen time reminder fires after the limit, with usage access granted.
