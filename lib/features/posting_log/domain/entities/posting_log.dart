import 'package:equatable/equatable.dart';

import '../../../../core/utils/platform_utils.dart';

class PostingLog extends Equatable {
  const PostingLog({
    required this.id,
    required this.postId,
    required this.platform,
    required this.status,
    required this.method,
    required this.postedAt,
    this.externalPostId,
    this.externalPostUrl,
    this.errorMessage,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final SocialPlatform platform;
  final LogStatus status;
  final PostingMethod method;
  final DateTime? postedAt;
  final String? externalPostId;
  final String? externalPostUrl;
  final String? errorMessage;
  final String? notes;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        postId,
        platform,
        status,
        method,
        postedAt,
        externalPostUrl,
        errorMessage,
      ];
}

class CreateLogParams {
  const CreateLogParams({
    required this.postId,
    required this.platform,
    required this.status,
    this.method = PostingMethod.manual,
    this.postedAt,
    this.externalPostId,
    this.externalPostUrl,
    this.errorMessage,
    this.notes,
  });

  final String postId;
  final SocialPlatform platform;
  final LogStatus status;
  final PostingMethod method;
  final DateTime? postedAt;
  final String? externalPostId;
  final String? externalPostUrl;
  final String? errorMessage;
  final String? notes;
}

class LogFilter {
  const LogFilter({this.platform, this.status});
  final SocialPlatform? platform;
  final LogStatus? status;
}
