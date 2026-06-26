import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/posting_log.dart';

extension PostingLogDataX on PostingLogRow {
  PostingLog toDomain() => PostingLog(
        id: id,
        postId: postId,
        platform: SocialPlatformX.fromName(platform) ?? SocialPlatform.twitter,
        status: LogStatusX.fromName(status),
        method: PostingMethodX.fromName(method),
        postedAt: postedAt,
        externalPostId: externalPostId,
        externalPostUrl: externalPostUrl,
        errorMessage: errorMessage,
        notes: notes,
        createdAt: createdAt,
      );
}

extension CreateLogParamsX on CreateLogParams {
  PostingLogsTableCompanion toCompanion(String id) =>
      PostingLogsTableCompanion.insert(
        id: id,
        postId: postId,
        platform: platform.name,
        status: Value(status.name),
        method: Value(method.name),
        postedAt: Value(postedAt),
        externalPostId: Value(externalPostId),
        externalPostUrl: Value(externalPostUrl),
        errorMessage: Value(errorMessage),
        notes: Value(notes),
        createdAt: DateTime.now(),
      );
}

extension PostingLogX on PostingLog {
  PostingLogsTableCompanion toCompanion() => PostingLogsTableCompanion(
        id: Value(id),
        postId: Value(postId),
        platform: Value(platform.name),
        status: Value(status.name),
        method: Value(method.name),
        postedAt: Value(postedAt),
        externalPostId: Value(externalPostId),
        externalPostUrl: Value(externalPostUrl),
        errorMessage: Value(errorMessage),
        notes: Value(notes),
        createdAt: Value(createdAt),
      );

  PostingLog copyWith({LogStatus? status}) => PostingLog(
        id: id,
        postId: postId,
        platform: platform,
        status: status ?? this.status,
        method: method,
        postedAt: postedAt,
        externalPostId: externalPostId,
        externalPostUrl: externalPostUrl,
        errorMessage: errorMessage,
        notes: notes,
        createdAt: createdAt,
      );
}
