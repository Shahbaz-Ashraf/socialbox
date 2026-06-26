import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../posting_log/domain/entities/posting_log.dart';
import '../../../posting_log/domain/repositories/log_repository.dart';
import '../../domain/entities/social_post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_local_datasource.dart';
import '../models/social_post_model.dart';

const _uuid = Uuid();

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl(this._local, this._logRepository);
  final PostLocalDataSource _local;
  final LogRepository _logRepository;

  @override
  Stream<List<SocialPost>> watchAllPosts() {
    return _local.watchAll().asyncMap(_attachPlatforms);
  }

  @override
  Stream<List<SocialPost>> watchPostsByStatus(PostStatus status) {
    return _local.watchByStatus(status.name).asyncMap(_attachPlatforms);
  }

  @override
  Stream<SocialPost?> watchPostById(String id) {
    return _local.watchPostById(id).asyncMap((data) async {
      if (data == null) return null;
      final platforms = await _local.getPlatformsForPost(id);
      return data.toDomain(_parsePlatforms(platforms));
    });
  }

  @override
  Stream<List<SocialPost>> watchPostsInRange(DateTime start, DateTime end) {
    return _local
        .watchAll()
        .asyncMap((rows) async => _filterByRange(
              await _attachPlatforms(rows),
              start,
              end,
            ));
  }

  Future<List<SocialPost>> _attachPlatforms(List<SocialPostRow> rows) async {
    final out = <SocialPost>[];
    for (final r in rows) {
      final platforms = await _local.getPlatformsForPost(r.id);
      out.add(r.toDomain(_parsePlatforms(platforms)));
    }
    return out;
  }

  List<SocialPost> _filterByRange(
      List<SocialPost> posts, DateTime start, DateTime end) {
    return posts
        .where((p) =>
            p.scheduledAt != null &&
            !p.scheduledAt!.isBefore(start) &&
            p.scheduledAt!.isBefore(end))
        .toList();
  }

  List<SocialPlatform> _parsePlatforms(List<String> names) => names
      .map((n) => SocialPlatformX.fromName(n) ?? SocialPlatform.twitter)
      .toList();

  @override
  Future<Either<Failure, List<SocialPost>>> getAllPosts() async {
    try {
      return Right(await _attachPlatforms(await _local.getAllPosts()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SocialPost>> getPostById(String id) async {
    try {
      final data = await _local.getPostById(id);
      if (data == null) {
        return const Left(NotFoundFailure(message: 'Post not found.'));
      }
      final platforms = await _local.getPlatformsForPost(id);
      return Right(data.toDomain(_parsePlatforms(platforms)));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SocialPost>> createPost(CreatePostParams p) async {
    try {
      final now = DateTime.now();
      final entity = SocialPost(
        id: _uuid.v4(),
        title: p.title,
        content: p.content,
        platforms: p.platforms,
        status: p.status,
        scheduledAt: p.scheduledAt,
        isRecurring: p.isRecurring,
        recurringType: p.recurringType,
        recurringDays: p.recurringDays,
        attachments: p.attachments,
        tags: p.tags,
        notes: p.notes,
        createdAt: now,
        updatedAt: now,
      );
      await _local.insertPost(
        entity.toCompanion(),
        entity.platforms.map((e) => e.name).toList(),
      );
      return Right(entity);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SocialPost>> updatePost(UpdatePostParams p) async {
    try {
      final existing = await _local.getPostById(p.id);
      if (existing == null) {
        return const Left(NotFoundFailure(message: 'Post not found.'));
      }
      final entity = SocialPost(
        id: p.id,
        title: p.title,
        content: p.content,
        platforms: p.platforms,
        status: p.status,
        scheduledAt: p.scheduledAt,
        isRecurring: p.isRecurring,
        recurringType: p.recurringType,
        recurringDays: p.recurringDays,
        attachments: p.attachments,
        tags: p.tags,
        notes: p.notes,
        createdAt: p.createdAt,
        updatedAt: DateTime.now(),
      );
      await _local.updatePost(
        entity.toCompanion(),
        entity.platforms.map((e) => e.name).toList(),
      );
      return Right(entity);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePost(String id) async {
    try {
      await _local.deletePost(id);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SocialPost>> updateStatus(
      String id, PostStatus status) async {
    try {
      await _local.updateStatus(id, status.name);
      return getPostById(id);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markPostedManually({
    required String postId,
    required SocialPlatform platform,
    String? notes,
  }) async {
    try {
      await _logRepository.createLog(CreateLogParams(
        postId: postId,
        platform: platform,
        status: LogStatus.posted,
        method: PostingMethod.manual,
        postedAt: DateTime.now(),
        notes: notes,
      ));
      await _recalculateStatus(postId);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  Future<void> _recalculateStatus(String postId) async {
    final logsResult = await _logRepository.getLogsForPost(postId);
    final postResult = await _local.getPostById(postId);
    if (postResult == null) return;
    final post = postResult;
    logsResult.fold(
      (_) {},
      (logs) async {
        final postedPlatforms =
            logs.where((l) => l.status == LogStatus.posted).toList();
        final failedPlatforms =
            logs.where((l) => l.status == LogStatus.failed).toList();
        final targetPlatforms = await _local.getPlatformsForPost(postId);

        PostStatus newStatus;
        if (postedPlatforms.length == targetPlatforms.length &&
            targetPlatforms.isNotEmpty) {
          newStatus = PostStatus.posted;
        } else if (failedPlatforms.isNotEmpty &&
            postedPlatforms.isEmpty) {
          newStatus = PostStatus.failed;
        } else if (postedPlatforms.isNotEmpty ||
            failedPlatforms.isNotEmpty) {
          newStatus = PostStatus.partial;
        } else {
          newStatus = post.scheduledAt != null &&
                  post.scheduledAt!.isAfter(DateTime.now())
              ? PostStatus.scheduled
              : PostStatus.draft;
        }
        await _local.updateStatus(postId, newStatus.name);
      },
    );
  }
}
