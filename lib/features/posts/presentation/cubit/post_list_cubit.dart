import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/social_post.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/post_usecases.dart';

abstract class PostListState extends Equatable {
  const PostListState();
  @override
  List<Object?> get props => [];
}

class PostListInitial extends PostListState {
  const PostListInitial();
}

class PostListLoading extends PostListState {
  const PostListLoading();
}

class PostListLoaded extends PostListState {
  const PostListLoaded({
    required this.posts,
    this.activeFilter,
    this.isActionInProgress = false,
  });

  final List<SocialPost> posts;
  final PostStatus? activeFilter;
  final bool isActionInProgress;

  List<SocialPost> get visiblePosts {
    if (activeFilter == null) return posts;
    return posts.where((p) => p.status == activeFilter).toList();
  }

  PostListLoaded copyWith({
    List<SocialPost>? posts,
    PostStatus? activeFilter,
    bool? isActionInProgress,
    bool clearFilter = false,
  }) =>
      PostListLoaded(
        posts: posts ?? this.posts,
        activeFilter:
            clearFilter ? null : (activeFilter ?? this.activeFilter),
        isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      );

  @override
  List<Object?> get props => [posts, activeFilter, isActionInProgress];
}

class PostListError extends PostListState {
  const PostListError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class PostListCubit extends Cubit<PostListState> {
  PostListCubit({
    required this.repository,
    required this.markPostedManually,
    required this.deletePost,
  }) : super(const PostListInitial()) {
    _subscribe();
  }

  final PostRepository repository;
  final MarkPostedManually markPostedManually;
  final DeletePost deletePost;

  StreamSubscription? _sub;

  void _subscribe() {
    _sub?.cancel();
    _sub = repository.watchAllPosts().listen((posts) {
      final s = state;
      if (s is PostListLoaded) {
        emit(s.copyWith(posts: posts));
      } else {
        emit(PostListLoaded(posts: posts));
      }
    });
  }

  void reload() {
    emit(const PostListLoading());
    _subscribe();
  }

  void filterBy(PostStatus? status) {
    final s = state;
    if (s is PostListLoaded) {
      if (status == null) {
        emit(s.copyWith(clearFilter: true));
      } else {
        emit(s.copyWith(activeFilter: status));
      }
    }
  }

  Future<bool> delete(String id) async {
    final r = await deletePost(id);
    return r.isRight();
  }

  Future<bool> markPosted({
    required String postId,
    required SocialPlatform platform,
    String? notes,
  }) async {
    emit((state as PostListLoaded).copyWith(isActionInProgress: true));
    final r = await markPostedManually(MarkPostedManuallyParams(
      postId: postId,
      platform: platform,
      notes: notes,
    ));
    emit((state as PostListLoaded).copyWith(isActionInProgress: false));
    return r.isRight();
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
