import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_constants.dart';

/// Callback when a notification is tapped.
typedef NotificationTapCallback = void Function(String? payload);

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  NotificationTapCallback? _onTap;

  bool _initialized = false;

  Future<void> init({NotificationTapCallback? onTap}) async {
    if (_initialized) return;
    _onTap = onTap;

    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleTap,
    );

    await _createChannels();

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    _initialized = true;
  }

  void _handleTap(NotificationResponse response) {
    _onTap?.call(response.payload);
  }

  Future<void> _createChannels() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return;

    const remindersChannel = AndroidNotificationChannel(
      AppConstants.remindersChannelId,
      AppConstants.remindersChannelName,
      description: 'Scheduled reminder alerts for posts',
      importance: Importance.high,
    );

    const postingChannel = AndroidNotificationChannel(
      AppConstants.postingChannelId,
      AppConstants.postingChannelName,
      description: 'Results of API posting attempts',
      importance: Importance.defaultImportance,
    );

    const summaryChannel = AndroidNotificationChannel(
      AppConstants.dailySummaryChannelId,
      AppConstants.dailySummaryChannelName,
      description: 'End-of-day summaries',
      importance: Importance.low,
    );

    await androidImpl.createNotificationChannel(remindersChannel);
    await androidImpl.createNotificationChannel(postingChannel);
    await androidImpl.createNotificationChannel(summaryChannel);
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String? body,
    required DateTime scheduledAt,
    required DateTimeComponents? matchComponent,
    String? payload,
  }) async {
    try {
      final tzTime = tz.TZDateTime.from(scheduledAt, tz.local);
      if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;
      await _plugin.zonedSchedule(
        id,
        title,
        body ?? 'Time to post!',
        tzTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.remindersChannelId,
            AppConstants.remindersChannelName,
            channelDescription: 'Scheduled reminder alerts for posts',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchComponent,
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('scheduleReminder error: $e');
      }
    }
  }

  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> showPostingResult({
    required String title,
    required String body,
    required bool isSuccess,
  }) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.postingChannelId,
          AppConstants.postingChannelName,
          channelDescription: 'Results of API posting attempts',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          color: isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
        ),
      ),
    );
  }

  Future<void> showInfo(String title, String body) async {
    await showDailySummary(title: title, body: body);
  }

  static const int dailySummaryNotificationId = 900001;

  /// Shows an end-of-day summary notification on the daily summary channel.
  Future<void> showDailySummary({
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      dailySummaryNotificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.dailySummaryChannelId,
          AppConstants.dailySummaryChannelName,
          channelDescription: 'End-of-day summaries',
          importance: Importance.low,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
    );
  }

  /// Schedules a recurring daily summary at the given local time.
  Future<void> scheduleDailySummary({
    required DateTime scheduledAt,
    required String title,
    required String body,
  }) async {
    try {
      final tzTime = tz.TZDateTime.from(scheduledAt, tz.local);
      if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;
      await _plugin.zonedSchedule(
        dailySummaryNotificationId,
        title,
        body,
        tzTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.dailySummaryChannelId,
            AppConstants.dailySummaryChannelName,
            channelDescription: 'End-of-day summaries',
            importance: Importance.low,
            styleInformation: BigTextStyleInformation(body),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('scheduleDailySummary error: $e');
      }
    }
  }
}
