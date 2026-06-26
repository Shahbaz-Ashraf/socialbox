import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/social_post.dart';

extension SocialPostDataX on SocialPostRow {
  SocialPost toDomain(List<SocialPlatform> platforms) => SocialPost(
        id: id,
        title: title,
        content: content,
        platforms: platforms,
        status: PostStatusX.fromName(status),
        scheduledAt: scheduledAt,
        isRecurring: isRecurring,
        recurringType: RecurringType.values.firstWhere(
          (e) => e.name == recurringType,
          orElse: () => RecurringType.none,
        ),
        recurringDays: IntListJson.fromJsonString(recurringDaysJson),
        attachments: StringListJson.fromJsonString(attachmentsJson),
        tags: StringListJson.fromJsonString(tagsJson),
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension SocialPostX on SocialPost {
  SocialPostsTableCompanion toCompanion() => SocialPostsTableCompanion.insert(
        id: id,
        title: title,
        content: content,
        status: Value(status.name),
        scheduledAt: Value(scheduledAt),
        isRecurring: Value(isRecurring),
        recurringType: Value(recurringType.name),
        recurringDaysJson: Value(recurringDays.toJsonString()),
        attachmentsJson: Value(attachments.toJsonString()),
        tagsJson: Value(tags.toJsonString()),
        notes: Value(notes),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
