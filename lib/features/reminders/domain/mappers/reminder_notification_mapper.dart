import '../../../../core/utils/platform_utils.dart';
import '../entities/reminder.dart';

enum ReminderNotificationMatchComponent {
  time,
  dayOfWeekAndTime,
}

ReminderNotificationMatchComponent? reminderMatchComponent(Reminder reminder) =>
    reminderMatchComponentForRepeat(reminder.repeat);

ReminderNotificationMatchComponent? reminderMatchComponentForRepeat(
  ReminderRepeat repeat,
) =>
    switch (repeat) {
      ReminderRepeat.daily => ReminderNotificationMatchComponent.time,
      ReminderRepeat.weekly =>
        ReminderNotificationMatchComponent.dayOfWeekAndTime,
      ReminderRepeat.custom =>
        ReminderNotificationMatchComponent.dayOfWeekAndTime,
      ReminderRepeat.none => null,
    };