# Daily Mind: Architecture and Build Specification

**Working name:** Daily Mind (change anytime, it is only a placeholder)
**Owner:** Bismark Nyota
**Version:** 1.0 (all features in one release)
**Audience:** AI coding agents building the full app from this document

---

## 0. Instructions for the Building Agent

Read this whole document before writing any code. Follow these rules:

1. Build in the milestone order in Section 15. Each milestone must compile and run before the next starts.
2. Offline first. The app must open and work with no internet connection. Never block the UI on a network call.
3. Never put secret API keys (DeepSeek or any AI provider) inside the Flutter app. All AI calls go through Supabase Edge Functions.
4. Every package listed here must be checked against its current pub.dev page before use. If a package is discontinued or its API differs from what is written here, use the current recommended approach and note the change in `CHANGES.md`.
5. Do not invent function names or APIs. If unsure a method exists, check the official docs.
6. Every network call has a timeout, a retry, and a user-friendly fallback message.
7. Write tests for the core logic listed in Section 14.

---

## 1. Product Summary

A simple, beautiful mobile app that keeps the user's mind active instead of scrolling social media. It sends short learning notifications through the day, teaches facts and skills across 8 topics, challenges the user with true or false "fake answer" questions, scores handwritten essays with AI, and reminds the user to take a break from their phone.

**Target user:** adults who want to keep learning. Not a children's school app.

### 1.1 Topics (8)

| Code | Topic | Content focus |
|---|---|---|
| `math` | Mathematics | Mental arithmetic, multiplication, percentages, logic, basic algebra |
| `english` | English | Grammar terms, parts of speech, advanced vocabulary, sophisticated phrases for speaking and writing, common mistakes |
| `french` | French | Everyday words and phrases, pronunciation hints, basic grammar, with English translation |
| `science` | Science | Physics, chemistry, biology, space, technology |
| `politics` | Politics | How governments and institutions work, political systems, history of key events. Must be neutral. |
| `economics` | Economics | Inflation, supply and demand, trade, GDP, currencies |
| `finance` | Finance | Saving, investing, interest, business basics, personal money skills |
| `relations` | International Relations | Countries, alliances, the UN, AU, SADC, diplomacy, treaties |

### 1.2 Core Features (all in v1)

1. **Google login** (Supabase Auth).
2. **Daily topic rotation:** each day the app picks 1 or 2 random topics. That day's notifications and home screen focus on those topics.
3. **Learning notifications** every 2 to 3 hours (user adjustable) during waking hours.
4. **Fake answer challenges:** e.g. "7 × 7 = 45. True or false?" The user taps to answer and sees the explanation.
5. **Content library:** browse all topics, even outside today's topics.
6. **Offline mode:** a local content pack stored on the phone. Everything except AI features works with no internet.
7. **Weekend essay challenge:** the app gives an essay prompt, the user writes by hand, photographs the page, and AI returns a score out of 20 with corrections.
8. **AI learning game:** a chat-style game where AI teaches and quizzes the user (online only).
9. **Screen time break reminders** (Android in v1, iOS stubbed).
10. **Streaks and progress:** daily streak, items learned, accuracy per topic.
11. **Light and dark mode.** Clean, white, minimal design by default.

---

## 2. Tech Stack

| Layer | Choice | Notes |
|---|---|---|
| Mobile framework | Flutter (latest stable) + Dart | Android first, iOS compatible |
| State management | Riverpod | Use `flutter_riverpod`. Verify latest version. |
| Navigation | `go_router` | Deep links from notifications |
| Local database | Drift (SQLite) | Offline storage of content, progress, sync queue |
| Backend | Supabase | Auth, Postgres, Storage, Edge Functions |
| Auth | Supabase Auth with Google | Native Google sign-in, then `signInWithIdToken`. Verify the current Supabase Flutter docs for the exact flow. |
| Notifications | `flutter_local_notifications` | Scheduled locally, works offline |
| Background tasks | `workmanager` | Daily reschedule and background sync |
| Camera / image | `image_picker` | Take essay photo or pick from gallery |
| Image compression | `flutter_image_compress` | Compress before upload |
| Screen time | Custom Android platform channel using `UsageStatsManager` | See Section 10 |
| AI: essay scoring and game | DeepSeek API via Edge Functions | Text reasoning and scoring |
| AI: handwriting reading | Vision capable model via Edge Function | See Section 9.2 |
| Connectivity | `connectivity_plus` | Detect online / offline |
| Secure storage | `flutter_secure_storage` | Session tokens if needed |
| Crash reporting (optional) | Sentry | Add if time allows |

**Verify all package names and versions on pub.dev before use.**

---

## 3. System Architecture

```
┌──────────────────────────────── PHONE ────────────────────────────────┐
│                                                                       │
│  Flutter UI (screens)                                                 │
│        │                                                              │
│  Riverpod providers (state)                                           │
│        │                                                              │
│  Repositories  ──────────────┬───────────────────────┐                │
│        │                     │                       │                │
│  Drift SQLite (local)   Supabase client        Notification service   │
│  - content_items        (online only)          (local scheduling)     │
│  - progress                                                           │
│  - sync_queue           Screen time channel (Android native)          │
│  - settings                                                           │
└────────────────────────────────┬──────────────────────────────────────┘
                                 │ HTTPS (when online)
┌────────────────────────────────▼──────────────────────────────────────┐
│                              SUPABASE                                 │
│  Auth (Google)   Postgres (+RLS)   Storage (essay images)             │
│  Edge Functions: score-essay, ai-game-turn, get-content-updates       │
└────────────────────────────────┬──────────────────────────────────────┘
                                 │
                 DeepSeek API  +  Vision model API (secrets on server)
                                 ▲
                 Content pipeline (cloud agents, separate from app)
                 writes facts into Postgres
```

### 3.1 Key principle: the phone is the source of truth for the user experience

- The UI **only reads from the local Drift database**.
- Sync runs in the background and updates Drift.
- Progress is written to Drift first, then queued for upload.
- This makes the app fast and impossible to "break" from bad internet.

---

## 4. Project Folder Structure

```
lib/
  main.dart
  app.dart                      # MaterialApp.router, themes
  core/
    config/env.dart             # Supabase URL + anon key (from --dart-define)
    theme/app_theme.dart        # light + dark themes
    theme/tokens.dart           # colours, spacing, text sizes
    router/app_router.dart
    utils/date_utils.dart
    utils/result.dart           # Result<T> success/failure wrapper
    errors/app_exception.dart
  data/
    local/
      database.dart             # Drift database
      tables/*.dart
      daos/*.dart
    remote/
      supabase_service.dart
      edge_functions_api.dart
    repositories/
      auth_repository.dart
      content_repository.dart
      progress_repository.dart
      essay_repository.dart
      ai_game_repository.dart
      settings_repository.dart
    sync/
      sync_service.dart
      sync_queue.dart
  domain/
    models/*.dart               # ContentItem, Topic, Progress, Essay, etc.
    services/
      topic_rotation_service.dart
      notification_planner.dart
      streak_service.dart
  features/
    onboarding/
    auth/
    home/
    card/                       # single item / challenge view
    library/
    essay/
    ai_game/
    progress/
    settings/
    screen_time/
  platform/
    screen_time_channel.dart
    notification_service.dart
    background_tasks.dart
assets/
  seed/content_seed.json         # offline pack shipped with the app
  images/
android/app/src/main/kotlin/.../ScreenTimePlugin.kt
supabase/
  migrations/*.sql
  functions/
    score-essay/index.ts
    ai-game-turn/index.ts
    get-content-updates/index.ts
    _shared/ai_client.ts
content-pipeline/
  schema/content_item.schema.json
  scripts/validate.ts
  scripts/upload.ts
test/
```

---

## 5. Database Design (Supabase Postgres)

### 5.1 Tables

```sql
-- Topics (seeded, 8 rows)
create table topics (
  code text primary key,              -- 'math', 'english', ...
  name text not null,
  icon text not null,                 -- icon name
  sort_order int not null
);

-- User profile
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz default now()
);

-- All learning content
create table content_items (
  id uuid primary key default gen_random_uuid(),
  topic_code text not null references topics(code),
  type text not null check (type in ('fact','lesson','challenge','vocab','phrase')),
  title text not null,                -- short, fits in a notification title
  body text not null,                 -- main text, max ~400 chars
  -- For challenges (true/false with fake answers):
  statement text,                     -- e.g. '7 × 7 = 45'
  is_true boolean,                    -- false for '7 × 7 = 45'
  correct_answer text,                -- '49'
  explanation text,                   -- why
  -- For vocab / phrases / French:
  term text,
  translation text,
  example_sentence text,
  difficulty smallint not null default 1 check (difficulty between 1 and 3),
  source_name text,                   -- REQUIRED for fact/lesson in politics, economics, finance, relations, science
  source_url text,
  verified boolean not null default false,
  in_offline_pack boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
create index on content_items (topic_code);
create index on content_items (updated_at);

-- Per-user progress on each item
create table user_progress (
  user_id uuid references auth.users(id) on delete cascade,
  item_id uuid references content_items(id) on delete cascade,
  seen_count int not null default 0,
  answered_correct int not null default 0,
  answered_wrong int not null default 0,
  last_seen_at timestamptz,
  saved boolean not null default false,
  updated_at timestamptz default now(),
  primary key (user_id, item_id)
);

-- Daily activity for streaks
create table daily_activity (
  user_id uuid references auth.users(id) on delete cascade,
  day date not null,
  topics text[] not null,             -- that day's rotation
  items_completed int not null default 0,
  primary key (user_id, day)
);

-- Essays
create table essays (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  prompt text not null,
  image_path text not null,           -- Supabase Storage path
  extracted_text text,
  score_total smallint,               -- out of 20
  score_breakdown jsonb,              -- see Section 9.3
  feedback jsonb,
  status text not null default 'pending' check (status in ('pending','done','failed')),
  error_message text,
  created_at timestamptz default now()
);

-- AI game sessions
create table ai_game_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  topic_code text references topics(code),
  mode text not null check (mode in ('teach','quiz','true_false')),
  messages jsonb not null default '[]',
  score int not null default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Simple rate limiting for AI calls
create table ai_usage (
  user_id uuid references auth.users(id) on delete cascade,
  day date not null,
  essay_calls int not null default 0,
  game_calls int not null default 0,
  primary key (user_id, day)
);

-- Essay prompts (readable by all users)
create table essay_prompts (
  id uuid primary key default gen_random_uuid(),
  topic_code text references topics(code),
  prompt text not null,
  is_active boolean not null default true
);

-- User reports of wrong or bad content
create table content_reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  item_id uuid references content_items(id) on delete cascade,
  reason text,
  created_at timestamptz default now()
);
```

### 5.2 Row Level Security (required)

- Enable RLS on every table.
- `topics`, `content_items`: any authenticated user can `select` rows where `is_active = true`. No client inserts or updates. Only the service role (content pipeline) writes.
- `profiles`, `user_progress`, `daily_activity`, `essays`, `ai_game_sessions`, `ai_usage`: users can only read and write rows where `user_id = auth.uid()` (or `id = auth.uid()` for profiles).
- Storage bucket `essays`: private. Path format `{user_id}/{essay_id}.jpg`. Users can only upload and read inside their own folder.

### 5.3 Trigger

Add a trigger that updates `updated_at` on every update of `content_items`, `user_progress`, and `ai_game_sessions`.

---

## 6. Local Database (Drift)

Mirror these tables locally:

- `topics`
- `content_items` (same columns)
- `user_progress`
- `daily_activity`
- `essays` (metadata only, no image blob)
- `settings` (key/value)
- `sync_queue`:

```
sync_queue
  id            integer primary key autoincrement
  entity        text      -- 'user_progress' | 'daily_activity'
  payload_json  text
  created_at    datetime
  attempts      integer default 0
```

Local key/value settings:

| Key | Default |
|---|---|
| `theme_mode` | `system` (`light` / `dark` / `system`) |
| `notif_interval_hours` | `3` (allowed 2 to 4) |
| `quiet_start` | `21:30` |
| `quiet_end` | `07:00` |
| `topics_per_day` | `random` (`1`, `2`, or `random`) |
| `enabled_topics` | all 8 |
| `screen_time_limit_minutes` | `45` |
| `essay_weekend_only` | `true` |
| `last_sync_at` | null |
| `onboarding_done` | false |

---

## 7. Offline and Sync Strategy

### 7.1 Three layers of content

1. **Seed pack:** `assets/seed/content_seed.json`, shipped inside the app. At least 40 verified items per topic (320+ total). Loaded into Drift on first launch. Guarantees the app works offline from minute one, even before login.
2. **Offline pack:** items where `in_offline_pack = true`. Downloaded on first online launch and refreshed weekly.
3. **Online content:** all other active items. Downloaded in batches when online, then also stored locally. Once downloaded, they work offline too.

### 7.2 Sync algorithm

Runs: on app open (if online), on connectivity regained, and once a day via `workmanager`.

```
1. PUSH: for each row in sync_queue (oldest first):
     upsert to Supabase
     on success: delete row
     on failure: attempts += 1; stop pushing; try next sync
     if attempts > 10: log and drop
2. PULL content: call get-content-updates(since = last_sync_at, limit = 500)
     upsert into local content_items
     repeat until fewer than 500 returned
3. PULL progress (only on new device / reinstall): download user_progress and daily_activity
4. Set last_sync_at = server time from response
```

### 7.3 Conflict rules

- Content: server always wins.
- Progress counters: take the higher value of each counter (`max(local, remote)`).
- `saved` flag: last write wins using `updated_at`.

### 7.4 Offline behaviour rules

| Feature | Offline |
|---|---|
| Home, cards, challenges, library | Works |
| Notifications | Works (scheduled on phone) |
| Streaks and progress | Works, syncs later |
| Screen time reminders | Works |
| Login | First login needs internet. After that, session is cached. |
| Essay scoring | Photo is saved locally, marked "waiting for internet", auto submits when online |
| AI game | Shows a friendly "needs internet" screen with a button to do an offline quiz instead |

---

## 8. Core Logic

### 8.1 Daily topic rotation

```
function topicsForDay(date, userId, enabledTopics, topicsPerDaySetting):
  seed = hash(userId + date.toIsoDate())
  rng = Random(seed)                              # same result all day
  n = topicsPerDaySetting == 'random' ? rng.nextInt(2) + 1 : topicsPerDaySetting
  candidates = enabledTopics minus yesterday's topics (if enough remain)
  shuffle(candidates, rng)
  return first n of candidates
```

- Deterministic: the same user gets the same topics all day, even after restarting the app.
- Avoids repeating yesterday's topics where possible.
- Save the result in `daily_activity.topics`.

### 8.2 Picking the next item

```
function nextItem(todayTopics):
  pool = local content_items where topic in todayTopics and is_active
  prefer items never seen (seen_count = 0)
  then items answered wrong before (spaced repetition light)
  then oldest last_seen_at
  mix types: aim for ~40% challenges, 30% facts/lessons, 30% vocab/phrases
  never repeat an item shown in the last 7 days unless pool is exhausted
```

### 8.3 Notification planning

- Plan and schedule notifications for the **next 2 days** at a time.
- Re-plan: every app open, after settings change, and daily via `workmanager`.
- Times: from `quiet_end` to `quiet_start`, every `notif_interval_hours`, with a random offset of plus or minus 15 minutes so it feels natural.
- Each notification is linked to a specific `item_id` chosen by `nextItem` for that day's topics.
- Notification content by type:
  - Challenge: title `"True or false? 🧠"`, body `"7 × 7 = 45"`
  - Fact: title `"Did you know? (Science)"`, body = item title
  - Vocab: title `"Word of the moment (English)"`, body = term
  - French: title `"En français 🇫🇷"`, body = term
- Tapping opens the card screen for that item (deep link `/card/{itemId}`).
- On Android, challenge notifications may include action buttons "True" and "False" if supported by the package; otherwise just open the card.
- Permissions: request notification permission on Android 13+ and iOS during onboarding. Explain why before asking.
- iOS has a limit on pending local notifications (commonly cited as 64). Planning 2 days ahead keeps well under it. Verify the current limit.
- Android exact alarms need special permission. Use inexact scheduling unless exact timing is truly needed. Verify current Android rules.

### 8.4 Streaks

- A day counts if the user completes at least 3 items.
- Streak = consecutive counted days ending today or yesterday.
- Calculated locally from `daily_activity`.

---

## 9. AI Features

### 9.1 Rules for all AI calls

- The app calls **Supabase Edge Functions only**. Edge Functions call the AI providers.
- API keys live in Supabase secrets: `DEEPSEEK_API_KEY`, `VISION_API_KEY`, `VISION_PROVIDER`, `VISION_MODEL`.
- Put all provider code in `supabase/functions/_shared/ai_client.ts` behind two functions: `readHandwriting(imageBytes)` and `chat(messages, jsonMode)`. Changing providers later must only change this file.
- Timeout: 60 seconds for essays, 30 seconds for game turns. Retry once on network error.
- Rate limits per user per day (check and increment `ai_usage`): 5 essays, 100 game turns.
- Always request JSON output and validate it. If the JSON is invalid, retry once, then return a clear error.
- Verify DeepSeek's current API docs for base URL, model names, and JSON mode before coding.

### 9.2 Handwriting reading (important)

The essay is handwritten and photographed. Two steps:

1. **Read the text** with a vision capable model (`readHandwriting`). It is **not confirmed** that DeepSeek's API accepts images, so this step uses a separate configurable vision provider. The building agent must check the current docs of the chosen provider. If DeepSeek does support images at build time, it may be used for both steps.
2. **Score the text** with DeepSeek (`chat`).

Show the extracted text to the user before scoring, with an "Edit" option, so reading errors on messy handwriting do not unfairly lower the score. Spelling mistakes should be kept exactly as written, so the vision prompt must say: "Transcribe exactly as written. Do not correct spelling or grammar."

### 9.3 Edge Function: `score-essay`

**Flow:**
1. App compresses the photo (max 1600px long side, JPEG quality ~80) and uploads it to Storage `essays/{user_id}/{essay_id}.jpg`.
2. App inserts an `essays` row with `status = 'pending'`.
3. App calls `score-essay` with `{ essay_id }`.
4. Function checks auth and ownership, checks rate limit, downloads image, runs `readHandwriting`, returns the text to the app (`step: 'transcribed'`).
5. User confirms or edits text, app calls `score-essay` again with `{ essay_id, confirmed_text }`.
6. Function scores with DeepSeek, saves the result, sets `status = 'done'`.

**Scoring rubric (out of 20):**

| Category | Points | What it checks |
|---|---|---|
| Ideas and content | 5 | Clear message, relevant, uses evidence or examples |
| Structure | 5 | Paragraphs, one topic per paragraph, clear opening and ending |
| Grammar and punctuation | 5 | Comma splices, subject-verb agreement, plurals, possessives, capitals |
| Spelling and vocabulary | 5 | Correct spelling, precise and varied word choice |

**Scoring system prompt (use as is, adjust wording only if needed):**

```
You are a strict, honest English writing examiner. Never flatter.
Score the essay out of 20 using this rubric: ideas (5), structure (5),
grammar and punctuation (5), spelling and vocabulary (5).
Be fair: a score of 10/20 is average for an adult learner.
Quote the user's exact mistakes and give the correction and a one line reason.
Identify the single biggest habit the writer must fix.
Return ONLY valid JSON matching this schema, no other text:
{
  "score_total": int,
  "breakdown": {"ideas": int, "structure": int, "grammar": int, "spelling_vocab": int},
  "breakdown_comments": {"ideas": str, "structure": str, "grammar": str, "spelling_vocab": str},
  "mistakes": [{"original": str, "correction": str, "reason": str}],
  "biggest_habit": str,
  "corrected_version": str,
  "next_exercise": str
}
```

**Essay prompts:** store a list of at least 30 prompts across all 8 topics in the database (a `essay_prompts` table with `id, topic_code, prompt`, readable by all users). One prompt is offered each weekend. User can tap "another prompt".

**Weekend rule:** if `essay_weekend_only = true`, the essay tab shows a countdown to Saturday on weekdays. The user can turn this off in settings.

### 9.4 Edge Function: `ai-game-turn`

**Modes:**
- `teach`: AI teaches a mini lesson (3 to 5 short messages), then asks one question.
- `quiz`: AI asks multiple choice questions, one at a time, tracks score.
- `true_false`: AI makes statements (some deliberately false), user answers True or False.

**Request:** `{ session_id | null, topic_code, mode, user_message }`
**Response:** `{ session_id, ai_message, options: [str] | null, score, finished: bool }`

**System prompt essentials:**
```
You are a friendly but honest tutor for an adult learner.
Topic: {topic}. Mode: {mode}.
Keep every message under 80 words.
Only state facts you are confident are correct. If unsure, say so.
For politics, be neutral and present facts, not opinions.
When the user is wrong, say so clearly and explain why.
Return ONLY JSON: {"ai_message": str, "options": [str] or null,
"correct": bool or null, "finished": bool}
```

- Keep only the last 20 messages in the context sent to DeepSeek.
- A session ends after 10 questions or when the user taps "End".

---

## 10. Screen Time Break Reminders

### 10.1 Android (v1)

- Implement a Kotlin platform channel `ScreenTimePlugin` using `android.app.usage.UsageStatsManager`.
- Requires the special permission `PACKAGE_USAGE_STATS`. The user must enable it manually in phone settings ("Usage access"). The app opens that settings page with `Settings.ACTION_USAGE_ACCESS_SETTINGS` and explains why first.
- Methods exposed to Flutter:
  - `hasPermission() -> bool`
  - `openPermissionSettings()`
  - `getTodayUsage() -> List<{packageName, appName, minutes}>`
  - `getTotalScreenTimeToday() -> int minutes`
- A `workmanager` periodic task (every 15 minutes, which is the Android minimum for periodic work, verify current value) checks usage. If continuous or total usage passes `screen_time_limit_minutes` since the last reminder, send a local notification:
  - Title: `"Time for a brain break 🌿"`
  - Body: a short fact or challenge from today's topics.
- Show a simple screen time card on the Progress screen: today's total and top 5 apps.
- If permission is not granted, the feature stays off and the app works normally.
- Verify all Android APIs against the current Android developer docs. Google Play has policies on usage access permission; check them before any Play Store release.

### 10.2 iOS

- Apple restricts reading screen time data (Screen Time / FamilyControls APIs need special entitlements). **Do not build this for iOS in v1.**
- On iOS, replace with a simple "break reminder" based on time spent inside this app plus a user-set reminder schedule. Hide the usage chart.

---

## 11. Screens and UX

### 11.1 Design system

- Default: white background `#FFFFFF`, text black `#000000`, secondary text `#555555`.
- Dark mode: background `#0E0E0E`, text `#F2F2F2`, secondary `#A0A0A0`.
- One accent colour per topic (used for chips and small icons only):
  math `#2563EB`, english `#DC2626`, french `#7C3AED`, science `#059669`, politics `#475569`, economics `#D97706`, finance `#0D9488`, relations `#DB2777`.
- Font: system default or `Inter`. Body text 16sp, card text 20sp, headings 24 to 28sp.
- Rounded cards (radius 16), lots of white space, no clutter, smooth simple animations (200 to 300ms).
- Must respect system font scaling and pass basic accessibility contrast.

### 11.2 Screens

1. **Onboarding (3 pages):** what the app does, pick topics (all on by default), notification permission. Optional page for screen time permission (Android).
2. **Login:** "Continue with Google". Also a "Try offline first" button that uses the seed pack and asks to log in later.
3. **Home:**
   - Top: greeting, streak 🔥 number, today's topic chips.
   - Big card: next item (tap to open).
   - Buttons: "Quick quiz (5)", "AI game", "Essay" (shows countdown on weekdays).
   - Small offline indicator when there is no internet.
4. **Card screen:**
   - Challenge: statement, two big buttons True / False, then result with correct answer and explanation.
   - Fact/lesson: title, body, source shown small at the bottom ("Source: ...").
   - Vocab/phrase/French: term, meaning or translation, example sentence.
   - Actions: Save ⭐, Next →, Report problem 🚩 (saves a flag locally and syncs to a `content_reports` table: `id, user_id, item_id, reason, created_at`).
5. **Quick quiz:** 5 challenges in a row from today's topics, score at the end.
6. **Library:** grid of 8 topics, then list of items per topic, filter by type, saved items tab.
7. **Essay:** prompt, "Take photo" / "Choose photo", preview, transcription check and edit, result screen with score, breakdown bars, mistakes list, corrected version, biggest habit. History list of past essays with scores (a simple line chart of scores over time).
8. **AI game:** pick topic (default today's) and mode, chat interface with tappable answer buttons, score at top.
9. **Progress:** streak, total items learned, accuracy per topic (bar chart), essay score trend, screen time card (Android).
10. **Settings:** theme, notification interval, quiet hours, topics per day, enabled topics, screen time limit, essay weekend only, sync now, sign out, about.

---

## 12. Content Pipeline (Cloud Agents)

This runs separately from the app. Its job is to fill `content_items` with high quality, correct content.

### 12.1 Rules for content agents

1. Output must match `content-pipeline/schema/content_item.schema.json` exactly.
2. Facts in science, politics, economics, finance, and relations **must include `source_name` and `source_url`** from a reputable source (official sites, encyclopedias, established news or academic sources). No source, no item.
3. Politics content must be neutral: describe systems and events, not opinions.
4. Content about current events must avoid facts that expire quickly (for example "the current president of X") unless the item includes a date like "as of 2026".
5. Challenges must have one clear correct answer. Fake statements must be plausible but clearly false when explained.
6. Keep `title` under 60 characters, `body` under 400 characters, `statement` under 100 characters.
7. Everything uploads with `verified = false`. A review step (human or a second AI checker agent) sets `verified = true`.
8. The app only downloads `verified = true` items by default. Setting option: "Include unverified content" (off by default).

### 12.2 Pipeline steps

```
generate (agents) -> validate.ts (schema + length + duplicate check)
  -> checker agent (second model verifies each fact against its source, flags doubts)
  -> upload.ts (service role key, upsert)
  -> human spot check sample -> set verified = true
```

### 12.3 Example items (JSON)

```json
[
  {
    "topic_code": "math",
    "type": "challenge",
    "title": "Quick multiplication",
    "body": "Multiplication check.",
    "statement": "7 × 7 = 45",
    "is_true": false,
    "correct_answer": "49",
    "explanation": "7 × 7 = 49. A quick check: 7 × 5 = 35, plus 7 × 2 = 14, gives 49.",
    "difficulty": 1
  },
  {
    "topic_code": "english",
    "type": "vocab",
    "title": "Word: meticulous",
    "body": "Meaning: showing great attention to detail.",
    "term": "meticulous",
    "example_sentence": "She kept meticulous records of every test.",
    "difficulty": 2
  },
  {
    "topic_code": "english",
    "type": "lesson",
    "title": "What is a comma splice?",
    "body": "A comma splice joins two full sentences with only a comma. Wrong: 'I love tech, I love building.' Right: 'I love tech. I love building.'",
    "difficulty": 1
  },
  {
    "topic_code": "french",
    "type": "phrase",
    "title": "Asking how someone is",
    "body": "A polite everyday greeting.",
    "term": "Comment allez-vous ?",
    "translation": "How are you? (formal)",
    "example_sentence": "Bonjour madame, comment allez-vous ?",
    "difficulty": 1
  }
]
```

### 12.4 Seed pack

Export 40+ verified items per topic into `assets/seed/content_seed.json` before each app release, with `in_offline_pack = true`.

---

## 13. Reliability ("It Must Not Break")

1. **Offline first:** UI reads only from Drift. Network failures never crash or freeze screens.
2. **Result wrapper:** every repository returns `Result<T>` (success or typed failure). No uncaught exceptions reach the UI.
3. **Global error handling:** set `FlutterError.onError` and `PlatformDispatcher.instance.onError` to log errors (and send to Sentry if added).
4. **Timeouts and retries:** every HTTP call has a timeout and one retry with backoff.
5. **Idempotent sync:** all uploads use upsert with primary keys, so repeating a sync never duplicates data.
6. **Database migrations:** Drift schema versioning with tested migrations. Never delete user progress on upgrade.
7. **Permissions:** the app must work fully if the user denies notifications or usage access. Show a gentle banner, never block.
8. **Validation:** all AI JSON and all downloaded content is validated before saving. Invalid items are skipped and logged.
9. **Empty states:** every list and screen has a friendly empty state.
10. **Low-end phones:** paginate lists, compress images, avoid heavy animations. Target smooth performance on a budget Android phone.

---

## 14. Testing Requirements

**Unit tests (required):**
- `topicsForDay`: same output all day, different across days, avoids yesterday where possible.
- `nextItem`: prefers unseen, then wrong answers, respects 7 day repeat rule.
- Notification planner: respects quiet hours and interval, never exceeds 2 days.
- Streak calculation: gaps, today vs yesterday, time zone edge cases.
- Sync merge rules (Section 7.3).
- Essay JSON parsing and validation.

**Integration tests:**
- First launch offline: seed pack loads, home shows an item.
- Answer a challenge offline, go online, progress appears in Supabase.
- Essay flow with a mocked Edge Function.

**Edge Function tests:** auth rejection, rate limit, invalid AI JSON retry.

**Manual test checklist:** airplane mode everything, deny all permissions, dark mode on every screen, reinstall and log in again (progress restores).

---

## 15. Build Milestones (order for the agent)

All features ship in v1, but build in this order so each step is testable:

1. **Project setup:** Flutter app, folder structure, themes (light/dark), router, Riverpod, env config.
2. **Local data:** Drift database, tables, DAOs, seed pack loader, home and card screens working fully offline.
3. **Core logic:** topic rotation, next item, streaks, quick quiz, library.
4. **Notifications:** planner, scheduling, deep links, quiet hours, permissions.
5. **Supabase:** migrations, RLS, Google login, sync service, background sync.
6. **Content pipeline:** schema, validate and upload scripts, first 320+ verified items, seed export.
7. **Essay feature:** storage upload, `score-essay` function, transcription check, results and history.
8. **AI game:** `ai-game-turn` function and chat UI.
9. **Screen time:** Android plugin, permission flow, reminders, progress card. iOS fallback.
10. **Progress and settings screens.**
11. **Hardening:** tests, error handling, empty states, performance check, final manual checklist.

---

## 16. Environment and Secrets

**App (`--dart-define`):**
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY` (public by design, protected by RLS)
- `GOOGLE_WEB_CLIENT_ID` / `GOOGLE_IOS_CLIENT_ID` (as required by the current Google sign-in setup)

**Supabase secrets (server only):**
- `DEEPSEEK_API_KEY`
- `VISION_PROVIDER`, `VISION_MODEL`, `VISION_API_KEY`

**Content pipeline (local machine only, never committed):**
- `SUPABASE_SERVICE_ROLE_KEY`

Add `.env*` and key files to `.gitignore`.

---

## 17. Must Verify Before or During Build

These points are not confirmed. The agent must check current official docs:

1. Whether DeepSeek's API supports image input, plus current model names, base URL, and JSON mode.
2. Current Supabase Flutter Google sign-in flow (native vs OAuth) for Android and iOS.
3. Latest versions and APIs of every Flutter package listed in Section 2.
4. Android rules for exact alarms, notification permission, and minimum `workmanager` periodic interval.
5. Android `UsageStatsManager` behaviour and Google Play policy for usage access permission.
6. iOS pending local notification limit.
7. Accuracy of the chosen vision model on messy handwriting (test with real handwritten pages early).

---

## 18. Definition of Done

- App installs and works in airplane mode on first launch.
- Google login works, and progress syncs across reinstall.
- Notifications arrive at the right times from that day's topics and open the correct card.
- True/false challenges, facts, vocab, French, and quick quiz all work.
- Essay photo returns a score out of 20 with breakdown and corrections.
- AI game works in all 3 modes.
- Screen time reminders work on Android when permission is granted.
- Light and dark mode look clean on every screen.
- All required tests pass. No crashes in the manual checklist.
