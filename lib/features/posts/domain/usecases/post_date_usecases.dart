import 'package:fpdart/fpdart.dart';

import '../../../../core/domain/date_range.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/platform_utils.dart';
import '../entities/social_post.dart';
import '../repositories/post_repository.dart';

class GetPostsInRange extends UseCase<List<SocialPost>, DateRange> {
  GetPostsInRange(this._repo);
  final PostRepository _repo;

  @override
  Future<Either<Failure, List<SocialPost>>> call(DateRange params) async {
    final all = await _repo.getAllPosts();
    return all.fold(
      (f) => Left<Failure, List<SocialPost>>(f),
      (posts) {
        final filtered = posts
            .where((p) =>
                p.scheduledAt != null &&
                !p.scheduledAt!.isBefore(params.start) &&
                p.scheduledAt!.isBefore(params.end))
            .toList();
        return Right(filtered);
      },
    );
  }
}

class DuplicatePost extends UseCase<SocialPost, String> {
  DuplicatePost(this._repo);
  final PostRepository _repo;

  @override
  Future<Either<Failure, SocialPost>> call(String params) async {
    final postResult = await _repo.getPostById(params);
    return postResult.fold(
      (f) async => Left<Failure, SocialPost>(f),
      (post) async {
        return _repo.createPost(CreatePostParams(
          title: '${post.title} (Copy)',
          content: post.content,
          platforms: post.platforms,
          status: PostStatus.draft,
          scheduledAt: null,
          isRecurring: false,
          attachments: post.attachments,
          tags: post.tags,
          notes: post.notes,
        ));
      },
    );
  }
}
