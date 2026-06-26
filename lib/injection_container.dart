import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/app_database.dart';
import 'core/services/clipboard_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/secure_storage_service.dart';
import 'features/ai_prompts/data/datasources/prompt_datasource.dart';
import 'features/ai_prompts/data/repositories/prompt_repository_impl.dart';
import 'features/ai_prompts/domain/repositories/prompt_repository.dart';
import 'features/ai_prompts/domain/usecases/prompt_usecases.dart';
import 'features/ai_prompts/presentation/cubit/ai_prompt_cubit.dart';
import 'features/comment_templates/data/datasources/comment_local_datasource.dart';
import 'features/comment_templates/data/repositories/comment_repository_impl.dart';
import 'features/comment_templates/domain/repositories/comment_repository.dart';
import 'features/comment_templates/domain/usecases/category_usecases.dart';
import 'features/comment_templates/domain/usecases/comment_usecases.dart';
import 'features/comment_templates/domain/usecases/get_all_categories.dart';
import 'features/comment_templates/presentation/cubit/category_cubit.dart';
import 'features/comment_templates/presentation/cubit/comment_cubit.dart';
import 'features/hashtags/data/datasources/hashtag_datasource.dart';
import 'features/hashtags/data/repositories/hashtag_repository_impl.dart';
import 'features/hashtags/data/services/hashtag_service.dart';
import 'features/hashtags/domain/repositories/hashtag_repository.dart';
import 'features/hashtags/domain/usecases/hashtag_usecases.dart';
import 'features/hashtags/presentation/cubit/hashtag_suggestions_cubit.dart';
import 'features/posting_log/data/datasources/log_local_datasource.dart';
import 'features/posting_log/data/repositories/log_repository_impl.dart';
import 'features/posting_log/domain/repositories/log_repository.dart';
import 'features/posting_log/domain/usecases/log_usecases.dart';
import 'features/posts/data/datasources/post_local_datasource.dart';
import 'features/posts/data/repositories/post_repository_impl.dart';
import 'features/posts/domain/repositories/post_repository.dart';
import 'features/posts/domain/usecases/post_date_usecases.dart';
import 'features/posts/domain/usecases/post_usecases.dart';
import 'features/posts/domain/usecases/publish_via_api.dart';
import 'features/posts/presentation/bloc/post_list_bloc.dart';
import 'features/posts/presentation/cubit/post_detail_cubit.dart';
import 'features/posts/presentation/cubit/post_form_cubit.dart';
import 'features/posting_log/presentation/cubit/log_cubit.dart';
import 'features/reminders/data/datasources/reminder_local_datasource.dart';
import 'features/reminders/data/repositories/reminder_repository_impl.dart';
import 'features/reminders/domain/repositories/reminder_repository.dart';
import 'features/reminders/domain/usecases/reminder_date_usecases.dart';
import 'features/reminders/domain/usecases/reminder_usecases.dart';
import 'features/reminders/presentation/bloc/reminder_bloc.dart';
import 'features/settings/data/datasources/settings_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/domain/usecases/settings_usecases.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/social_auth/data/datasources/social_auth_datasource.dart';
import 'features/social_auth/data/deep_link_handler.dart';
import 'features/social_auth/data/repositories/auth_repository_impl.dart';
import 'features/social_auth/data/services/oauth_service.dart';
import 'features/social_auth/domain/repositories/auth_repository.dart';
import 'features/social_auth/domain/usecases/auth_usecases.dart';
import 'features/social_auth/presentation/bloc/auth_bloc.dart';

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
  getIt.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(getIt<SettingsDataSource>()));
  getIt.registerFactory<GetSettings>(() => GetSettings(getIt()));
  getIt.registerFactory<UpdateSettings>(() => UpdateSettings(getIt()));
  getIt.registerFactory<ExportCommentsCsv>(
      () => ExportCommentsCsv(getIt<CommentRepository>()));
  getIt.registerLazySingleton<SettingsCubit>(() => SettingsCubit(
        getSettings: getIt(),
        updateSettings: getIt(),
        exportCommentsCsv: getIt(),
        clipboard: getIt(),
      ));

  getIt.registerLazySingleton<PromptDataSource>(
      () => PromptDataSource(getIt<SharedPreferences>()));
  getIt.registerLazySingleton<PromptRepository>(
      () => PromptRepositoryImpl(getIt<PromptDataSource>()));
  getIt.registerFactory<LoadPromptTemplate>(() => LoadPromptTemplate(getIt()));
  getIt.registerFactory<SavePromptTemplate>(() => SavePromptTemplate(getIt()));
  getIt.registerFactory<ResetPromptTemplate>(() => ResetPromptTemplate(getIt()));
  getIt.registerFactory<LoadLastPromptConfig>(
      () => LoadLastPromptConfig(getIt()));
  getIt.registerFactory<SaveLastPromptConfig>(
      () => SaveLastPromptConfig(getIt()));
  getIt.registerFactory<LoadPromptPresets>(() => LoadPromptPresets(getIt()));
  getIt.registerFactory<SavePromptPresets>(() => SavePromptPresets(getIt()));
  getIt.registerFactory<AiPromptCubit>(() => AiPromptCubit(
        repository: getIt(),
        loadLastConfig: getIt(),
        saveLastConfig: getIt(),
        loadTemplate: getIt(),
        saveTemplate: getIt(),
        resetTemplate: getIt(),
        loadPresets: getIt(),
        savePresets: getIt(),
        clipboard: getIt(),
      ));

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
        getIt<SettingsRepository>(),
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
  getIt.registerFactory<HashtagSuggestionsCubit>(() => HashtagSuggestionsCubit(
        watchTopHashtagSuggestions: getIt<WatchTopHashtagSuggestions>(),
      ));

  // UseCases: Auth ----------------------------------------------------
  getIt.registerFactory<GetConnectedAccounts>(
      () => GetConnectedAccounts(getIt()));
  getIt.registerFactory<DisconnectPlatform>(() => DisconnectPlatform(getIt()));
  getIt.registerFactory<RefreshAccessToken>(
      () => RefreshAccessToken(getIt()));
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));

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
  getIt.registerFactory<CategoryCubit>(() => CategoryCubit(
        repository: getIt(),
        getAllCategories: getIt(),
        createCategory: getIt(),
        updateCategory: getIt(),
        deleteCategory: getIt(),
        searchComments: getIt(),
        incrementUsageCount: getIt(),
        clipboard: getIt(),
      ));
  getIt.registerFactoryParam<CommentCubit, String, void>(
    (categoryId, _) {
      final cubit = CommentCubit(
        repository: getIt(),
        createComment: getIt(),
        updateComment: getIt(),
        deleteComment: getIt(),
        toggleFavorite: getIt(),
        incrementUsageCount: getIt(),
        clipboard: getIt(),
        watchByCategory: getIt<CommentRepository>().watchCommentsByCategory,
      );
      cubit.watchCategory(categoryId);
      return cubit;
    },
  );

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
  getIt.registerFactory<PublishViaApi>(() => PublishViaApi(
        getIt<SettingsRepository>(),
        getIt<AuthRepository>(),
      ));

  getIt.registerFactoryParam<PostDetailCubit, String, void>(
    (postId, _) => PostDetailCubit(
      postId: postId,
      getPostById: getIt(),
      markPostedManually: getIt(),
      deletePost: getIt(),
      duplicatePost: getIt(),
      publishViaApi: getIt(),
      clipboard: getIt(),
    ),
  );
  getIt.registerFactory<PostFormCubit>(() => PostFormCubit(
        createPost: getIt(),
        updatePost: getIt(),
        getPostById: getIt(),
        recordHashtagUsage: getIt(),
        extractHashtags: getIt(),
        clipboard: getIt(),
      ));
  getIt.registerFactory<PostListBloc>(() => PostListBloc(
        repository: getIt<PostRepository>(),
        markPostedManually: getIt(),
        deletePost: getIt(),
        publishViaApi: getIt(),
        clipboard: getIt(),
      ));

  // Posting Log ------------------------------------------------------
  getIt.registerLazySingleton<LogLocalDataSource>(
      () => LogLocalDataSource(getIt<AppDatabase>()));
  getIt.registerLazySingleton<LogRepository>(
      () => LogRepositoryImpl(getIt<LogLocalDataSource>()));

  getIt.registerFactory<GetLogsForPost>(() => GetLogsForPost(getIt()));
  getIt.registerFactory<GetAllLogs>(() => GetAllLogs(getIt()));
  getIt.registerFactory<CreateLogEntry>(() => CreateLogEntry(getIt()));
  getIt.registerFactory<UpdateLogStatus>(() => UpdateLogStatus(getIt()));
  getIt.registerFactory<DeleteLog>(() => DeleteLog(getIt()));
  getIt.registerFactory<LogCubit>(() => LogCubit(
        repository: getIt(),
        updateLogStatus: getIt(),
        clipboard: getIt(),
      ));

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
  getIt.registerFactory<ReminderBloc>(() => ReminderBloc(
        repository: getIt<ReminderRepository>(),
        notificationService: getIt<NotificationService>(),
        settingsRepository: getIt<SettingsRepository>(),
        getAllPosts: getIt(),
      ));

  // Dashboard ---------------------------------------------------------
  getIt.registerFactory<GetDashboardStats>(() => GetDashboardStats(
        postRepo: getIt(),
        commentRepo: getIt(),
        logRepo: getIt(),
        reminderRepo: getIt(),
      ));
  getIt.registerFactory<DashboardCubit>(() => DashboardCubit(
        getStats: getIt<GetDashboardStats>(),
        clipboard: getIt(),
      ));
}
