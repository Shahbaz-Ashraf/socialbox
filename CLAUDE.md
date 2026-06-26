# CLAUDE.md — SocialBox
## Social Media Comment Templates & Post Manager
### Flutter + BLoC + Clean Architecture (Features-First)

> **For Claude Code:** Read this file fully at the start of every session. Never skip sections.
> Current session state is in `STATUS.md`.

---

## 1. Project Overview

| Key | Value |
|-----|-------|
| **App Name** | SocialBox |
| **Package ID** | `com.linkedif.socialbox` |
| **Tagline** | Organize, schedule, and track your social media content |
| **Platforms** | Android (primary), Windows (secondary) |
| **Developer** | Shahbaz / Linkedif |
| **State Mgmt** | BLoC + Cubit |
| **Architecture** | Clean Architecture, Features-First |
| **Local DB** | Drift (SQLite) |
| **DI** | get_it + injectable |

### Core Problem Solved

Social media managers and content creators need:
1. A **reusable comment library** organized by category — copy & paste to any social media post
2. A **post queue manager** with platform-specific targeting (Facebook, LinkedIn, Twitter/X)
3. A **posting log** to track where and when each post was published per platform
4. **Reminders** for time-sensitive and recurring posts
5. *(Optional/Phase 6)* API-based **auto-posting** with OAuth per platform

---

## 2. Architecture

### Layer Rule (STRICTLY ENFORCED)

```
Presentation  →  Domain  ←  Data
(BLoC/Cubit)    (UseCases)   (Repositories + DataSources)
```

- **Domain**: Pure Dart only. Zero Flutter or package dependencies. Contains entities, repository interfaces, use cases.
- **Data**: Implements domain repository interfaces. Uses Drift, Dio, FlutterSecureStorage.
- **Presentation**: Flutter + BLoC/Cubit. Calls use cases only — never data sources or repositories directly.

### Feature-First Folder Convention

```
features/
  {feature_name}/
    data/
      datasources/
      models/
      repositories/
    domain/
      entities/
      repositories/
      usecases/
    presentation/
      bloc/    ← or cubit/
      pages/
      widgets/
```

### State Management Rules

| Scenario | Use |
|----------|-----|
| Complex flow with multiple event types + side effects | **BLoC** (events + states) |
| Simple CRUD / toggle / load | **Cubit** |
| Never | Direct repository calls from widgets |

### DI Rules

- All dependencies registered via `get_it` + `injectable`
- Use `@injectable`, `@singleton`, `@lazySingleton` annotations
- `injection_container.dart` is the **only** place `GetIt.instance` is accessed
- Widgets use `context.read<T>()` — never `GetIt.instance<T>()` in widget trees
- Repositories always registered as their abstract interface type: `@Injectable(as: CommentRepository)`

---

## 3. Tech Stack & Dependencies

### Core State + Utilities

```yaml
dependencies:
  flutter_bloc: ^8.1.6
  bloc: ^8.1.4
  equatable: ^2.0.5
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  fpdart: ^1.1.0          # Either<Failure, T> for error handling
  uuid: ^4.4.2
  intl: ^0.19.0
```

### Data & Storage

```yaml
  drift: ^2.18.0
  drift_flutter: ^0.1.0
  sqlite3_flutter_libs: ^0.5.24
  path: ^1.9.0
  path_provider: ^2.1.3
  flutter_secure_storage: ^9.2.2    # OAuth tokens (AES-256, keystore-backed)
  shared_preferences: ^2.3.2        # Non-sensitive settings
```

### Networking & Auth

```yaml
  dio: ^5.6.0
  flutter_appauth: ^8.0.1           # OAuth 2.0 PKCE flows
```

### Notifications & Background

```yaml
  flutter_local_notifications: ^17.2.2
  timezone: ^0.9.4
  workmanager: ^0.5.2               # Background scheduled posting
```

### Navigation & DI

```yaml
  go_router: ^14.2.7
  get_it: ^7.7.0
  injectable: ^2.4.4
```

### UI Utilities

```yaml
  share_plus: ^10.0.2
  url_launcher: ^6.3.0
  image_picker: ^1.1.2
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  lottie: ^3.1.2
  flutter_svg: ^2.0.10+1
  permission_handler: ^11.3.1
```

### Dev Dependencies (Code Generation)

```yaml
dev_dependencies:
  build_runner: ^2.4.12
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  injectable_generator: ^2.6.2
  drift_dev: ^2.18.0
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
  flutter_lints: ^4.0.0
```

### Build Runner Command

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Run after: any Drift table change, any freezed model change, any injectable annotation change.

---

## 4. Full Project Structure

```
socialbox/
├── lib/
│   ├── main.dart                              # Entry: init DI + notifications + WorkManager + runApp
│   ├── app/
│   │   ├── app.dart                           # MaterialApp.router
│   │   ├── app_bloc_observer.dart             # BLoC debug logging observer
│   │   ├── router/
│   │   │   ├── app_router.dart                # GoRouter definition (ShellRoute + all routes)
│   │   │   └── route_names.dart               # Route path constants
│   │   └── theme/
│   │       ├── app_theme.dart                 # ThemeData light + dark
│   │       ├── app_colors.dart                # Color palette constants
│   │       └── app_text_styles.dart           # TextStyle definitions
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart             # Package ID, redirect URIs, DB name
│   │   │   ├── predefined_categories.dart     # Seed: 8 categories + 5 comments each
│   │   │   └── api_endpoints.dart             # Twitter / LinkedIn / Facebook API URLs
│   │   ├── errors/
│   │   │   ├── failures.dart                  # Sealed Failure class hierarchy
│   │   │   └── exceptions.dart                # Exception types (DB, Network, Auth)
│   │   ├── network/
│   │   │   ├── dio_client.dart                # Dio singleton with auth interceptor
│   │   │   └── network_info.dart              # Connectivity check (connectivity_plus)
│   │   ├── database/
│   │   │   ├── app_database.dart              # @DriftDatabase root + seeding
│   │   │   ├── app_database.g.dart            # Generated — do not edit
│   │   │   └── daos/
│   │   │       ├── comment_dao.dart           # DAO for categories + comments
│   │   │       ├── post_dao.dart              # DAO for posts + post_platforms
│   │   │       ├── log_dao.dart               # DAO for posting_logs
│   │   │       └── reminder_dao.dart          # DAO for reminders
│   │   ├── services/
│   │   │   ├── notification_service.dart      # flutter_local_notifications wrapper
│   │   │   ├── clipboard_service.dart         # Clipboard.setData + haptic
│   │   │   ├── secure_storage_service.dart    # OAuth token CRUD
│   │   │   └── background_service.dart        # WorkManager task registration
│   │   ├── usecases/
│   │   │   └── usecase.dart                   # abstract UseCase<Type, Params> + NoParams
│   │   └── utils/
│   │       ├── date_utils.dart                # Format helpers
│   │       ├── platform_utils.dart            # SocialPlatform → icon/color/label
│   │       └── extensions.dart                # String, DateTime, BuildContext extensions
│   │
│   ├── features/
│   │   │
│   │   ├── comment_templates/                 ─── FEATURE 1 ───
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── comment_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── comment_category_model.dart
│   │   │   │   │   └── comment_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── comment_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── comment_category.dart
│   │   │   │   │   └── comment.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── comment_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_all_categories.dart
│   │   │   │       ├── create_category.dart
│   │   │   │       ├── update_category.dart
│   │   │   │       ├── delete_category.dart
│   │   │   │       ├── get_comments_by_category.dart
│   │   │   │       ├── search_comments.dart
│   │   │   │       ├── create_comment.dart
│   │   │   │       ├── update_comment.dart
│   │   │   │       ├── delete_comment.dart
│   │   │   │       ├── toggle_favorite.dart
│   │   │   │       └── increment_usage_count.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── category_bloc.dart
│   │   │       │   ├── category_event.dart
│   │   │       │   ├── category_state.dart
│   │   │       │   ├── comment_cubit.dart
│   │   │       │   └── comment_state.dart
│   │   │       ├── pages/
│   │   │       │   ├── categories_page.dart
│   │   │       │   └── comments_page.dart
│   │   │       └── widgets/
│   │   │           ├── category_card.dart
│   │   │           ├── comment_tile.dart
│   │   │           ├── add_category_bottom_sheet.dart
│   │   │           ├── add_comment_bottom_sheet.dart
│   │   │           └── copy_feedback_snackbar.dart
│   │   │
│   │   ├── posts/                             ─── FEATURE 2 ───
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── post_local_datasource.dart
│   │   │   │   │   └── post_remote_datasource.dart    # API posting (Phase 6)
│   │   │   │   ├── models/
│   │   │   │   │   ├── social_post_model.dart
│   │   │   │   │   └── api_post_response_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── post_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── social_post.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── post_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_all_posts.dart
│   │   │   │       ├── get_posts_by_status.dart
│   │   │   │       ├── get_post_by_id.dart
│   │   │   │       ├── create_post.dart
│   │   │   │       ├── update_post.dart
│   │   │   │       ├── delete_post.dart
│   │   │   │       ├── mark_posted_manually.dart
│   │   │   │       └── publish_via_api.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── post_list_bloc.dart
│   │   │       │   ├── post_list_event.dart
│   │   │       │   ├── post_list_state.dart
│   │   │       │   ├── post_form_cubit.dart
│   │   │       │   └── post_form_state.dart
│   │   │       ├── pages/
│   │   │       │   ├── posts_page.dart
│   │   │       │   ├── post_detail_page.dart
│   │   │       │   └── create_edit_post_page.dart
│   │   │       └── widgets/
│   │   │           ├── post_card.dart
│   │   │           ├── platform_chip_selector.dart
│   │   │           ├── post_status_badge.dart
│   │   │           ├── schedule_date_picker.dart
│   │   │           └── recurring_options_sheet.dart
│   │   │
│   │   ├── posting_log/                       ─── FEATURE 3 ───
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── log_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── posting_log_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── log_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── posting_log.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── log_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_logs_for_post.dart
│   │   │   │       ├── get_all_logs.dart
│   │   │   │       ├── create_log_entry.dart
│   │   │   │       ├── update_log_status.dart
│   │   │   │       └── delete_log.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── log_cubit.dart
│   │   │       │   └── log_state.dart
│   │   │       ├── pages/
│   │   │       │   ├── posting_log_page.dart
│   │   │       │   └── post_log_detail_page.dart
│   │   │       └── widgets/
│   │   │           ├── log_tile.dart
│   │   │           ├── platform_log_row.dart
│   │   │           └── log_filter_bar.dart
│   │   │
│   │   ├── reminders/                         ─── FEATURE 4 ───
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── reminder_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── reminder_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── reminder_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── reminder.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── reminder_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_all_reminders.dart
│   │   │   │       ├── get_reminders_for_post.dart
│   │   │   │       ├── create_reminder.dart
│   │   │   │       ├── update_reminder.dart
│   │   │   │       ├── delete_reminder.dart
│   │   │   │       └── toggle_reminder_enabled.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── reminder_bloc.dart
│   │   │       │   ├── reminder_event.dart
│   │   │       │   └── reminder_state.dart
│   │   │       ├── pages/
│   │   │       │   └── reminders_page.dart
│   │   │       └── widgets/
│   │   │           ├── reminder_tile.dart
│   │   │           └── reminder_form_sheet.dart
│   │   │
│   │   ├── social_auth/                       ─── FEATURE 5 ───
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── social_auth_datasource.dart    # FlutterAppAuth + SecureStorage
│   │   │   │   ├── models/
│   │   │   │   │   └── oauth_token_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── connected_account.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── connect_platform.dart
│   │   │   │       ├── disconnect_platform.dart
│   │   │   │       ├── get_connected_accounts.dart
│   │   │   │       └── refresh_access_token.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── auth_cubit.dart
│   │   │       │   └── auth_state.dart
│   │   │       ├── pages/
│   │   │       │   └── social_accounts_page.dart
│   │   │       └── widgets/
│   │   │           └── platform_account_tile.dart
│   │   │
│   │   ├── dashboard/                         ─── FEATURE 6 ───
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── dashboard_stats.dart
│   │   │   │   └── usecases/
│   │   │   │       └── get_dashboard_stats.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── dashboard_cubit.dart
│   │   │       │   └── dashboard_state.dart
│   │   │       ├── pages/
│   │   │       │   └── dashboard_page.dart
│   │   │       └── widgets/
│   │   │           ├── stat_card.dart
│   │   │           ├── upcoming_posts_section.dart
│   │   │           ├── pending_reminders_section.dart
│   │   │           └── recent_activity_section.dart
│   │   │
│   │   └── settings/                          ─── FEATURE 7 ───
│   │       ├── data/
│   │       │   └── datasources/
│   │       │       └── settings_datasource.dart       # SharedPreferences wrapper
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   └── app_settings.dart
│   │       │   ├── repositories/
│   │       │   │   └── settings_repository.dart
│   │       │   └── usecases/
│   │       │       ├── get_settings.dart
│   │       │       └── save_settings.dart
│   │       └── presentation/
│   │           ├── cubit/
│   │           │   ├── settings_cubit.dart
│   │           │   └── settings_state.dart
│   │           └── pages/
│   │               └── settings_page.dart
│   │
│   └── injection_container.dart               # GetIt + Injectable root
│
├── test/
│   ├── features/
│   │   ├── comment_templates/
│   │   │   ├── domain/usecases/
│   │   │   └── presentation/bloc/
│   │   ├── posts/
│   │   │   ├── domain/usecases/
│   │   │   └── presentation/bloc/
│   │   └── posting_log/
│   └── core/
│
├── CLAUDE.md        ← This file
├── STATUS.md        ← Session state — read at start of every session
└── pubspec.yaml
```

---

## 5. Domain Entities

### 5.1 CommentCategory

```dart
// features/comment_templates/domain/entities/comment_category.dart
class CommentCategory extends Equatable {
  final String id;
  final String name;
  final String icon;          // Emoji: '👋'
  final String colorHex;      // '#4CAF50'
  final bool isPredefined;    // true = cannot be deleted
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, name, icon, colorHex, isPredefined, sortOrder];
}
```

### 5.2 Comment

```dart
// features/comment_templates/domain/entities/comment.dart
class Comment extends Equatable {
  final String id;
  final String categoryId;
  final String text;
  final List<String> tags;
  final bool isFavorite;
  final int usageCount;       // Incremented every time user copies it
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, categoryId, text, isFavorite, usageCount];
}
```

### 5.3 SocialPost

```dart
// features/posts/domain/entities/social_post.dart
enum SocialPlatform { facebook, linkedin, twitter }
enum PostStatus { draft, scheduled, partial, posted, failed }
enum RecurringType { none, daily, weekly, custom }

class SocialPost extends Equatable {
  final String id;
  final String title;
  final String content;
  final List<SocialPlatform> platforms;     // Target platforms for this post
  final PostStatus status;
  final DateTime? scheduledAt;
  final bool isRecurring;
  final RecurringType recurringType;
  final List<int> recurringDays;            // 1=Mon, 7=Sun (ISO weekday)
  final List<String> attachments;           // Local file paths
  final List<String> tags;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}

// Status logic:
// draft      → created, not scheduled, not posted
// scheduled  → has scheduledAt in future
// partial    → posted on some platforms but not all
// posted     → posted on ALL targeted platforms
// failed     → API posting attempted but failed on at least one platform
```

### 5.4 PostingLog

```dart
// features/posting_log/domain/entities/posting_log.dart
enum LogStatus { pending, posted, failed, skipped }
enum PostingMethod { manual, api }

class PostingLog extends Equatable {
  final String id;
  final String postId;
  final SocialPlatform platform;
  final LogStatus status;
  final PostingMethod method;
  final DateTime? postedAt;
  final String? externalPostId;     // ID from API response
  final String? externalPostUrl;    // Live URL of the post
  final String? errorMessage;
  final String? notes;
  final DateTime createdAt;
}
```

### 5.5 Reminder

```dart
// features/reminders/domain/entities/reminder.dart
enum ReminderRepeat { none, daily, weekly, custom }

class Reminder extends Equatable {
  final String id;
  final String? postId;             // Optional: linked post
  final String title;
  final String? body;
  final DateTime scheduledAt;
  final ReminderRepeat repeat;
  final List<int> repeatDays;       // [1,3,5] = Mon,Wed,Fri (for custom)
  final bool isEnabled;
  final int notificationId;         // flutter_local_notifications ID
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 5.6 ConnectedAccount

```dart
// features/social_auth/domain/entities/connected_account.dart
class ConnectedAccount extends Equatable {
  final String platform;            // 'facebook' | 'linkedin' | 'twitter'
  final String accessToken;         // Stored in SecureStorage
  final String? refreshToken;
  final DateTime? expiresAt;
  final String? userId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? pageId;             // Facebook: Page ID
  final String? pageToken;          // Facebook: Page Access Token

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isConnected => accessToken.isNotEmpty;
}
```

### 5.7 DashboardStats

```dart
// features/dashboard/domain/entities/dashboard_stats.dart
class DashboardStats extends Equatable {
  final int totalPosts;
  final int draftPosts;
  final int scheduledPosts;
  final int postedPosts;
  final int totalCommentCategories;
  final int totalComments;
  final int totalCopies;            // Sum of usageCount across all comments
  final List<SocialPost> upcomingPosts;
  final List<Reminder> upcomingReminders;
  final List<PostingLog> recentActivity;
}
```

### 5.8 AppSettings

```dart
// features/settings/domain/entities/app_settings.dart
class AppSettings extends Equatable {
  final List<SocialPlatform> defaultPlatforms;
  final bool enableApiPosting;
  final bool enableNotifications;
  final ThemeMode themeMode;
  final int reminderLeadMinutes;     // Notify X min before scheduled post time
  final bool autoRefreshTokens;
  // OAuth credentials (stored via settings; used to init API clients)
  final String? fbAppId;
  final String? liClientId;
  final String? twApiKey;
}
```

---

## 6. Database Schema (Drift)

### Root Database

```dart
// core/database/app_database.dart

@DriftDatabase(tables: [
  CommentCategoriesTable,
  CommentsTable,
  SocialPostsTable,
  SocialPostPlatformsTable,    // Junction: post ↔ platforms
  PostingLogsTable,
  RemindersTable,
], daos: [
  CommentDao,
  PostDao,
  LogDao,
  ReminderDao,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedPredefinedData();
    },
    onUpgrade: (m, from, to) async {
      // Add migration steps here as schemaVersion increments
    },
  );

  Future<void> _seedPredefinedData() async {
    // Insert kPredefinedCategories and kPredefinedComments from predefined_categories.dart
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.dbName));
    return NativeDatabase.createInBackground(file);
  });
}
```

### Drift Table Definitions

```dart
class CommentCategoriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text()();                                           // emoji
  TextColumn get colorHex => text()();                                       // '#RRGGBB'
  BoolColumn get isPredefined => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override Set<Column> get primaryKey => {id};
  @override String get tableName => 'comment_categories';
}

class CommentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(CommentCategoriesTable, #id)();
  TextColumn get commentText => text()();                                    // 'text' is reserved
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();    // JSON array of strings
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override Set<Column> get primaryKey => {id};
  @override String get tableName => 'comments';
}

class SocialPostsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get status => text().withDefault(const Constant('draft'))();   // PostStatus.name
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurringType => text().withDefault(const Constant('none'))();
  TextColumn get recurringDaysJson => text().withDefault(const Constant('[]'))();
  TextColumn get attachmentsJson => text().withDefault(const Constant('[]'))();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override Set<Column> get primaryKey => {id};
  @override String get tableName => 'social_posts';
}

class SocialPostPlatformsTable extends Table {
  // Normalized: one row per (post, platform) pair
  IntColumn get id => integer().autoIncrement()();
  TextColumn get postId => text().references(SocialPostsTable, #id)();
  TextColumn get platform => text()();                                       // SocialPlatform.name

  @override String get tableName => 'social_post_platforms';
}

class PostingLogsTable extends Table {
  TextColumn get id => text()();
  TextColumn get postId => text().references(SocialPostsTable, #id)();
  TextColumn get platform => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // LogStatus.name
  TextColumn get method => text().withDefault(const Constant('manual'))();  // PostingMethod.name
  DateTimeColumn get postedAt => dateTime().nullable()();
  TextColumn get externalPostId => text().nullable()();
  TextColumn get externalPostUrl => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override Set<Column> get primaryKey => {id};
  @override String get tableName => 'posting_logs';
}

class RemindersTable extends Table {
  TextColumn get id => text()();
  TextColumn get postId => text().nullable()();                              // optional FK
  TextColumn get title => text()();
  TextColumn get body => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get repeat => text().withDefault(const Constant('none'))();    // ReminderRepeat.name
  TextColumn get repeatDaysJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get notificationId => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override Set<Column> get primaryKey => {id};
  @override String get tableName => 'reminders';
}
```

### DAO Pattern

```dart
// core/database/daos/comment_dao.dart
@DriftAccessor(tables: [CommentCategoriesTable, CommentsTable])
class CommentDao extends DatabaseAccessor<AppDatabase> with _$CommentDaoMixin {
  CommentDao(super.db);

  // Categories
  Stream<List<CommentCategoryData>> watchAllCategories() =>
      (select(commentCategoriesTable)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).watch();

  Future<void> insertCategory(CommentCategoriesTableCompanion entry) =>
      into(commentCategoriesTable).insert(entry);

  Future<bool> updateCategory(CommentCategoriesTableCompanion entry) =>
      update(commentCategoriesTable).replace(entry);

  Future<int> deleteCategory(String id) =>
      (delete(commentCategoriesTable)..where((t) => t.id.equals(id))).go();

  // Comments
  Stream<List<CommentData>> watchByCategory(String categoryId) =>
      (select(commentsTable)..where((t) => t.categoryId.equals(categoryId))).watch();

  Future<List<CommentData>> searchComments(String query) =>
      (select(commentsTable)..where((t) => t.commentText.like('%$query%'))).get();

  Future<void> insertComment(CommentsTableCompanion entry) =>
      into(commentsTable).insert(entry);

  Future<bool> updateComment(CommentsTableCompanion entry) =>
      update(commentsTable).replace(entry);

  Future<int> deleteComment(String id) =>
      (delete(commentsTable)..where((t) => t.id.equals(id))).go();

  Future<void> incrementUsageCount(String id) async {
    await (update(commentsTable)..where((t) => t.id.equals(id)))
        .write(CommentsTableCompanion(usageCount: Value(
          (await (select(commentsTable)..where((t) => t.id.equals(id))).getSingle()).usageCount + 1,
        )));
  }
}
```

---

## 7. Features & Use Cases

### 7.1 Comment Templates

#### Use Case Summary

| UseCase | Params | Return |
|---------|--------|--------|
| `GetAllCategories` | `NoParams` | `List<CommentCategory>` |
| `CreateCategory` | `(name, icon, colorHex)` | `CommentCategory` |
| `UpdateCategory` | `CommentCategory` | `CommentCategory` |
| `DeleteCategory` | `String id` | `Unit` (fails if isPredefined) |
| `GetCommentsByCategory` | `String categoryId` | `List<Comment>` |
| `SearchComments` | `String query` | `List<Comment>` |
| `CreateComment` | `(categoryId, text, tags)` | `Comment` |
| `UpdateComment` | `Comment` | `Comment` |
| `DeleteComment` | `String id` | `Unit` |
| `ToggleFavorite` | `String commentId` | `Comment` |
| `IncrementUsageCount` | `String commentId` | `Unit` |

#### CategoryBloc

```dart
// Events (sealed class)
sealed class CategoryEvent {
  const factory CategoryEvent.loadAll() = CategoryLoadAll;
  const factory CategoryEvent.create({
    required String name, required String icon, required String colorHex,
  }) = CategoryCreate;
  const factory CategoryEvent.update({required CommentCategory category}) = CategoryUpdate;
  const factory CategoryEvent.delete({required String id}) = CategoryDelete;
  const factory CategoryEvent.reorder({required List<CommentCategory> reordered}) = CategoryReorder;
}

// States (Freezed)
@freezed
class CategoryState with _$CategoryState {
  const factory CategoryState.initial() = _Initial;
  const factory CategoryState.loading() = _Loading;
  const factory CategoryState.loaded({required List<CommentCategory> categories}) = _Loaded;
  const factory CategoryState.error({required String message}) = _Error;
}
```

#### CommentCubit

```dart
@freezed
class CommentState with _$CommentState {
  const factory CommentState.initial() = _Initial;
  const factory CommentState.loading() = _Loading;
  const factory CommentState.loaded({
    required List<Comment> comments,
    @Default('') String query,
    @Default(false) bool favoritesOnly,
  }) = _Loaded;
  const factory CommentState.error({required String message}) = _Error;
}
```

### 7.2 Posts Manager

#### Use Case Summary

| UseCase | Params | Return |
|---------|--------|--------|
| `GetAllPosts` | `(filterStatus?, sortBy?)` | `List<SocialPost>` |
| `GetPostsByStatus` | `PostStatus` | `List<SocialPost>` |
| `GetPostById` | `String id` | `SocialPost` |
| `CreatePost` | `CreatePostParams` | `SocialPost` |
| `UpdatePost` | `UpdatePostParams` | `SocialPost` |
| `DeletePost` | `String id` | `Unit` |
| `MarkPostedManually` | `(postId, platform, notes?)` | `PostingLog` |
| `PublishViaApi` | `(postId, platform)` | `PostingLog` |

#### PostListBloc

```dart
sealed class PostListEvent {
  const factory PostListEvent.load({PostStatus? filterStatus}) = PostListLoad;
  const factory PostListEvent.delete({required String postId}) = PostListDelete;
  const factory PostListEvent.filterByStatus({PostStatus? status}) = PostListFilterByStatus;
  const factory PostListEvent.markPosted({
    required String postId,
    required SocialPlatform platform,
    String? notes,
  }) = PostListMarkPosted;
  const factory PostListEvent.publishViaApi({
    required String postId,
    required SocialPlatform platform,
  }) = PostListPublishViaApi;
}

@freezed
class PostListState with _$PostListState {
  const factory PostListState.initial() = _Initial;
  const factory PostListState.loading() = _Loading;
  const factory PostListState.loaded({
    required List<SocialPost> posts,
    @Default(null) PostStatus? activeFilter,
    @Default(false) bool isActionInProgress,
  }) = _Loaded;
  const factory PostListState.error({required String message}) = _Error;
}
```

#### PostFormCubit (for create/edit form validation)

```dart
@freezed
class PostFormState with _$PostFormState {
  const factory PostFormState({
    @Default('') String title,
    @Default('') String content,
    @Default([]) List<SocialPlatform> selectedPlatforms,
    @Default(PostStatus.draft) PostStatus status,
    DateTime? scheduledAt,
    @Default(false) bool isRecurring,
    @Default(RecurringType.none) RecurringType recurringType,
    @Default([]) List<int> recurringDays,
    @Default([]) List<String> attachments,
    @Default([]) List<String> tags,
    String? notes,
    @Default(false) bool isSubmitting,
    String? errorMessage,
    @Default(false) bool isSuccess,
  }) = _PostFormState;
}
```

### 7.3 Posting Log

#### Use Case Summary

| UseCase | Params | Return |
|---------|--------|--------|
| `GetLogsForPost` | `String postId` | `List<PostingLog>` |
| `GetAllLogs` | `LogFilter` | `List<PostingLog>` |
| `CreateLogEntry` | `CreateLogParams` | `PostingLog` |
| `UpdateLogStatus` | `(id, status, errorMessage?)` | `PostingLog` |
| `DeleteLog` | `String id` | `Unit` |

#### LogCubit

```dart
@freezed
class LogState with _$LogState {
  const factory LogState.initial() = _Initial;
  const factory LogState.loading() = _Loading;
  const factory LogState.loaded({
    required List<PostingLog> logs,
    @Default(null) SocialPlatform? filterPlatform,
    @Default(null) LogStatus? filterStatus,
  }) = _Loaded;
  const factory LogState.error({required String message}) = _Error;
}
```

### 7.4 Reminders

#### Use Case Summary

| UseCase | Params | Return |
|---------|--------|--------|
| `GetAllReminders` | `NoParams` | `List<Reminder>` |
| `GetRemindersForPost` | `String postId` | `List<Reminder>` |
| `CreateReminder` | `CreateReminderParams` | `Reminder` |
| `UpdateReminder` | `UpdateReminderParams` | `Reminder` |
| `DeleteReminder` | `String id` | `Unit` |
| `ToggleReminderEnabled` | `String id` | `Reminder` |

#### ReminderBloc

```dart
sealed class ReminderEvent {
  const factory ReminderEvent.load() = ReminderLoad;
  const factory ReminderEvent.loadForPost({required String postId}) = ReminderLoadForPost;
  const factory ReminderEvent.create({required CreateReminderParams params}) = ReminderCreate;
  const factory ReminderEvent.update({required UpdateReminderParams params}) = ReminderUpdate;
  const factory ReminderEvent.delete({required String id}) = ReminderDelete;
  const factory ReminderEvent.toggle({required String id}) = ReminderToggle;
}

@freezed
class ReminderState with _$ReminderState {
  const factory ReminderState.initial() = _Initial;
  const factory ReminderState.loading() = _Loading;
  const factory ReminderState.loaded({required List<Reminder> reminders}) = _Loaded;
  const factory ReminderState.error({required String message}) = _Error;
}
```

### 7.5 Social Auth

#### Use Case Summary

| UseCase | Params | Return |
|---------|--------|--------|
| `ConnectPlatform` | `String platform` | `ConnectedAccount` |
| `DisconnectPlatform` | `String platform` | `Unit` |
| `GetConnectedAccounts` | `NoParams` | `List<ConnectedAccount>` |
| `RefreshAccessToken` | `String platform` | `ConnectedAccount` |

#### AuthCubit

```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.loaded({required List<ConnectedAccount> accounts}) = _Loaded;
  const factory AuthState.connecting({required String platform}) = _Connecting;
  const factory AuthState.error({required String message}) = _Error;
}
```

---

## 8. Navigation (GoRouter)

```dart
// app/router/app_router.dart
final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          name: RouteNames.dashboard,
          builder: (_, __) => const DashboardPage(),
        ),
        GoRoute(
          path: '/comments',
          name: RouteNames.categories,
          builder: (_, __) => const CategoriesPage(),
          routes: [
            GoRoute(
              path: ':categoryId',
              name: RouteNames.comments,
              builder: (_, state) => CommentsPage(
                categoryId: state.pathParameters['categoryId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/posts',
          name: RouteNames.posts,
          builder: (_, __) => const PostsPage(),
          routes: [
            GoRoute(
              path: 'new',
              name: RouteNames.createPost,
              builder: (_, __) => const CreateEditPostPage(),
            ),
            GoRoute(
              path: ':id',
              name: RouteNames.postDetail,
              builder: (_, state) => PostDetailPage(postId: state.pathParameters['id']!),
              routes: [
                GoRoute(
                  path: 'edit',
                  name: RouteNames.editPost,
                  builder: (_, state) => CreateEditPostPage(
                    postId: state.pathParameters['id'],
                  ),
                ),
                GoRoute(
                  path: 'logs',
                  name: RouteNames.postLogs,
                  builder: (_, state) => PostLogDetailPage(
                    postId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/logs',
          name: RouteNames.logs,
          builder: (_, __) => const PostingLogPage(),
        ),
        GoRoute(
          path: '/settings',
          name: RouteNames.settings,
          builder: (_, __) => const SettingsPage(),
          routes: [
            GoRoute(
              path: 'accounts',
              name: RouteNames.socialAccounts,
              builder: (_, __) => const SocialAccountsPage(),
            ),
            GoRoute(
              path: 'reminders',
              name: RouteNames.reminders,
              builder: (_, __) => const RemindersPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
```

### Bottom Navigation Tabs

```
Tab 0: /dashboard   icon: Icons.home_rounded
Tab 1: /comments    icon: Icons.chat_bubble_outline_rounded
Tab 2: /posts       icon: Icons.send_rounded
Tab 3: /logs        icon: Icons.history_rounded
Tab 4: /settings    icon: Icons.settings_rounded
```

---

## 9. Predefined Seed Data

```dart
// core/constants/predefined_categories.dart

const kPredefinedCategories = [
  (id: 'cat_engagement',   name: 'Engagement',      icon: '👋', color: '#4CAF50'),
  (id: 'cat_congrats',     name: 'Congratulations', icon: '🎉', color: '#FF9800'),
  (id: 'cat_professional', name: 'Professional',    icon: '💼', color: '#2196F3'),
  (id: 'cat_promotional',  name: 'Promotional',     icon: '📢', color: '#E91E63'),
  (id: 'cat_appreciation', name: 'Appreciation',    icon: '🙏', color: '#9C27B0'),
  (id: 'cat_questions',    name: 'Questions',       icon: '❓', color: '#00BCD4'),
  (id: 'cat_support',      name: 'Support',         icon: '💪', color: '#FF5722'),
  (id: 'cat_general',      name: 'General',         icon: '💬', color: '#607D8B'),
];

const kPredefinedComments = {
  'cat_engagement': [
    'Great content as always! Keeping me coming back for more. 🙌',
    'Really valuable insights here, thank you for sharing!',
    'This is exactly what I needed to read today. Bookmarking this!',
    'Love the way you explained this. So clear and practical!',
    'This really made me think! What inspired this post?',
  ],
  'cat_congrats': [
    'Congratulations on this amazing achievement! Well deserved! 🎉',
    'So excited to see this announcement! You\'ve worked so hard for this!',
    'Huge congratulations! This is just the beginning of something great!',
    'This is truly inspiring! Congratulations on your success! 🏆',
    'What a milestone! Congratulations and wishing you even greater success!',
  ],
  'cat_professional': [
    'Excellent perspective on this. Very directly applicable to our work.',
    'From my experience in this field, this approach delivers the best results.',
    'Great analysis. The key takeaway for professionals here is spot on.',
    'Thank you for sharing this insight. Adding it to our team playbook!',
    'This is exactly the kind of thought leadership our industry needs.',
  ],
  'cat_promotional': [
    'We\'ve been building something that solves exactly this! Feel free to DM.',
    'Tag someone in your network who needs to see this! 👇',
    'Share this with your connections if you found it valuable! 🔁',
    'This is why we built our product. Would love your feedback!',
    'If this resonates, you\'d love what we\'re working on. Check the link!',
  ],
  'cat_appreciation': [
    'Thank you so much for sharing this! Really helpful and timely.',
    'Your content always adds value to my day. Much appreciated!',
    'I really appreciate the effort you put into creating this. Thank you!',
    'This community is amazing because of people like you. Thank you!',
    'Grateful for this resource. Sharing it with my team right away!',
  ],
  'cat_questions': [
    'This is fascinating! How did you arrive at this conclusion?',
    'What would you recommend for someone just starting out here?',
    'Have you seen any real-world success stories with this approach?',
    'What was the biggest challenge you faced while implementing this?',
    'How does this compare to the more traditional approach?',
  ],
  'cat_support': [
    'You\'ve got this! Keep pushing forward! 💪',
    'We\'re all rooting for you! This is going to be incredible!',
    'Believe in yourself — the hard work always pays off!',
    'Tackling this head-on is the right move. Respect!',
    'Remember why you started. You\'re doing absolutely great!',
  ],
  'cat_general': [
    'Great post! Thanks for sharing.',
    'Very insightful. Saved for future reference!',
    'Sharing this — more people need to see it.',
    'Couldn\'t agree more with this perspective!',
    'This just made it to my must-read list!',
  ],
};
```

---

## 10. Social Media API Integration

### 10.1 Twitter / X API v2

**OAuth 2.0 PKCE**

| Field | Value |
|-------|-------|
| Auth URL | `https://twitter.com/i/oauth2/authorize` |
| Token URL | `https://api.twitter.com/2/oauth2/token` |
| Scopes | `tweet.write users.read offline.access` |
| Redirect URI | `com.linkedif.socialbox://oauth/twitter` |
| Requires | Developer Portal account + approved app |
| Register at | https://developer.twitter.com/en/portal/dashboard |

**Post Tweet**

```
POST https://api.twitter.com/2/tweets
Authorization: Bearer {access_token}
Content-Type: application/json

{ "text": "Your content here" }

Response: { "data": { "id": "1234567890", "text": "..." } }
External URL: https://twitter.com/i/web/status/{id}
```

---

### 10.2 LinkedIn API

**OAuth 2.0**

| Field | Value |
|-------|-------|
| Auth URL | `https://www.linkedin.com/oauth/v2/authorization` |
| Token URL | `https://www.linkedin.com/oauth/v2/accessToken` |
| Scopes | `w_member_social r_liteprofile` |
| Redirect URI | `com.linkedif.socialbox://oauth/linkedin` |
| Register at | https://www.linkedin.com/developers/apps (Product: "Share on LinkedIn") |

**Get Profile URN (required before posting)**

```
GET https://api.linkedin.com/v2/me
Authorization: Bearer {access_token}
→ { "id": "xyz123", "localizedFirstName": "...", "localizedLastName": "..." }
```

**Post Share**

```
POST https://api.linkedin.com/v2/ugcPosts
Authorization: Bearer {access_token}
Content-Type: application/json
X-Restli-Protocol-Version: 2.0.0

{
  "author": "urn:li:person:{userId}",
  "lifecycleState": "PUBLISHED",
  "specificContent": {
    "com.linkedin.ugc.ShareContent": {
      "shareCommentary": { "text": "Post content" },
      "shareMediaCategory": "NONE"
    }
  },
  "visibility": { "com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC" }
}

Response: { "id": "urn:li:ugcPost:1234567890" }
```

---

### 10.3 Facebook Graph API

**OAuth 2.0**

| Field | Value |
|-------|-------|
| Auth URL | `https://www.facebook.com/dialog/oauth` |
| Token URL | `https://graph.facebook.com/oauth/access_token` |
| Scopes | `pages_manage_posts pages_read_engagement` |
| Redirect URI | `com.linkedif.socialbox://oauth/facebook` |
| Register at | https://developers.facebook.com/apps |
| Note | Requires Business Verification for full permissions |

**Get Pages (after user login)**

```
GET https://graph.facebook.com/v20.0/me/accounts?access_token={user_token}
→ { "data": [{ "id": "pageId", "name": "My Page", "access_token": "page_token" }] }
```

**Post to Page**

```
POST https://graph.facebook.com/v20.0/{pageId}/feed
Content-Type: application/json

{ "message": "Post content", "access_token": "{page_access_token}" }

Response: { "id": "pageId_postId" }
External URL: https://www.facebook.com/{pageId}/posts/{postId}
```

---

### 10.4 Token Storage

```dart
// core/services/secure_storage_service.dart
class SecureStorageService {
  static const _prefix = 'socialbox_oauth_';

  Future<void> saveToken(String platform, OAuthTokenModel token) async {
    await _storage.write(
      key: '$_prefix$platform',
      value: jsonEncode(token.toJson()),
    );
  }

  Future<OAuthTokenModel?> getToken(String platform) async {
    final raw = await _storage.read(key: '$_prefix$platform');
    if (raw == null) return null;
    return OAuthTokenModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> deleteToken(String platform) async {
    await _storage.delete(key: '$_prefix$platform');
  }

  Future<Map<String, OAuthTokenModel>> getAllTokens() async {
    final all = await _storage.readAll();
    return Map.fromEntries(
      all.entries
          .where((e) => e.key.startsWith(_prefix))
          .map((e) => MapEntry(
                e.key.substring(_prefix.length),
                OAuthTokenModel.fromJson(jsonDecode(e.value) as Map<String, dynamic>),
              )),
    );
  }
}
```

---

## 11. Notification Strategy

### Channels

| Channel ID | Name | Importance | Use |
|-----------|------|-----------|-----|
| `reminders_channel` | Post Reminders | High | Scheduled reminder alerts |
| `posting_channel` | Posting Results | Default | API success/failure alerts |
| `daily_summary` | Daily Summary | Low | End-of-day posting summary |

### NotificationService

```dart
// core/services/notification_service.dart
@singleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _plugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    await _createChannels();
    await tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));  // PKT default
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    if (!reminder.isEnabled) return;

    final scheduledDate = tz.TZDateTime.from(reminder.scheduledAt, tz.local);
    final repeatComponent = switch (reminder.repeat) {
      ReminderRepeat.daily => DateTimeComponents.time,
      ReminderRepeat.weekly => DateTimeComponents.dayOfWeekAndTime,
      _ => null,
    };

    await _plugin.zonedSchedule(
      reminder.notificationId,
      reminder.title,
      reminder.body ?? 'Time to post!',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Post Reminders',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(reminder.body ?? ''),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: repeatComponent,
      payload: reminder.postId,      // For deep link on tap
    );
  }

  Future<void> cancelReminder(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  Future<void> showPostingResult({
    required String title,
    required String body,
    required bool isSuccess,
  }) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title, body,
      const NotificationDetails(
        android: AndroidNotificationDetails('posting_channel', 'Posting Results'),
      ),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Navigate to post detail if payload is postId
    // Use GoRouter: appRouter.push('/posts/${response.payload}')
  }
}
```

---

## 12. Background Tasks (WorkManager)

```dart
// core/services/background_service.dart
const kScheduledPostingTask = 'socialbox_scheduled_posting';
const kTokenRefreshTask = 'socialbox_token_refresh';

class BackgroundService {
  static Future<void> register() async {
    await Workmanager().registerPeriodicTask(
      kScheduledPostingTask,
      kScheduledPostingTask,
      frequency: const Duration(minutes: 15),    // Android minimum
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  // Called by callbackDispatcher in background isolate
  static Future<bool> executeScheduledPosting() async {
    try {
      // 1. Re-initialize DI in background isolate
      await configureDependencies();
      final db = getIt<AppDatabase>();
      final notifService = getIt<NotificationService>();
      await notifService.init();

      // 2. Find posts due for posting
      final postDao = getIt<PostDao>();
      final duePosts = await postDao.getPostsDueForPosting(DateTime.now());

      for (final post in duePosts) {
        for (final platform in post.platforms) {
          // 3. Check if already logged for this platform today
          final alreadyPosted = await getIt<LogDao>()
              .isPostedToday(post.id, platform.name);
          if (alreadyPosted) continue;

          // 4. Call publish use case
          final result = await getIt<PublishViaApi>()(
            PublishParams(postId: post.id, platform: platform),
          );

          // 5. Notify result
          result.fold(
            (failure) => notifService.showPostingResult(
              title: 'Posting Failed',
              body: '${post.title} failed on ${platform.name}: ${failure.message}',
              isSuccess: false,
            ),
            (log) => notifService.showPostingResult(
              title: 'Posted Successfully',
              body: '${post.title} published on ${platform.name}',
              isSuccess: true,
            ),
          );
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
```

### main.dart WorkManager Setup

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<NotificationService>().init();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  await BackgroundService.register();
  runApp(const SocialBoxApp());
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    return switch (task) {
      kScheduledPostingTask => BackgroundService.executeScheduledPosting(),
      _ => Future.value(true),
    };
  });
}
```

---

## 13. Core Patterns

### UseCase Base Class

```dart
// core/usecases/usecase.dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();
  @override List<Object?> get props => [];
}
```

### Failure Hierarchy

```dart
// core/errors/failures.dart
sealed class Failure extends Equatable {
  const Failure({required this.message});
  final String message;
  @override List<Object?> get props => [message];
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message});
}
final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}
final class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}
final class ApiFailure extends Failure {
  const ApiFailure({required super.message, this.statusCode});
  final int? statusCode;
  @override List<Object?> get props => [message, statusCode];
}
final class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}
final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
final class PredefinedItemFailure extends Failure {
  const PredefinedItemFailure({required super.message});
}
```

### Repository Implementation Pattern

```dart
// Example: CommentRepositoryImpl
@Injectable(as: CommentRepository)
class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl(this._localDataSource);
  final CommentLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<CommentCategory>>> getAllCategories() async {
    try {
      final models = await _localDataSource.getAllCategories();
      return Right(models.map((m) => m.toDomain()).toList());
    } on DriftWrappedException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String id) async {
    try {
      // Business rule: cannot delete predefined categories
      final category = await _localDataSource.getCategoryById(id);
      if (category?.isPredefined == true) {
        return Left(const PredefinedItemFailure(
          message: 'Predefined categories cannot be deleted.',
        ));
      }
      await _localDataSource.deleteCategory(id);
      return const Right(unit);
    } on DriftWrappedException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
```

### BLoC in Widget Pattern

```dart
// Always provide BLoCs at route level or via BlocProvider, never in build()
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CategoryBloc>()..add(const CategoryEvent.loadAll()),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) => switch (state) {
        _Initial() => const SizedBox.shrink(),
        _Loading() => const LoadingSkeletonGrid(),
        _Loaded(:final categories) => CategoryGrid(categories: categories),
        _Error(:final message) => ErrorRetryWidget(
            message: message,
            onRetry: () => context.read<CategoryBloc>().add(const CategoryEvent.loadAll()),
          ),
      },
    );
  }
}
```

### ClipboardService

```dart
@singleton
class ClipboardService {
  Future<void> copyText(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Copied to clipboard!'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
```

---

## 14. Platform Utilities

```dart
// core/utils/platform_utils.dart
extension SocialPlatformX on SocialPlatform {
  String get displayName => switch (this) {
    SocialPlatform.facebook => 'Facebook',
    SocialPlatform.linkedin => 'LinkedIn',
    SocialPlatform.twitter  => 'Twitter / X',
  };

  IconData get icon => switch (this) {
    SocialPlatform.facebook => Icons.facebook,
    SocialPlatform.linkedin => FontAwesomeIcons.linkedin,   // if fa added
    SocialPlatform.twitter  => FontAwesomeIcons.xTwitter,
  };

  Color get color => switch (this) {
    SocialPlatform.facebook => const Color(0xFF1877F2),
    SocialPlatform.linkedin => const Color(0xFF0A66C2),
    SocialPlatform.twitter  => const Color(0xFF000000),
  };

  String get openAppUrl => switch (this) {
    SocialPlatform.facebook => 'fb://feed',
    SocialPlatform.linkedin => 'linkedin://feed',
    SocialPlatform.twitter  => 'twitter://timeline',
  };

  String get openWebUrl => switch (this) {
    SocialPlatform.facebook => 'https://facebook.com',
    SocialPlatform.linkedin => 'https://linkedin.com/feed',
    SocialPlatform.twitter  => 'https://x.com/home',
  };
}
```

---

## 15. Development Phases

### Phase 1: Foundation (Days 1–3)

**Goal:** Runnable app shell — DI, theme, navigation, DB, seed data

- [ ] `flutter create socialbox --org com.linkedif --platforms android,windows`
- [ ] Replace `pubspec.yaml` with dependencies from §3
- [ ] Create complete folder structure from §4
- [ ] Configure `get_it` + `injectable` → `injection_container.dart`
- [ ] Implement `AppDatabase` with all Drift tables from §6
- [ ] Implement all 4 DAOs
- [ ] Implement `NotificationService` (init + permission request on Android 13+)
- [ ] Implement `ClipboardService`
- [ ] Implement `SecureStorageService`
- [ ] Seed `kPredefinedCategories` + `kPredefinedComments` on DB `onCreate`
- [ ] Set up `AppTheme` (brand colors: deep indigo primary + teal accent)
- [ ] Set up `GoRouter` with all routes from §8
- [ ] Create `MainShell` with bottom navigation (5 tabs)
- [ ] Create stub pages (placeholder text only)
- [ ] Add `AppBlocObserver` → register in `main.dart`
- [ ] Init WorkManager in `main.dart`
- [ ] Run `build_runner` — confirm no errors

**Exit criteria:** App launches, tabs switch, DB created with seed data visible in debug logs.

---

### Phase 2: Comment Templates (Days 4–7)

**Goal:** Full CRUD for categories and comments with copy functionality

- [ ] Domain: entities, repository interface, all 11 use cases
- [ ] Data: `CommentLocalDataSource` (DAO calls), models with `toDomain()` / `toCompanion()`, `CommentRepositoryImpl`
- [ ] Register all in `injection_container.dart`
- [ ] `CategoryBloc`: LoadAll, Create, Update, Delete, Reorder
- [ ] `CommentCubit`: LoadByCategory, Create, Update, Delete, ToggleFavorite, IncrementUsage, Search
- [ ] `CategoriesPage`: responsive grid (2-col phone / 3-col tablet), FAB add, tap → CommentsPage
- [ ] `CommentsPage`: list with search bar + favorites filter chip, FAB add
- [ ] `AddCategoryBottomSheet`: name + emoji picker (grid) + color swatch picker
- [ ] `AddCommentBottomSheet`: multiline text field + optional tags chip input
- [ ] `CategoryCard`: colored icon, name, comment count badge
- [ ] `CommentTile`: text preview, tags, copy icon (ClipboardService + IncrementUsage), favorite toggle heart, long-press context menu (Edit / Delete)
- [ ] Confirmation dialog before delete
- [ ] Swipe to delete (with Undo SnackBar)
- [ ] Empty state for categories (Lottie) + empty state for comments

**Exit criteria:** Full copy → paste flow works. Categories with sample comments loaded from seed.

---

### Phase 3: Posts Manager (Days 8–12)

**Goal:** Full post lifecycle management with manual posting flow

- [ ] Domain: entities (enums), repository interface, all 8 use cases
- [ ] Data: `PostLocalDataSource` (PostDao), `PostRemoteDataSource` (stub), models, `PostRepositoryImpl`
- [ ] `PostListBloc`: Load with filter, Delete, MarkPosted (creates log), PublishViaApi (stub)
- [ ] `PostFormCubit`: validation (title required, ≥1 platform, scheduledAt in future if scheduled)
- [ ] `PostsPage`: TabBar (All / Draft / Scheduled / Posted / Failed), pull-to-refresh
- [ ] `PostCard`: title, content truncated, platform chips row, status badge, schedule time
- [ ] `PostDetailPage`: full content, per-platform action buttons, log preview section
- [ ] `CreateEditPostPage`: title, content (multiline), platform multi-select, schedule picker, recurring options, notes, tags, attach image (image_picker)
- [ ] `PlatformChipSelector`: Facebook / LinkedIn / Twitter/X colored chips with toggle
- [ ] `ScheduleDatePicker`: date + time picker → sets scheduledAt
- [ ] `RecurringOptionsSheet`: none / daily / weekly / custom day-of-week selector
- [ ] "Mark as Posted" flow: dialog asks for notes → creates PostingLog(method: manual) → recalculates PostStatus → updates post
- [ ] "Open App" button: url_launcher deep link to platform app/web
- [ ] Computed PostStatus: if all platforms have log(status: posted) → 'posted', if some → 'partial'

**Exit criteria:** Full create → detail → mark as posted → log created flow works.

---

### Phase 4: Posting Log (Days 13–15)

**Goal:** Full log history and per-post platform tracking

- [ ] Domain: `PostingLog` entity, repository interface, 5 use cases
- [ ] Data: `LogLocalDataSource` (LogDao), model, `LogRepositoryImpl`
- [ ] `LogCubit`: LoadAll (with filter), LoadForPost
- [ ] `PostingLogPage`: chronological list of all log entries, `LogFilterBar` (by platform + status)
- [ ] `PostLogDetailPage` (accessible from PostDetailPage): all logs for one post grouped by platform
- [ ] `LogTile`: platform icon + color, status badge, timestamp, method badge (Manual/API), external URL link button
- [ ] `PlatformLogRow` widget (used in `PostDetailPage`): horizontal row of platform icons with status indicator dots
- [ ] Filter bar: platform chips + status filter (pending / posted / failed / skipped)
- [ ] Log is auto-created in `MarkPostedManually` use case and `PublishViaApi` use case

**Exit criteria:** Posting history visible per-post and globally with filters.

---

### Phase 5: Reminders (Days 16–18)

**Goal:** Local notification reminders linked to posts

- [ ] Domain: `Reminder` entity, repository interface, 6 use cases
- [ ] Data: `ReminderLocalDataSource` (ReminderDao), model, `ReminderRepositoryImpl`
- [ ] `ReminderBloc`: Load, LoadForPost, Create (schedule notification), Update (reschedule), Delete (cancel notification), Toggle (enable/disable)
- [ ] `RemindersPage`: list sorted by scheduledAt, upcoming section + past section
- [ ] `ReminderTile`: title, formatted date/time, repeat badge, post link chip, enable toggle
- [ ] `ReminderFormSheet`: title, date+time picker, repeat selector, optional post link
- [ ] Auto-suggest dialog: when creating a scheduled post → "Add a reminder for this post?" → pre-fill with post title + scheduled time
- [ ] `NotificationService.scheduleReminder()` called on create/update
- [ ] `NotificationService.cancelReminder()` called on delete or disable
- [ ] Notification tap → deep link to `/posts/{postId}` if linked, else `/settings/reminders`
- [ ] Notification ID: use `uuid.v4().hashCode.abs() % 100000`

**Exit criteria:** Reminders appear as system notifications at correct time. Recurring reminders fire daily/weekly.

---

### Phase 6: Social Auth + API Posting (Days 19–25)

**Goal:** OAuth connections and automatic API posting

- [ ] Domain: `ConnectedAccount` entity, repository interface, 4 use cases
- [ ] Data: `SocialAuthDataSource` (FlutterAppAuth + SecureStorageService), `AuthRepositoryImpl`
- [ ] Twitter PKCE flow: Auth → Token exchange → Save → Load profile (GET /2/users/me)
- [ ] LinkedIn OAuth flow: Auth → Token → Load profile (GET /v2/me)
- [ ] Facebook OAuth flow: Auth → Token → List pages (GET /me/accounts) → User selects page
- [ ] `AuthCubit`: load accounts, connect(platform), disconnect(platform), refresh(platform)
- [ ] `SocialAccountsPage`: 3 tiles (FB, LI, TW) with connect/disconnect, username, expiry
- [ ] `PlatformAccountTile`: platform logo, connection status, username, last refresh time
- [ ] Implement `PostRemoteDataSource`: `postToTwitter()`, `postToLinkedIn()`, `postToFacebook()`
- [ ] Dio interceptor: inject `Authorization: Bearer {token}` per platform
- [ ] `PublishViaApi` use case: get token → call remote datasource → create PostingLog
- [ ] Auto token refresh (if refreshToken available) before API calls
- [ ] WorkManager `executeScheduledPosting()` fully wired
- [ ] Settings page: show per-platform OAuth client ID/secret input fields (saved to SharedPreferences, not SecureStorage — not sensitive)
- [ ] android/app/build.gradle: add `manifestPlaceholders += ['appAuthRedirectScheme': 'com.linkedif.socialbox']`

**Exit criteria:** Can connect to Twitter/LinkedIn, publish a post, see log with external URL.

---

### Phase 7: Dashboard + Polish (Days 26–30)

**Goal:** Production-ready app with dashboard and polish

- [ ] `GetDashboardStats` use case: aggregate query across PostDao + CommentDao + LogDao + ReminderDao
- [ ] `DashboardCubit`: load stats, auto-refresh every 60s
- [ ] `DashboardPage`: stat cards row + upcoming posts + upcoming reminders + recent log activity
- [ ] `StatCard`: icon, label, count with animation
- [ ] Global search: `SearchDelegate` searching comments + posts by text
- [ ] Export: export all comments to CSV (share_plus)
- [ ] Settings: theme toggle (light/dark/system), default platforms, reminder lead time slider
- [ ] Empty states: Lottie animations on all list pages
- [ ] Loading skeletons: shimmer on all list pages
- [ ] Error states with retry button on all pages
- [ ] Haptic feedback: `HapticFeedback.lightImpact()` on copy; `mediumImpact()` on mark-as-posted
- [ ] App icon + splash screen
- [ ] `analysis_options.yaml` with strict lints
- [ ] All TODO stubs removed or tracked in STATUS.md

**Exit criteria:** App is fully functional, polished, and ready for Play Store alpha.

---

## 16. Coding Conventions

### Naming

| Type | Convention | Example |
|------|-----------|---------|
| Files | snake_case | `comment_repository_impl.dart` |
| Classes | PascalCase | `CommentRepositoryImpl` |
| Variables/methods | camelCase | `getAllCategories()` |
| Constants | kCamelCase | `kPredefinedCategories` |
| Enums (type) | PascalCase | `PostStatus` |
| Enum values | camelCase | `PostStatus.draft` |
| Private fields | underscore prefix | `_localDataSource` |

### Import Order

```dart
// 1. Dart SDK
import 'dart:convert';
// 2. Flutter
import 'package:flutter/material.dart';
// 3. Third-party
import 'package:flutter_bloc/flutter_bloc.dart';
// 4. Project (always relative)
import '../../domain/entities/comment.dart';
```

### BLoC Rules

- One BLoC/Cubit per feature concern (not per page)
- States: always `@freezed` sealed classes
- Events: always `sealed class` (no Equatable needed)
- No `if/else` chains in widget `build()` → use `switch` pattern matching on state
- Never emit loading state if the operation is < 100ms (causes flicker)
- All BLoC/Cubit instances are registered in DI, never `new`-ed manually

### Error Handling

- Domain/Data layer: always `Either<Failure, T>` from fpdart
- Presentation layer: unwrap with `.fold()` in BLoC, emit error state
- Widget: switch on error state, never show raw exception messages
- User-facing error messages: friendly text in the Failure class, not stack traces

### JSON in SQLite

- List fields (tags, platforms, etc.) stored as JSON strings
- Use `jsonEncode(list)` on write, `(jsonDecode(str) as List).cast<String>()` on read
- Helper extensions go in `core/utils/extensions.dart`

---

## 17. Environment & Build Config

### android/app/build.gradle

```groovy
android {
  defaultConfig {
    applicationId "com.linkedif.socialbox"
    minSdkVersion 21         // WorkManager + SecureStorage requirement
    targetSdkVersion 34
    manifestPlaceholders += ['appAuthRedirectScheme': 'com.linkedif.socialbox']
  }
}
```

### AndroidManifest.xml (add to `<application>`)

```xml
<!-- For exact alarms (notifications) -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<!-- For notifications on Android 13+ -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<!-- For internet (API posting) -->
<uses-permission android:name="android.permission.INTERNET" />
```

### AppConstants

```dart
// core/constants/app_constants.dart
class AppConstants {
  AppConstants._();

  static const String packageId = 'com.linkedif.socialbox';
  static const String dbName = 'socialbox.db';
  static const int dbVersion = 1;

  // OAuth Redirect URIs
  static const String oauthScheme = 'com.linkedif.socialbox';
  static const String twitterRedirect = '$oauthScheme://oauth/twitter';
  static const String linkedinRedirect = '$oauthScheme://oauth/linkedin';
  static const String facebookRedirect = '$oauthScheme://oauth/facebook';

  // Notification
  static const String remindersChannelId = 'reminders_channel';
  static const String postingChannelId = 'posting_channel';

  // WorkManager
  static const String scheduledPostingTask = 'socialbox_scheduled_posting';

  // Limits
  static const int maxCommentLength = 2000;
  static const int maxPostContentLength = 5000;
  static const int maxTagsPerItem = 10;
}
```

---

## 18. Extension Points (Future Features)

The architecture is designed for extension. All switches on `SocialPlatform` are the single change point for new platforms.

| Feature | Extension Point |
|---------|----------------|
| New platform (Instagram, TikTok) | Add enum value → `PostRemoteDataSource` impl → OAuth flow → `SocialPlatform` switch stmts |
| AI comment generation | New use case `GenerateComments` → calls external AI API → saves to category |
| Cloud sync / team accounts | Swap `LocalDataSource` implementations for Remote; add Supabase/Firebase datasources |
| Post analytics | Add `PostAnalyticsDao` + `GetPostAnalytics` use case → new Dashboard chart widget |
| Media library | Add `MediaTable` to Drift DB + new feature folder `media_library/` |
| Post templates | Add `PostTemplates` table + `GenerateFromTemplate` use case + template picker in PostForm |
| Bulk operations | Add `BulkDeletePosts` / `BulkMarkPosted` use cases |
| Windows desktop | Add `window_manager` dependency + Windows-specific `main_windows.dart` entry point |
| WhatsApp Business API | Add to `SocialPlatform` + WhatsApp Cloud API integration in `PostRemoteDataSource` |

---

## 19. Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Storage | Local-first (Drift/SQLite) | Offline-capable, no account required, privacy-friendly |
| State | BLoC + Cubit | Predictable, testable, separation of concerns |
| OAuth tokens | FlutterSecureStorage | AES-256, Android Keystore-backed |
| Background | WorkManager | Reliable on Android, survives process kill |
| Notifications | flutter_local_notifications | Full control, timezone-aware scheduling |
| Routing | GoRouter | Declarative, deep link support |
| HTTP | Dio | Auth interceptor, easy token injection |
| Error handling | fpdart Either | Type-safe, explicit, no hidden exceptions |
| JSON in DB | Encoded strings | Avoids extra junction tables for simple lists |
| Platforms in DB | Junction table | Normalized for easy per-platform log queries |
| Predefined data | Seeded on DB onCreate | Always available, works offline, no API needed |

---

*Last updated: Phase 0 — Planning complete, development not started*
*See STATUS.md for current session state*
