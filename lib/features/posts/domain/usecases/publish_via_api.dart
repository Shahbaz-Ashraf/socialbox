import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../posting_log/domain/entities/posting_log.dart';
import '../../../posting_log/domain/repositories/log_repository.dart';
import '../../../posting_log/domain/usecases/log_usecases.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../social_auth/domain/entities/connected_account.dart';
import '../../../social_auth/domain/repositories/auth_repository.dart';
import '../../data/datasources/post_remote_datasource.dart';
import '../../data/models/api_post_response_model.dart';
import '../entities/social_post.dart';
import '../repositories/post_repository.dart';
import 'post_usecases.dart';

class PublishViaApiParams {
  const PublishViaApiParams({
    required this.postId,
    required this.platform,
  });

  final String postId;
  final SocialPlatform platform;
}

class PublishViaApi extends UseCase<PostingLog, PublishViaApiParams> {
  PublishViaApi(
    this._settings,
    this._auth,
    this._getPostById,
    this._remote,
    this._createLog,
    this._logRepo,
    this._postRepo,
    this._notifications,
  );

  final SettingsRepository _settings;
  final AuthRepository _auth;
  final GetPostById _getPostById;
  final PostRemoteDataSource _remote;
  final CreateLogEntry _createLog;
  final LogRepository _logRepo;
  final PostRepository _postRepo;
  final NotificationService _notifications;

  static const disabledMessage =
      'API posting is disabled. Turn on "Enable API posting" in Settings.';

  @override
  Future<Either<Failure, PostingLog>> call(PublishViaApiParams params) async {
    if (!_settings.getSettings().enableApiPosting) {
      return const Left(ValidationFailure(message: disabledMessage));
    }

    final postResult = await _getPostById(params.postId);
    late final SocialPost post;
    final postFailure = postResult.fold(
      (f) => f,
      (p) {
        post = p;
        return null;
      },
    );
    if (postFailure != null) return Left(postFailure);

    if (!post.platforms.contains(params.platform)) {
      return Left(
        ValidationFailure(
          message:
              'This post is not scheduled for ${params.platform.displayName}.',
        ),
      );
    }

    final tokenResult = await _auth.ensureFreshToken(params.platform);
    late final ConnectedAccount account;
    final tokenFailure = tokenResult.fold(
      (f) => f,
      (a) {
        account = a;
        return null;
      },
    );
    if (tokenFailure != null) {
      await _notifications.showPostingResult(
        title: 'Posting Failed',
        body:
            '${post.title} failed on ${params.platform.displayName}: ${tokenFailure.message}',
        isSuccess: false,
      );
      return Left(tokenFailure);
    }

    try {
      final apiResult = await _postToPlatform(
        account: account,
        platform: params.platform,
        content: post.content,
      );

      final logResult = await _createLog(
        CreateLogParams(
          postId: params.postId,
          platform: params.platform,
          status: LogStatus.posted,
          method: PostingMethod.api,
          postedAt: DateTime.now(),
          externalPostId: apiResult.externalPostId,
          externalPostUrl: apiResult.externalPostUrl,
        ),
      );

      return await logResult.fold(
        (f) async {
          await _notifications.showPostingResult(
            title: 'Posting Failed',
            body:
                '${post.title} failed on ${params.platform.displayName}: ${f.message}',
            isSuccess: false,
          );
          return Left(f);
        },
        (log) async {
          await _recalculateStatus(params.postId, post);
          await _notifications.showPostingResult(
            title: 'Posted Successfully',
            body: '${post.title} published on ${params.platform.displayName}',
            isSuccess: true,
          );
          return Right(log);
        },
      );
    } on NetworkException catch (e) {
      await _createLog(
        CreateLogParams(
          postId: params.postId,
          platform: params.platform,
          status: LogStatus.failed,
          method: PostingMethod.api,
          errorMessage: e.message,
        ),
      );
      await _recalculateStatus(params.postId, post);
      await _notifications.showPostingResult(
        title: 'Posting Failed',
        body:
            '${post.title} failed on ${params.platform.displayName}: ${e.message}',
        isSuccess: false,
      );
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      final message = e.toString();
      await _createLog(
        CreateLogParams(
          postId: params.postId,
          platform: params.platform,
          status: LogStatus.failed,
          method: PostingMethod.api,
          errorMessage: message,
        ),
      );
      await _recalculateStatus(params.postId, post);
      await _notifications.showPostingResult(
        title: 'Posting Failed',
        body:
            '${post.title} failed on ${params.platform.displayName}: $message',
        isSuccess: false,
      );
      return Left(ApiFailure(message: message));
    }
  }

  Future<ApiPostResult> _postToPlatform({
    required ConnectedAccount account,
    required SocialPlatform platform,
    required String content,
  }) {
    return switch (platform) {
      SocialPlatform.twitter => _remote.postToTwitter(
          accessToken: account.accessToken,
          text: content,
        ),
      SocialPlatform.linkedin => _remote.postToLinkedIn(
          accessToken: account.accessToken,
          userId: account.userId ??
              (throw NetworkException(
                'LinkedIn user id missing — please reconnect.',
              )),
          text: content,
        ),
      SocialPlatform.facebook => _remote.postToFacebook(
          pageId: account.pageId ??
              (throw NetworkException(
                'Facebook page not selected — please reconnect.',
              )),
          pageAccessToken: account.pageToken ?? account.accessToken,
          message: content,
        ),
    };
  }

  Future<void> _recalculateStatus(String postId, SocialPost post) async {
    final logsResult = await _logRepo.getLogsForPost(postId);
    await logsResult.fold((_) async {}, (logs) async {
      final postedCount =
          logs.where((l) => l.status == LogStatus.posted).length;
      final failedCount =
          logs.where((l) => l.status == LogStatus.failed).length;
      final targetCount = post.platforms.length;

      final PostStatus newStatus;
      if (postedCount == targetCount && targetCount > 0) {
        newStatus = PostStatus.posted;
      } else if (failedCount > 0 && postedCount == 0) {
        newStatus = PostStatus.failed;
      } else if (postedCount > 0 || failedCount > 0) {
        newStatus = PostStatus.partial;
      } else {
        newStatus = post.scheduledAt != null &&
                post.scheduledAt!.isAfter(DateTime.now())
            ? PostStatus.scheduled
            : PostStatus.draft;
      }
      await _postRepo.updateStatus(postId, newStatus);
    });
  }
}