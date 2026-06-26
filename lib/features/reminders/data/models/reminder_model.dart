import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/reminder.dart';

extension ReminderDataX on ReminderRow {
  Reminder toDomain() => Reminder(
        id: id,
        postId: postId,
        title: title,
        body: body,
        scheduledAt: scheduledAt,
        repeat: ReminderRepeatX.fromName(repeat),
        repeatDays: IntListJson.fromJsonString(repeatDaysJson),
        isEnabled: isEnabled,
        notificationId: notificationId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension CreateReminderParamsX on CreateReminderParams {
  RemindersTableCompanion toCompanion({
    required String id,
    required int notificationId,
  }) =>
      RemindersTableCompanion.insert(
        id: id,
        postId: Value(postId),
        title: title,
        body: Value(body),
        scheduledAt: scheduledAt,
        repeat: Value(repeat.name),
        repeatDaysJson: Value(repeatDays.toJsonString()),
        isEnabled: const Value(true),
        notificationId: notificationId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}

extension UpdateReminderParamsX on UpdateReminderParams {
  RemindersTableCompanion toCompanion() => RemindersTableCompanion(
        id: Value(id),
        postId: Value(postId),
        title: Value(title),
        body: Value(body),
        scheduledAt: Value(scheduledAt),
        repeat: Value(repeat.name),
        repeatDaysJson: Value(repeatDays.toJsonString()),
        isEnabled: Value(isEnabled),
        notificationId: Value(notificationId),
        createdAt: Value(createdAt),
        updatedAt: Value(DateTime.now()),
      );
}
