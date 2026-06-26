import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/platform_utils.dart';
import '../entities/social_post.dart';

class CreatePostParams {
  const CreatePostParams({
    required this.title,
    required this.content,
    required this.platforms,
    required this.status,
    this.scheduledAt,
    this.isRecurring = false,
    this.recurringType = RecurringType.none,
    this.recurringDays = const [],
    this.attachments = const [],
    this.tags = const [],
    this.notes,
  });

  final String title;
  final String content;
  final List<SocialPlatform> platforms;
  final PostStatus status;
  final DateTime? scheduledAt;
  final bool isRecurring;
  final RecurringType recurringType;
  final List<int> recurringDays;
  final List<String> attachments;
  final List<String> tags;
  final String? notes;
}

class UpdatePostParams {
  const UpdatePostParams({
    required this.id,
    required this.title,
    required this.content,
    required this.platforms,
    required this.status,
    this.scheduledAt,
    this.isRecurring = false,
    this.recurringType = RecurringType.none,
    this.recurringDays = const [],
    this.attachments = const [],
    this.tags = const [],
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final List<SocialPlatform> platforms;
  final PostStatus status;
  final DateTime? scheduledAt;
  final bool isRecurring;
  final RecurringType recurringType;
  final List<int> recurringDays;
  final List<String> attachments;
  final List<String> tags;
  final String? notes;
  final DateTime createdAt;
}

abstract class PostRepository {
  Stream<List<SocialPost>> watchAllPosts();
  Stream<List<SocialPost>> watchPostsByStatus(PostStatus status);
  Stream<SocialPost?> watchPostById(String id);
  Stream<List<SocialPost>> watchPostsInRange(DateTime start, DateTime end);
  Future<Either<Failure, List<SocialPost>>> getAllPosts();
  Future<Either<Failure, SocialPost>> getPostById(String id);
  Future<Either<Failure, SocialPost>> createPost(CreatePostParams params);
  Future<Either<Failure, SocialPost>> updatePost(UpdatePostParams params);
  Future<Either<Failure, Unit>> deletePost(String id);
  Future<Either<Failure, SocialPost>> updateStatus(String id, PostStatus status);
  Future<Either<Failure, Unit>> markPostedManually({
    required String postId,
    required SocialPlatform platform,
    String? notes,
  });
}
