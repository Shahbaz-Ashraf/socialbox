import 'package:equatable/equatable.dart';

import '../../../../core/utils/platform_utils.dart';

class Reminder extends Equatable {
  const Reminder({
    required this.id,
    required this.postId,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.repeat,
    required this.repeatDays,
    required this.isEnabled,
    required this.notificationId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? postId;
  final String title;
  final String? body;
  final DateTime scheduledAt;
  final ReminderRepeat repeat;
  final List<int> repeatDays;
  final bool isEnabled;
  final int notificationId;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isUpcoming =>
      isEnabled && scheduledAt.isAfter(DateTime.now());

  @override
  List<Object?> get props => [
        id,
        postId,
        title,
        body,
        scheduledAt,
        repeat,
        repeatDays,
        isEnabled,
        notificationId,
      ];
}

class CreateReminderParams {
  const CreateReminderParams({
    required this.title,
    required this.scheduledAt,
    this.body,
    this.postId,
    this.repeat = ReminderRepeat.none,
    this.repeatDays = const [],
  });

  final String title;
  final String? body;
  final String? postId;
  final DateTime scheduledAt;
  final ReminderRepeat repeat;
  final List<int> repeatDays;
}

class UpdateReminderParams {
  const UpdateReminderParams({
    required this.id,
    required this.title,
    required this.scheduledAt,
    this.body,
    this.postId,
    this.repeat = ReminderRepeat.none,
    this.repeatDays = const [],
    this.isEnabled = true,
    required this.notificationId,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String? body;
  final String? postId;
  final DateTime scheduledAt;
  final ReminderRepeat repeat;
  final List<int> repeatDays;
  final bool isEnabled;
  final int notificationId;
  final DateTime createdAt;
}
