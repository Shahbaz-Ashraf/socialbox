import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/platform_utils.dart';
import '../entities/social_post.dart';
import '../repositories/post_repository.dart';

class GetAllPosts extends UseCase<List<SocialPost>, NoParams> {
  GetAllPosts(this._repo);
  final PostRepository _repo;

  @override
  Future<Either<Failure, List<SocialPost>>> call(NoParams params) =>
      _repo.getAllPosts();
}

class GetPostsByStatus extends UseCase<List<SocialPost>, PostStatus> {
  GetPostsByStatus(this._repo);
  final PostRepository _repo;

  @override
  Future<Either<Failure, List<SocialPost>>> call(PostStatus params) =>
      _repo.getAllPosts();
}

class GetPostById extends UseCase<SocialPost, String> {
  GetPostById(this._repo);
  final PostRepository _repo;

  @override
  Future<Either<Failure, SocialPost>> call(String params) =>
      _repo.getPostById(params);
}

class CreatePost extends UseCase<SocialPost, CreatePostParams> {
  CreatePost(this._repo);
  final PostRepository _repo;

  @override
  Future<Either<Failure, SocialPost>> call(CreatePostParams params) =>
      _repo.createPost(params);
}

class UpdatePost extends UseCase<SocialPost, UpdatePostParams> {
  UpdatePost(this._repo);
  final PostRepository _repo;

  @override
  Future<Either<Failure, SocialPost>> call(UpdatePostParams params) =>
      _repo.updatePost(params);
}

class DeletePost extends UseCase<Unit, String> {
  DeletePost(this._repo);
  final PostRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(String params) => _repo.deletePost(params);
}

class MarkPostedManuallyParams {
  const MarkPostedManuallyParams({
    required this.postId,
    required this.platform,
    this.notes,
  });
  final String postId;
  final SocialPlatform platform;
  final String? notes;
}

class MarkPostedManually extends UseCase<Unit, MarkPostedManuallyParams> {
  MarkPostedManually(this._repo);
  final PostRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(MarkPostedManuallyParams params) =>
      _repo.markPostedManually(
        postId: params.postId,
        platform: params.platform,
        notes: params.notes,
      );
}
