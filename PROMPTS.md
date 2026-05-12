# AI Usage — Prompt Document

**Tool used:** Gemini / Claude (via Antigravity AI coding assistant in VS Code)  
**Disclosure:** AI was used throughout this project as a pair-programming tool. All architectural decisions, feature requirements, and debugging diagnoses were made by me. The AI was used to implement those decisions faster and to write boilerplate — not to design the system.

---

## How I Directed the AI

The requirement says *"We want to see how well you directed it."* Below is an honest account of every major decision point, what I instructed the AI to do, and — more importantly — **why** I made that call.

---

### 1. Choosing the Architecture

**My decision:** Clean Architecture with feature-based slicing, BLoC for state management, GetIt for DI.

**Why:** I wanted each feature (`users`, `movies`, `saved_movies`, `matches`) to be independently testable with a clear boundary between data and UI. BLoC forces unidirectional data flow, which makes offline/online state predictable. GetIt as a service locator keeps Bloc constructors clean without needing a generated DI framework.

**What I told the AI:**
> "Structure this as Clean Architecture — domain, data, presentation — one folder per feature. Use BLoC for state, GetIt for dependency injection, Dio for networking. Don't use Provider or Riverpod."

---

### 2. The Local Database Design (Drift)

**My decision:** Use Drift (type-safe SQLite) with three tables: `users`, `movies`, `saved_movies`. Use the join table `saved_movies` as a many-to-many between users and movies.

**Why:** The "Matches" feature — finding movies saved by 2+ users — is fundamentally a SQL `GROUP BY / HAVING COUNT >= 2` query. A proper relational schema makes this trivial and reactive (via Drift's `.watch()`). Using a document store or just lists in memory would have made this feature very hard to implement correctly.

**What I told the AI:**
> "Create three Drift tables. Users table with local ID (autoincrement) AND a nullable remote_id — they are separate because locally-created users need to save movies immediately before they have a remote ID. Movies table uses TMDB's ID directly as the primary key, not autoincrement — same movie fetched twice must map to the same row."

The two-ID-space decision for users was entirely mine and required me to explain the constraint carefully.

---

### 3. Offline-First with Background Sync

**My decision:** Optimistic writes to local DB first, then sync to API. Use WorkManager for background sync when the app is killed, plus a foreground sync when connectivity returns.

**Why:** I needed user creation to work completely offline. The WorkManager approach handles the case where the user creates a profile, closes the app, and comes back online later. The foreground sync handles the more common case where they're still in the app.

**What I told the AI:**
> "When creating a user offline, set pendingSync=true and store locally. Register a WorkManager one-off task constrained to NetworkType.connected. When the app is in foreground and connectivity returns, also trigger a direct sync and show a SnackBar — but only if there are actually pending users, otherwise don't show it."

The "only show if pending" condition was my correction after the first implementation showed the snackbar on every reconnect.

---

### 4. Security — API Keys

**My decision:** Use `String.fromEnvironment()` with `--dart-define-from-file=.env` rather than hardcoding keys.

**Why:** I was about to push to GitHub as a public repo for this assignment. Hardcoded API keys in git history are a real security risk.

**What I told the AI:**
> "I don't want to push API keys to GitHub but the app still needs to run. What's the correct Flutter approach?" 

The AI suggested `--dart-define-from-file`. I then decided which keys needed to be extracted (TMDB, OMDB, Reqres) and wrote the `.env` structure myself.

---

### 5. Debugging: Users Not Loading on First Install

**My diagnosis:** After running the app fresh, users weren't appearing even though the API call succeeded (I could see 200 OK in logs). I suspected a silent database write failure.

**What I found:** The `users` table has a required `email` column, but `UserModel` wasn't parsing the `email` field from the Reqres API response. This caused a SQLite null constraint violation that was silently swallowed in the catch block, resulting in an empty local DB and no users displayed.

**What I told the AI:**
> "The API returns 200 with user data but the list is empty. The DB has an email column. Look at UserModel — I think it's not parsing email from the JSON."

I had already diagnosed the root cause before asking the AI to implement the fix.

---

### 6. UX Decisions — Non-Blocking Feedback

**My decision:** Replace all blocking `AlertDialog` popups (except exit confirmation) with floating SnackBars.

**Why:** Dialogs interrupt the user and require an action to dismiss. SnackBars are appropriate for confirmations that don't require a decision — "movie saved" or "user added" are purely informational.

**What I told the AI:**
> "After saving a movie, adding a user, or completing a sync — show a small snackbar at the bottom. No blocking dialogs."

---

### 7. Release Build Debugging

**My diagnosis:** The release APK had no data. I knew this was a release-specific issue and suspected either ProGuard stripping networking classes or a missing Android permission.

**What I told the AI:**
> "Release build can't fetch data. Check AndroidManifest for INTERNET permission, and check if we have ProGuard rules for Dio and Drift."

The `INTERNET` permission was indeed missing — it's not required in debug builds but is in release. I also had the AI create `proguard-rules.pro` with keep rules for all networking and database dependencies.

---

## What the AI Did vs. What I Did

| Aspect | Me | AI |
|--------|----|----|
| Architecture choice (Clean Arch, BLoC, Drift) | ✅ Decided | Implemented |
| Database schema design (two ID spaces, join table) | ✅ Designed | Wrote the Dart code |
| Identifying why users weren't loading | ✅ Diagnosed | Fixed the UserModel |
| Deciding to use `.env` for key security | ✅ Decided | Set up the mechanism |
| Choosing SnackBars over dialogs | ✅ UX decision | Wired them in |
| Identifying missing INTERNET permission | ✅ Diagnosed | Wrote the ProGuard rules |
| Writing the README | ✅ Outlined all content | Formatted and wrote prose |
| Visual design / color palette | ✅ Chose "cinematic dark" direction | Generated the specific hex values |

---

## Key Takeaway

The AI accelerated implementation significantly. But every prompt above required me to already understand the problem well enough to describe it precisely. The email/SQLite bug required me to correlate an empty list with a successful API response and hypothesize a silent write failure — the AI can't do that diagnosis without being told where to look.

Knowing *what to ask* and *how to constrain the answer* is the engineering skill this project demonstrates.
