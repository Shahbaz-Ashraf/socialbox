import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/social_post.dart';
import '../../domain/usecases/post_date_usecases.dart';
import '../../domain/usecases/post_usecases.dart';
import '../../domain/usecases/publish_via_api.dart';

abstract class PostDetailState extends Equatable {
  const PostDetailState();
  @override
  List<Object?> get props => [];
}

class PostDetailInitial extends PostDetailState {
  const PostDetailInitial();
}

class PostDetailLoading extends PostDetailState {
  const PostDetailLoading();
}

class PostDetailLoaded extends PostDetailState {
  const PostDetailLoaded(this.post);
  final SocialPost post;
  @override
  List<Object?> get props => [post];
}

class PostDetailNotFound extends PostDetailState {
  const PostDetailNotFound();
}

class PostDetailError extends PostDetailState {
  const PostDetailError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class PostDetailActionInProgress extends PostDetailState {
  const PostDetailActionInProgress(this.post);
  final SocialPost post;
  @override
  List<Object?> get props => [post];
}

class PostDetailCubit extends Cubit<PostDetailState> {
  PostDetailCubit({
    required this.postId,
    required GetPostById getPostById,
    required MarkPostedManually markPostedManually,
    required DeletePost deletePost,
    required DuplicatePost duplicatePost,
    required PublishViaApi publishViaApi,
  })  : _getPostById = getPostById,
        _markPostedManually = markPostedManually,
        _deletePost = deletePost,
        _duplicatePost = duplicatePost,
        _publishViaApi = publishViaApi,
        super(const PostDetailInitial());

  final String postId;
  final GetPostById _getPostById;
  final MarkPostedManually _markPostedManually;
  final DeletePost _deletePost;
  final DuplicatePost _duplicatePost;
  final PublishViaApi _publishViaApi;

  Future<void> load() async {
    emit(const PostDetailLoading());
    final r = await _getPostById(postId);
    r.fold(
      (f) => emit(PostDetailError(f.message)),
      (p) => emit(PostDetailLoaded(p)),
    );
  }

  Future<String?> publishViaApi({required SocialPlatform platform}) async {
    final current = state;
    if (current is! PostDetailLoaded) return 'Post not loaded.';
    emit(PostDetailActionInProgress(current.post));
    final r = await _publishViaApi(PublishViaApiParams(
      postId: postId,
      platform: platform,
    ));
    return r.fold(
      (f) {
        emit(PostDetailLoaded(current.post));
        return f.message;
      },
      (_) async {
        await load();
        return null;
      },
    );
  }

  Future<bool> markPosted({
    required SocialPlatform platform,
    String? notes,
  }) async {
    final current = state;
    if (current is! PostDetailLoaded) return false;
    emit(PostDetailActionInProgress(current.post));
    final r = await _markPostedManually(MarkPostedManuallyParams(
      postId: postId,
      platform: platform,
      notes: notes,
    ));
    return r.fold(
      (f) {
        emit(PostDetailError(f.message));
        return false;
      },
      (_) async {
        await load();
        return true;
      },
    );
  }

  Future<bool> deletePost() async {
    final r = await _deletePost(postId);
    return r.isRight();
  }

  Future<String?> duplicate() async {
    final r = await _duplicatePost(postId);
    return r.fold((_) => null, (p) => p.id);
  }

  SocialPost? get currentPost {
    final s = state;
    if (s is PostDetailLoaded) return s.post;
    if (s is PostDetailActionInProgress) return s.post;
    return null;
  }
}