import 'package:equatable/equatable.dart';

import '../../../../core/utils/platform_utils.dart';

class SocialPost extends Equatable {
  const SocialPost({
    required this.id,
    required this.title,
    required this.content,
    required this.platforms,
    required this.status,
    required this.scheduledAt,
    required this.isRecurring,
    required this.recurringType,
    required this.recurringDays,
    required this.attachments,
    required this.tags,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
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
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        platforms,
        status,
        scheduledAt,
        isRecurring,
        recurringType,
        recurringDays,
        tags,
        notes,
      ];
}
