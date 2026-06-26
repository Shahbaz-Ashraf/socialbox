import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/clipboard_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/post_usecases.dart';
import '../../domain/usecases/publish_via_api.dart';
import '../cubit/post_list_cubit.dart';

abstract class PostListEvent extends Equatable {
  const PostListEvent();
  @override
  List<Object?> get props => [];
}

class PostListLoad extends PostListEvent {
  const PostListLoad();
}

class PostListReload extends PostListEvent {
  const PostListReload();
}

class PostListDelete extends PostListEvent {
  const PostListDelete(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class PostListMarkPosted extends PostListEvent {
  const PostListMarkPosted({
    required this.postId,
    required this.platform,
    this.notes,
  });

  final String postId;
  final SocialPlatform platform;
  final String? notes;

  @override
  List<Object?> get props => [postId, platform, notes];
}

class PostListPublishViaApi extends PostListEvent {
  const PostListPublishViaApi({
    required this.postId,
    required this.platform,
  });

  final String postId;
  final SocialPlatform platform;

  @override
  List<Object?> get props => [postId, platform];
}

class PostListBloc extends Bloc<PostListEvent, PostListState> {
  PostListBloc({
    required this.repository,
    required this.markPostedManually,
    required this.deletePost,
    required this.publishViaApi,
    required this.clipboard,
    required this.notificationService,
    required this.settingsRepository,
  }) : super(const PostListInitial()) {
    on<PostListLoad>(_onLoad);
    on<PostListReload>(_onReload);
    on<PostListDelete>(_onDelete);
    on<PostListMarkPosted>(_onMarkPosted);
    on<PostListPublishViaApi>(_onPublishViaApi);
    add(const PostListLoad());
  }

  final PostRepository repository;
  final MarkPostedManually markPostedManually;
  final DeletePost deletePost;
  final PublishViaApi publishViaApi;
  final ClipboardService clipboard;
  final NotificationService notificationService;
  final SettingsRepository settingsRepository;

  StreamSubscription? _sub;

  Future<void> copyContent(BuildContext context, String content) =>
      clipboard.copyText(context, content);

  Future<void> _onLoad(PostListLoad event, Emitter<PostListState> emit) async {
    await _subscribe(emit);
  }

  Future<void> _onReload(
      PostListReload event, Emitter<PostListState> emit) async {
    emit(const PostListLoading());
    await _subscribe(emit);
  }

  Future<void> _subscribe(Emitter<PostListState> emit) async {
    await _sub?.cancel();
    _sub = repository.watchAllPosts().listen((posts) {
      final s = state;
      if (s is PostListLoaded) {
        emit(s.copyWith(posts: posts));
      } else {
        emit(PostListLoaded(posts: posts));
      }
    });
  }

  Future<void> _onDelete(
      PostListDelete event, Emitter<PostListState> emit) async {
    await deletePost(event.id);
  }

  Future<void> _onMarkPosted(
      PostListMarkPosted event, Emitter<PostListState> emit) async {
    final s = state;
    if (s is! PostListLoaded) return;
    emit(s.copyWith(isActionInProgress: true));
    await markPostedManually(MarkPostedManuallyParams(
      postId: event.postId,
      platform: event.platform,
      notes: event.notes,
    ));
    final current = state;
    if (current is PostListLoaded) {
      emit(current.copyWith(isActionInProgress: false));
    }
  }

  Future<void> _onPublishViaApi(
      PostListPublishViaApi event, Emitter<PostListState> emit) async {
    final s = state;
    if (s is! PostListLoaded) return;
    emit(s.copyWith(isActionInProgress: true));
    final result = await publishViaApi(PublishViaApiParams(
      postId: event.postId,
      platform: event.platform,
    ));
    result.fold(
      (f) => _notifyPublishResult(
        platform: event.platform,
        isSuccess: false,
        message: f.message,
      ),
      (_) => _notifyPublishResult(
        platform: event.platform,
        isSuccess: true,
      ),
    );
    final current = state;
    if (current is PostListLoaded) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: result.fold((f) => f.message, (_) => null),
      ));
    }
  }

  void _notifyPublishResult({
    required SocialPlatform platform,
    required bool isSuccess,
    String? message,
  }) {
    if (!settingsRepository.getSettings().enableNotifications) return;
    unawaited(
      notificationService.showPostingResult(
        title: isSuccess
            ? 'Posted to ${platform.displayName}'
            : 'Post failed on ${platform.displayName}',
        body: message ??
            (isSuccess
                ? 'Your post was published successfully.'
                : 'Publishing did not complete.'),
        isSuccess: isSuccess,
      ),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}