import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:socialbox/core/services/clipboard_service.dart';
import 'package:socialbox/core/services/notification_service.dart';
import 'package:socialbox/core/utils/platform_utils.dart';
import 'package:socialbox/features/posts/domain/entities/social_post.dart';
import 'package:socialbox/features/posts/domain/repositories/post_repository.dart';
import 'package:socialbox/features/posts/domain/usecases/post_usecases.dart';
import 'package:socialbox/features/posts/domain/usecases/publish_via_api.dart';
import 'package:socialbox/features/posts/presentation/bloc/post_list_bloc.dart';
import 'package:socialbox/features/posts/presentation/cubit/post_list_cubit.dart';
import 'package:socialbox/features/settings/domain/entities/app_settings.dart';
import 'package:socialbox/features/settings/domain/entities/app_theme_mode.dart';
import 'package:socialbox/features/settings/domain/repositories/settings_repository.dart';

class MockPostRepository extends Mock implements PostRepository {}

class MockMarkPostedManually extends Mock implements MarkPostedManually {}

class MockDeletePost extends Mock implements DeletePost {}

class MockPublishViaApi extends Mock implements PublishViaApi {}

class MockClipboardService extends Mock implements ClipboardService {}

class MockNotificationService extends Mock implements NotificationService {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

SocialPost _samplePost({String id = 'p1'}) {
  final now = DateTime(2026, 6, 26);
  return SocialPost(
    id: id,
    title: 'Test',
    content: 'Body',
    platforms: const [SocialPlatform.linkedin],
    status: PostStatus.draft,
    scheduledAt: null,
    isRecurring: false,
    recurringType: RecurringType.none,
    recurringDays: const [],
    attachments: const [],
    tags: const [],
    notes: null,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late MockPostRepository repository;
  late StreamController<List<SocialPost>> postsController;
  late MockSettingsRepository settings;

  PostListBloc buildBloc() {
    return PostListBloc(
      repository: repository,
      markPostedManually: MockMarkPostedManually(),
      deletePost: MockDeletePost(),
      publishViaApi: MockPublishViaApi(),
      clipboard: MockClipboardService(),
      notificationService: MockNotificationService(),
      settingsRepository: settings,
    );
  }

  setUp(() {
    repository = MockPostRepository();
    postsController = StreamController<List<SocialPost>>.broadcast();
    settings = MockSettingsRepository();

    when(() => repository.watchAllPosts()).thenAnswer(
      (_) => postsController.stream,
    );
    when(() => settings.getSettings()).thenReturn(
      const AppSettings(
        defaultPlatforms: [],
        enableApiPosting: false,
        enableNotifications: false,
        themeMode: AppThemeMode.system,
        reminderLeadMinutes: 15,
        autoRefreshTokens: true,
      ),
    );
  });

  tearDown(() async {
    await postsController.close();
  });

  test('initial state is PostListInitial', () async {
    final bloc = buildBloc();
    expect(bloc.state, isA<PostListInitial>());
    await bloc.close();
  });

  blocTest<PostListBloc, PostListState>(
    'stream updates emit PostListLoaded without handler-after-complete error',
    build: buildBloc,
    act: (b) async {
      postsController.add([_samplePost()]);
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => [
      isA<PostListLoaded>().having(
        (s) => s.posts.length,
        'post count',
        1,
      ),
    ],
  );

  blocTest<PostListBloc, PostListState>(
    'reload shows loading then loaded when stream emits',
    build: buildBloc,
    seed: () => PostListLoaded(posts: [_samplePost()]),
    act: (b) async {
      b.add(const PostListReload());
      await Future<void>.delayed(Duration.zero);
      postsController.add([_samplePost(), _samplePost(id: 'p2')]);
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => [
      const PostListLoading(),
      isA<PostListLoaded>().having(
        (s) => s.posts.length,
        'post count',
        2,
      ),
    ],
  );

  blocTest<PostListBloc, PostListState>(
    'stream update preserves active filter on loaded state',
    build: buildBloc,
    seed: () => PostListLoaded(
      posts: [_samplePost()],
      activeFilter: PostStatus.draft,
    ),
    act: (b) async {
      postsController.add([
        _samplePost(),
        _samplePost(id: 'p2'),
      ]);
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => [
      isA<PostListLoaded>()
          .having((s) => s.posts.length, 'posts', 2)
          .having((s) => s.activeFilter, 'filter', PostStatus.draft),
    ],
  );
}