# Publishing We Learn on Google Play

A checklist for getting We Learn from this repo into the Play Store. Work through it top to bottom. Steps marked **Decide** need your choice before you upload anything.

## 1. Before the first upload

- **Decide: the package name.** The app ID is still `com.dailymind.daily_mind` from the old name. Google never lets you change it after the first upload. If you want something like `app.welearn`, change it now (`applicationId` in `android/app/build.gradle.kts`, and the Android OAuth client in Google Cloud).
- **Merge the `we-learn-books` branch into `main`** on GitHub.
- **Turn on GitHub Pages:** repo **Settings → Pages → Deploy from a branch → `main` / `/docs`**. After a minute, these links must open:
  - Privacy policy: https://anvilaidesign-max.github.io/lets-lern/privacy.html
  - Terms: https://anvilaidesign-max.github.io/lets-lern/terms.html
  - Delete account: https://anvilaidesign-max.github.io/lets-lern/delete-account.html
- **Rotate the keys that were pasted in chat:** the Supabase access token (`sbp_…`), the Supabase service role key, the DeepSeek key, the Together key and the Google OAuth client secret. Then update the DeepSeek key in Supabase Edge Function secrets, and the service role key in `content-pipeline/.env`.

## 2. Build the release bundle

```
flutter build appbundle --release --dart-define-from-file=env.json
```

The file to upload is `build/app/outputs/bundle/release/app-release.aab`.

It is signed with your upload key, `android/app/upload-keystore.jks`, using the passwords in `android/key.properties`. Both files are gitignored. **Back them up somewhere safe** (a password manager or an encrypted drive): you need them for every future update.

For each new upload, raise the version in `pubspec.yaml`. The number after `+` must always go up: `1.0.0+1`, then `1.0.1+2`, and so on.

## 3. Keep Google sign-in working

Google sign-in only works for app copies signed with a key whose SHA-1 is registered in Google Cloud (**APIs & Services → Credentials → Android OAuth client**, package `com.dailymind.daily_mind`):

- **Upload key SHA-1:** `F8:16:4C:E1:ED:D6:06:5C:65:A4:7C:9B:2B:B1:46:4A:37:3C:F6:D6`
- **Play App Signing key SHA-1:** Google re-signs the app, so after your first upload copy this SHA-1 from Play Console (**Test and release → App integrity → App signing**) and add it as a second Android OAuth client.

On the **OAuth consent screen**, add your testers as test users, or publish the consent screen to production before a public launch.

## 4. Testing before production

New personal developer accounts must run a **closed test with at least 12 testers opted in for 14 days in a row** before they can apply for production access. Start the closed test early and invite friends and classmates.

## 5. Store listing (draft text)

- **App name:** We Learn
- **Short description (max 80 characters):**
  Learn engineering, law, business, medicine & more in a few minutes a day.
- **Full description:**

  > We Learn turns a few spare minutes into real knowledge. Every day you get fresh cards and a quick quiz from 13 subjects: Electronics Engineering, Mathematics, Science, Technology, Medicine, Law, Business & Startups, Finance, Economics, Politics, International Relations, English and French.
  >
  > **Read like a book.** Each topic has illustrated chapters, from Ohm's law and op-amps to contracts, venture capital, inflation and Zimbabwe's history, each ending in a chapter quiz.
  >
  > **Learn by playing.** Four animated games (Falling Numbers, Swipe It, Memory Match and Rocket Quiz) plus an AI tutor that teaches and tests you at your level.
  >
  > **Stay informed.** A News tab with headlines from Zimbabwe, the world and tech.
  >
  > **Write better.** Photograph a handwritten essay and get a score and feedback.
  >
  > **Works offline.** Cards, books and games work without data. Sign in with Google to back up your progress and streak.
  >
  > No ads. Delete your account and data at any time from Settings.

- **Category:** Education
- **Contact email:** nyotabis@gmail.com
- **Graphics you need to upload:**
  - App icon 512 × 512 PNG (make it from `assets/icon/icon_full.png`)
  - Feature graphic 1024 × 500
  - At least 2 phone screenshots (Home, a book chapter with a diagram, a game, News)

## 6. App content answers

| Section | Answer |
|---|---|
| Privacy policy | https://anvilaidesign-max.github.io/lets-lern/privacy.html |
| App access | All features work without an account except syncing, the AI tutor and essay scoring, which need Google sign-in (any Google account works). No special test login is needed. |
| Ads | No ads |
| Content rating | Fill in the IARC questionnaire as an **Education** app: no violence, sexual content, gambling or user-to-user chat. The history and law books mention wars and crimes factually. |
| Target audience | Recommended **18 and over**: the content is university level and uses Google sign-in and AI. Choosing any under-13 age brings in the Families policy. |
| News app | **No.** The app's purpose is education; the News tab links to publishers' own articles. |
| Health | Health **education** only. The app collects no health data and is not a medical device. |
| Financial features | None. Finance is taught, not offered. |
| Government app | No |

### Data safety form

Data sent to Supabase (the backend) and DeepSeek (AI processing) goes to **service providers acting for the app**, so under Play's definitions it counts as **collected**, not **shared**. Nothing is sold or used for ads.

| Data type (Play category) | Collected? | Optional? | Purpose |
|---|---|---|---|
| Name (Personal info) | Yes, on Google sign-in and profile | Yes, the app works as a guest | Account management, app functionality |
| Email address (Personal info) | Yes, on Google sign-in | Yes | Account management |
| User IDs (Personal info) | Yes (account ID) | Yes | Account management |
| Photos (Photos and videos) | Yes, essay photos only | Yes | App functionality (essay scoring) |
| Other user-generated content | Yes: essay text, AI tutor messages | Yes | App functionality |
| In-app actions (App activity) | Yes: progress, quiz scores, streak | Yes (synced only when signed in) | App functionality |

**Not collected:**

- The profile picture, screen-time usage and the device ID are used on the phone only and never uploaded.
- There is no location, contacts, analytics or crash reporting.

**Security:**

- Data is encrypted in transit: **Yes** (HTTPS).
- Users can ask for their data to be deleted: **Yes**, in the app (**Settings → Delete account**) or at the delete-account page above.

### Permissions you may be asked about

- **Usage access (`PACKAGE_USAGE_STATS`)** powers the optional screen-time break reminders. The user grants it in system settings, and the data stays on the phone.
- **Notifications (`POST_NOTIFICATIONS`)** are used for daily learning reminders.
- **Foreground service (short service)** is declared by the WorkManager library for background tasks such as refreshing news and scheduling reminders. The app has no foreground service of its own. If Play Console asks, describe it that way.
