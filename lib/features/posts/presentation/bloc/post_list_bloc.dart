import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/post_usecases.dart';
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

class PostListBloc extends Bloc<PostListEvent, PostListState> {
  PostListBloc({
    required this.repository,
    required this.markPostedManually,
    required this.deletePost,
  }) : super(const PostListInitial()) {
    on<PostListLoad>(_onLoad);
    on<PostListReload>(_onReload);
    on<PostListDelete>(_onDelete);
    on<PostListMarkPosted>(_onMarkPosted);
    add(const PostListLoad());
  }

  final PostRepository repository;
  final MarkPostedManually markPostedManually;
  final DeletePost deletePost;

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

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}