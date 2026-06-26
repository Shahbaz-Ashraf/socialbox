import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/social_post.dart';
import '../repositories/post_repository.dart';

class WatchAllPosts extends StreamUseCase<List<SocialPost>, NoParams> {
  WatchAllPosts(this._repo);
  final PostRepository _repo;

  @override
  Stream<Either<Failure, List<SocialPost>>> call(NoParams params) {
    return _repo
        .watchAllPosts()
        .map((list) => Right<Failure, List<SocialPost>>(list));
  }
}