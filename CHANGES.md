# Changes from ARCHITECTURE.md

Decisions made while building v1, as required by rule 4 of the build spec. Checked on 27 September 2026.

## Verified facts (section 17)

| Item | Finding | What the build does |
|---|---|---|
| DeepSeek models | Current models are `deepseek-flash` and `deepseek-v4-pro`. `deepseek-chat` is gone. Base URL `https://api.deepseek.com`, OpenAI-compatible `/chat/completions`. | Uses `deepseek-flash` (secret `DEEPSEEK_MODEL` to change). |
| DeepSeek JSON mode | `response_format: {type: "json_object"}`. The prompt must contain the word "json". It can occasionally return empty content. | JSON mode on every call; empty answers are errors that get retried. |
| DeepSeek vision | `deepseek-flash` now accepts images (`image_url` with a base64 data URL). | DeepSeek does both handwriting reading and scoring. It was tested on a misspelled sample and kept the spelling exactly. The vision provider is still configurable. |
| DeepSeek thinking mode | On by default for `deepseek-flash`. Turned off with `"thinking": {"type": "disabled"}`. | Off by default for speed (`DEEPSEEK_THINKING=enabled` turns it on). |
| Together AI vision | None of the vision models on this account are serverless (all need a dedicated endpoint). | No vision fallback is configured. `VISION_FALLBACK_*` secrets are supported if one is added later. |
| Supabase Google sign-in | Native flow: `google_sign_in` 7.x (`GoogleSignIn.instance.initialize(serverClientId)` then `authenticate()`), then `signInWithIdToken`. | Implemented as in the spec. |
| Package versions | riverpod 3.4, go_router 18, drift 2.35 + drift_flutter, flutter_local_notifications 22 (all named parameters), google_sign_in 7.2, workmanager 0.10, connectivity_plus 7, fl_chart 1.2. | Code written against these APIs. Riverpod 3 removed `valueOrNull`, so `.value` is used. |
| Exact alarms | Not needed. | Notifications use `AndroidScheduleMode.inexactAllowWhileIdle`, so there is no exact-alarm permission. |
| WorkManager minimum | 15 minutes for periodic work. | Screen time check runs every 15 min; maintenance (sync and re-plan) every 12 h. |
| iOS pending notification limit | Commonly 64. | At most about 2 days × 8 slots (under 20) are planned. |
| Usage access / Play policy | `PACKAGE_USAGE_STATS` is a special permission that Google Play reviews. | The feature is off until the user enables it. Package visibility uses `<queries>` for launcher apps instead of `QUERY_ALL_PACKAGES`. Check the Play policy declaration before release. |

## Deviations

1. **Screen time plugin location.** The spec puts `ScreenTimePlugin.kt` under `android/app/...`. It lives in the local plugin package `packages/screen_time/` instead. WorkManager runs the 15-minute check in a separate background engine, and only packages declared in pubspec get registered there. A class inside the app module would not be.
2. **Sync uses merge RPCs instead of plain upsert.** `sync_user_progress()` and `sync_daily_activity()` apply the section 7.3 rules on the server (max of counters, last-write-wins for `saved`). A plain upsert would let an older device overwrite newer counts. They are `security invoker`, so RLS still applies and `user_id` always comes from the JWT.
3. **Extra columns.**
   - `user_progress.saved_updated_at` holds the client time for last-write-wins, because the `updated_at` trigger always stores server time.
   - `sync_queue.entity_key` makes a newer change replace an older queued change for the same row.
   - Local-only `user_progress.last_answer_correct` and `reported`.
4. **`ai_usage` is read-only for users.** The spec says users can read and write their own rows. That would let anyone reset their own rate limit. Counters change only through `increment_ai_usage()`, which only the service role can call.
5. **Content updates pagination.** `get-content-updates` uses keyset pagination on `(updated_at, id)`, so rows sharing a timestamp are never skipped. It returns tombstones `{id, is_active:false}` for withdrawn or unverified items so the app removes them. `server_time` is moved back 60 seconds to cover late commits.
6. **Rate limit counting.** One essay counts when the photo is transcribed (5 per day). Scoring the confirmed text is not counted separately. Game turns count per AI call (100 per day); "End" does not call the AI.
7. **Edge Function auth.** `verify_jwt = false` in `supabase/config.toml`, and every function checks the user with `auth.getUser()` itself. This keeps working if the project moves to the newer publishable/secret keys.
8. **Edge Function tests** run on Node's built-in test runner (`node --test`) because Deno is not installed. Handler logic lives in `_shared/*.ts` with injected dependencies. The same files run on Deno in production.
9. **Background tasks are Android only in v1.** On iOS, notifications are re-planned on every app open (2 days ahead). iOS "brain breaks" are daily reminders at user-set times (default 11:00, 15:00, 19:00), per section 10.2.
10. **Supabase is optional at build time.** Without `SUPABASE_URL` the app runs fully offline on the seed pack; sign-in explains that online features are not set up.
11. **Seed content is reviewed, not machine-checked.** The 329 items were written for this build. Every one passes `validate.ts`: schema, lengths, duplicates, and arithmetic for statements like "7 × 7 = 45". All 154 source links respond (`check-links.ts`). They are marked `verified = true`. A human spot check (section 12.2) is still recommended before a public release.
12. **Router tabs.** Bottom navigation has Today, Library, Progress and Settings. Essay, AI game and quick quiz open from Home as full screens.
13. **No Sentry.** It was optional. `AppLogger` keeps the last 200 log lines (Settings > About) and is the single place to plug Sentry in.

## Known issues

- **The project folder name contains an apostrophe (`lets learn'`).** `flutter test` generates a Dart file that embeds the path in quotes, and it fails to compile. Rename the folder (for example to `lets-learn`) or run through a path without the apostrophe. This build used a junction, `C:\Users\GRACE\dm`.
- iOS was not built (Windows machine). The iOS setup steps are in README.md.
