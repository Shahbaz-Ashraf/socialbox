import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/reminder.dart';

DateTimeComponents? reminderMatchComponent(Reminder reminder) =>
    reminderMatchComponentForRepeat(reminder.repeat);

DateTimeComponents? reminderMatchComponentForRepeat(ReminderRepeat repeat) =>
    switch (repeat) {
      ReminderRepeat.daily => DateTimeComponents.time,
      ReminderRepeat.weekly => DateTimeComponents.dayOfWeekAndTime,
      ReminderRepeat.custom => DateTimeComponents.dayOfWeekAndTime,
      ReminderRepeat.none => null,
    };