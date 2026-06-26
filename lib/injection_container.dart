import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/app_database.dart';
import 'core/services/clipboard_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/secure_storage_service.dart';
import 'features/comment_templates/data/datasources/comment_local_datasource.dart';
import 'features/comment_templates/data/repositories/comment_repository_impl.dart';
import 'features/comment_templates/domain/repositories/comment_repository.dart';
import 'features/comment_templates/domain/usecases/category_usecases.dart';
import 'features/comment_templates/domain/usecases/comment_usecases.dart';
import 'features/comment_templates/domain/usecases/get_all_categories.dart';
import 'features/hashtags/data/datasources/hashtag_datasource.dart';
import 'features/hashtags/data/repositories/hashtag_repository_impl.dart';
import 'features/hashtags/data/services/hashtag_service.dart';
import 'features/hashtags/domain/repositories/hashtag_repository.dart';
import 'features/hashtags/domain/usecases/hashtag_usecases.dart';
import 'features/posting_log/data/datasources/log_local_datasource.dart';
import 'features/posting_log/data/repositories/log_repository_impl.dart';
import 'features/posting_log/domain/repositories/log_repository.dart';
import 'features/posting_log/domain/usecases/log_usecases.dart';
import 'features/posts/data/datasources/post_local_datasource.dart';
import 'features/posts/data/repositories/post_repository_impl.dart';
import 'features/posts/domain/repositories/post_repository.dart';
import 'features/posts/domain/usecases/post_date_usecases.dart';
import 'features/posts/domain/usecases/post_usecases.dart';
import 'features/reminders/data/datasources/reminder_local_datasource.dart';
import 'features/reminders/data/repositories/reminder_repository_impl.dart';
import 'features/reminders/domain/repositories/reminder_repository.dart';
import 'features/reminders/domain/usecases/reminder_date_usecases.dart';
import 'features/reminders/domain/usecases/reminder_usecases.dart';
import 'features/settings/data/datasources/settings_datasource.dart';
import 'features/social_auth/data/datasources/social_auth_datasource.dart';
import 'features/social_auth/data/deep_link_handler.dart';
import 'features/social_auth/data/repositories/auth_repository_impl.dart';
import 'features/social_auth/data/services/oauth_service.dart';
import 'features/social_auth/domain/repositories/auth_repository.dart';
import 'features/social_auth/domain/usecases/auth_usecases.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<AppDatabase>()) return;

  // Database ----------------------------------------------------------
  getIt.registerSingleton<AppDatabase>(AppDatabase());

  // Shared prefs ------------------------------------------------------
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Core services -----------------------------------------------------
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<ClipboardService>(() => ClipboardService());
  getIt.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  getIt.registerLazySingleton<SettingsDataSource>(
      () => SettingsDataSource(getIt<SharedPreferences>()));

  // Social Auth -------------------------------------------------------
  getIt.registerLazySingleton<DeepLinkHandler>(() => DeepLinkHandler());
  getIt.registerLazySingleton<OAuthService>(() => OAuthService(
        deepLinkHandler: getIt<DeepLinkHandler>(),
      ));
  getIt.registerLazySingleton<SocialAuthDataSource>(
      () => SocialAuthDataSource(getIt<SecureStorageService>()));
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        getIt<SocialAuthDataSource>(),
        getIt<OAuthService>(),
      ));

  // Hashtag Suggestions -----------------------------------------------
  getIt.registerLazySingleton<HashtagLocalDataSource>(
      () => HashtagLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton<HashtagRepository>(
      () => HashtagRepositoryImpl(getIt<HashtagLocalDataSource>()));
  getIt.registerLazySingleton<HashtagService>(
      () => HashtagService(getIt<HashtagRepository>()));

  getIt.registerFactory<RecordHashtagUsage>(
      () => RecordHashtagUsage(getIt<HashtagRepository>()));
  getIt.registerFactory<GetTopHashtagSuggestions>(
      () => GetTopHashtagSuggestions(getIt<HashtagRepository>()));
  getIt.registerFactory<WatchTopHashtagSuggestions>(
      () => WatchTopHashtagSuggestions(getIt<HashtagRepository>()));
  getIt.registerFactory<ExtractHashtags>(
      () => ExtractHashtags(getIt<HashtagRepository>()));

  // UseCases: Auth ----------------------------------------------------
  getIt.registerFactory<GetConnectedAccounts>(
      () => GetConnectedAccounts(getIt()));
  getIt.registerFactory<DisconnectPlatform>(() => DisconnectPlatform(getIt()));
  getIt.registerFactory<RefreshAccessToken>(
      () => RefreshAccessToken(getIt()));

  // Comment Templates -------------------------------------------------
  getIt.registerLazySingleton<CommentLocalDataSource>(
      () => CommentLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton<CommentRepository>(
      () => CommentRepositoryImpl(getIt<CommentLocalDataSource>()));

  getIt.registerFactory<GetAllCategories>(() => GetAllCategories(getIt()));
  getIt.registerFactory<CreateCategory>(() => CreateCategory(getIt()));
  getIt.registerFactory<UpdateCategory>(() => UpdateCategory(getIt()));
  getIt.registerFactory<DeleteCategory>(() => DeleteCategory(getIt()));
  getIt.registerFactory<GetCommentsByCategory>(
      () => GetCommentsByCategory(getIt()));
  getIt.registerFactory<SearchComments>(() => SearchComments(getIt()));
  getIt.registerFactory<CreateComment>(() => CreateComment(getIt()));
  getIt.registerFactory<UpdateComment>(() => UpdateComment(getIt()));
  getIt.registerFactory<DeleteComment>(() => DeleteComment(getIt()));
  getIt.registerFactory<ToggleFavorite>(() => ToggleFavorite(getIt()));
  getIt.registerFactory<IncrementUsageCount>(
      () => IncrementUsageCount(getIt()));

  // Posts ------------------------------------------------------------
  getIt.registerLazySingleton<PostLocalDataSource>(
      () => PostLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton<PostRepository>(() => PostRepositoryImpl(
        getIt<PostLocalDataSource>(),
        getIt<LogRepository>(),
      ));

  getIt.registerFactory<GetAllPosts>(() => GetAllPosts(getIt()));
  getIt.registerFactory<GetPostsByStatus>(() => GetPostsByStatus(getIt()));
  getIt.registerFactory<GetPostById>(() => GetPostById(getIt()));
  getIt.registerFactory<CreatePost>(() => CreatePost(getIt()));
  getIt.registerFactory<UpdatePost>(() => UpdatePost(getIt()));
  getIt.registerFactory<DeletePost>(() => DeletePost(getIt()));
  getIt.registerFactory<MarkPostedManually>(
      () => MarkPostedManually(getIt()));
  getIt.registerFactory<GetPostsInRange>(
      () => GetPostsInRange(getIt()));
  getIt.registerFactory<DuplicatePost>(() => DuplicatePost(getIt()));

  // Posting Log ------------------------------------------------------
  getIt.registerLazySingleton<LogLocalDataSource>(
      () => LogLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton<LogRepository>(
      () => LogRepositoryImpl(getIt<LogLocalDataSource>()));

  getIt.registerFactory<GetLogsForPost>(() => GetLogsForPost(getIt()));
  getIt.registerFactory<GetAllLogs>(() => GetAllLogs(getIt()));
  getIt.registerFactory<CreateLogEntry>(() => CreateLogEntry(getIt()));
  getIt.registerFactory<DeleteLog>(() => DeleteLog(getIt()));

  // Reminders --------------------------------------------------------
  getIt.registerLazySingleton<ReminderLocalDataSource>(
      () => ReminderLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton<ReminderRepository>(
      () => ReminderRepositoryImpl(getIt<ReminderLocalDataSource>()));

  getIt.registerFactory<GetAllReminders>(() => GetAllReminders(getIt()));
  getIt.registerFactory<GetRemindersForPost>(
      () => GetRemindersForPost(getIt()));
  getIt.registerFactory<CreateReminder>(() => CreateReminder(getIt()));
  getIt.registerFactory<UpdateReminder>(() => UpdateReminder(getIt()));
  getIt.registerFactory<DeleteReminder>(() => DeleteReminder(getIt()));
  getIt.registerFactory<ToggleReminder>(() => ToggleReminder(getIt()));
  getIt.registerFactory<GetRemindersInRange>(
      () => GetRemindersInRange(getIt()));
}
