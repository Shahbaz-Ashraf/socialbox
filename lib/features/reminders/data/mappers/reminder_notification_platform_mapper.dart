import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/mappers/reminder_notification_mapper.dart';

DateTimeComponents? toDateTimeComponents(
  ReminderNotificationMatchComponent? component,
) =>
    switch (component) {
      ReminderNotificationMatchComponent.time => DateTimeComponents.time,
      ReminderNotificationMatchComponent.dayOfWeekAndTime =>
        DateTimeComponents.dayOfWeekAndTime,
      null => null,
    };