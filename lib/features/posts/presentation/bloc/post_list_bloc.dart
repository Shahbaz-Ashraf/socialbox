import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/platform_utils.dart';
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

  StreamSubscription? _sub;

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
    final current = state;
    if (current is PostListLoaded) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: result.fold((f) => f.message, (_) => null),
      ));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}