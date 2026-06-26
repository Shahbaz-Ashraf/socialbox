# SocialBox — Agent & Developer Guide

Quick-start for AI agents and developers working on this repo. Read this **before** editing code.

---

## Session Startup (required reading order)

1. **`CLAUDE.md`** — Full architecture spec (layers, entities, phases). Read completely on first session.
2. **`STATUS.md`** — Last known compile issues and session goals (may be stale — verify with `flutter analyze`).
3. **`features.md`** — What is implemented vs partial vs scheduled.
4. **`schema.md`** — Before any Drift/DB change.
5. **`api.md`** + **`keys.md`** — Before OAuth, posting, or storage work.

---

## Architecture (Features-First Clean Architecture + MVVM + BLoC/Cubit)

**Official stack:** Features-First → Clean Architecture → MVVM → mixed **BLoC or Cubit** (`flutter_bloc`).

```
Presentation (View + ViewModel)  →  Domain  ←  Data
   pages/widgets    bloc/cubit      usecases    repositories
```

### MVVM mapping

| MVVM | SocialBox |
|------|-----------|
| **Model** | `domain/entities/` |
| **ViewModel** | `Bloc` or `Cubit` in `presentation/bloc/` or `presentation/cubit/` |
| **View** | `presentation/pages/` + `widgets/` — `BlocBuilder` only, no business logic |

Views dispatch via `context.read<ViewModel>()`. **Never** `getIt`, repository, or use case inside widgets.

### Mixed BLoC + Cubit (choose by complexity)

| Use **Cubit** | Use **BLoC** |
|---------------|--------------|
| `load()`, `save()`, toggle, form state | Multiple event types, branching async flows |
| Settings, dashboard, AI config, simple lists | Post list actions, reminders+notifications, OAuth connect |

New screens: `BlocProvider` at page level → private `_XxxView` with `BlocBuilder` + `switch` on state.

### Layer rules

| Layer | Allowed | Forbidden |
|-------|---------|-----------|
| **Presentation** | Use cases **via** Bloc/Cubit only | Direct DAO, repository, datasource, or `GetIt` in widgets |
| **Domain** | Pure Dart, entities, use case interfaces | Flutter imports, Drift, Dio |
| **Data** | DAOs, models, repository implementations | BLoC, Cubit, BuildContext |

- Register dependencies in `lib/injection_container.dart` only.
- Repositories register as abstract interface types.
- After Drift / freezed / injectable annotation changes → **build_runner**.
- Full spec: **`CLAUDE.md` §2** and §16 BLoC/Cubit rules.

### Expansion policy (CRITICAL)

**SocialBox grows — it does not shrink.** Every fix and feature must preserve or extend capability.

| Do | Don't |
|----|-------|
| Fix errors by adding missing layers (repo, use case, ViewModel) | Delete screens, routes, DB columns, or use cases to compile |
| Wire partial features (orphan `/logs`, settings toggles, reminder prefill) | Remove “unfinished” code or UI entry points |
| Refactor View → Cubit/Bloc while keeping all actions | Comment out or strip features to “simplify” |
| Add tests/docs when touching a feature | Drop behavior to resolve analyzer warnings |

Deprecation or removal of user-facing behavior requires **explicit owner approval**.

---

## Build & Run (Windows, project on `I:`)

```powershell
$env:PUB_CACHE = "I:\.pub-cache"
Set-Location I:\Posts\socialbox
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run -d <device_id>
```

List devices: `flutter devices`

**If Kotlin compile fails across drives:** ensure `PUB_CACHE` is on `I:\` and `kotlin.incremental=false` in `android/gradle.properties`.

---

## Code Generation

Run when you change:

- Any `@DriftDatabase` table or DAO → `app_database.g.dart`
- Any `@freezed` state/event → `*.freezed.dart`
- Injectable annotations (if enabled later) → `injection_container.config.dart`

```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

**Missing `app_database.g.dart` = ~10+ analyzer errors** — always generate first.

---

## Feature Folders

```
lib/features/
  comment_templates/   # Categories + comments + copy
  posts/               # Post CRUD, calendar, create/edit
  posting_log/         # Global + per-post logs
  reminders/           # Local notifications
  social_auth/         # OAuth (partial)
  dashboard/           # Stats home
  settings/            # Theme, toggles
  hashtags/            # Suggestion tracking (Drift v2)
  ai_prompts/          # AI post writer studio
```

---

## Navigation (GoRouter)

Bottom tabs: **Home** `/dashboard` · **Calendar** `/calendar` · **Comments** `/comments` · **Posts** `/posts` · **Settings** `/settings`

| Route | Path | Notes |
|-------|------|-------|
| AI Writer | `/ai-writer` | Query: `?topic=&platform=` — platform must be normalized |
| Posting Log | `/logs` | Linked from Settings + Dashboard recent activity |
| Social Accounts | `/settings/accounts` | OAuth credentials |
| Reminders | `/settings/reminders` | |

Route name constants: `lib/app/router/route_names.dart`

---

## Known Pitfalls (read before debugging)

| Issue | Detail | Safe approach |
|-------|--------|---------------|
| AI platform crash | Dropdown values: `LinkedIn`, `X`, `Facebook` only | Use `PromptConfig.normalizePlatform()` / `platformFromSocial()` — never `displayName` |
| `Twitter / X` in DB | `SocialPlatform.displayName` ≠ AI values | Store `twitter` in DB; map at UI boundary |
| PUB_CACHE on C: | Cross-drive Gradle/Kotlin failures | `$env:PUB_CACHE = "I:\.pub-cache"` |
| Settings toggles unused | `defaultPlatforms`, `enableNotifications`, etc. saved but not read elsewhere | Wire before assuming behavior |
| Reminder prefill | Create-post may pass `extra` that `RemindersPage` ignores | Check route `extra` handling |
| Notification taps | `NotificationService` callback not wired in `main.dart` | Deep links won't navigate yet |
| Posting log entry points | `/logs` linked from Settings + Dashboard | Bottom-nav tab still optional |
| OAuth compile errors | `ServiceConfiguration` vs `AuthorizationServiceConfiguration` | Match `flutter_appauth` API |
| `ApiEndpoints` typo | Was `AppEndpoints` in some stubs | Import `api_endpoints.dart` |
| Enum in SQLite | Always `.name` strings | `draft` not `Draft` |
| JSON columns | `tagsJson`, `recurringDaysJson`, etc. | `jsonEncode` / `jsonDecode` |
| Predefined categories | `isPredefined: true` | Delete use case must reject |
| Hashtag table | Added in schema v2 | Migration `from < 2` only creates table |

---

## Making Changes Safely

### Database change

1. Edit `app_database.dart`
2. Bump `AppConstants.dbVersion`
3. Add `onUpgrade` migration
4. Run build_runner
5. Update model `toDomain()` / repository if needed
6. Test fresh install **and** upgrade path

### New feature or use case

1. Create/extend `features/{name}/` with `domain/`, `data/` (if persisted), `presentation/`
2. Domain: entity, repository interface, use case(s)
3. Data: datasource + repository impl + models
4. Register in `injection_container.dart`
5. Presentation: **Cubit or Bloc** (per mixed strategy) calling use cases only
6. UI: page shell (`BlocProvider`) + view (`BlocBuilder`) — no logic in widgets
7. Update `features.md` — mark **Implemented** or **Partial**, never remove existing entries

### Fix architecture violation (without losing features)

1. Extract ViewModel from page; move `getIt`/use-case calls into Cubit/Bloc
2. Add missing repository + use cases if presentation hits datasource directly
3. Keep every button, route, and field working — run app path after change

### UI overflow on small screens

- Prefer `FittedBox`, `Flexible`, `Expanded`, lower padding
- Dropdowns: `isExpanded: true`, ellipsis on long text
- Grid: adjust `childAspectRatio` (dashboard stat cards use ~1.2)

---

## Testing Commands

```powershell
flutter analyze
flutter test
```

`test/` has **6 test files** (cubit, page, widget) — add more under `test/features/...` matching feature structure.

---

## Documentation Index

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Master architecture & phase plan |
| `STATUS.md` | Session snapshot |
| `features.md` | Feature inventory + status |
| `schema.md` | Drift tables, DAOs, migrations |
| `api.md` | OAuth + social API endpoints |
| `keys.md` | Storage keys, redirects, limits |
| `agents.md` | This file |
| `quickref.md` | One-page cheat sheet |
| `post-writing-prompt.md` | Default AI prompt template reference |

---

## When to Update Docs

| You changed… | Update… |
|--------------|---------|
| Drift table / migration | `schema.md`, `AppConstants.dbVersion` |
| New API endpoint or OAuth scope | `api.md`, `keys.md` |
| New SharedPreferences / secure key | `keys.md` |
| Shipped or deferred a feature | `features.md` |
| Fixed compile blocker / new pitfall | `agents.md`, `STATUS.md` |

---

*Last updated: 2026-06-26 (Agent 6) — architecture: Features-First Clean Architecture + MVVM + mixed BLoC/Cubit; `flutter analyze` 0 issues*