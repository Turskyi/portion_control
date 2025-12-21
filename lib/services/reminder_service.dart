import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Simple service to schedule/cancel a daily local notification.
/// Uses `flutter_local_notifications` + `timezone` to schedule at local time.
class ReminderService {
  ReminderService._privateConstructor();

  static final ReminderService instance = ReminderService._privateConstructor();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;

    final AndroidInitializationSettings androidSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings =
        const DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    await _plugin.initialize(
      InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: const DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        ),
      ),
    );

    // Initialize timezone data
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(tz.local.name));
    } catch (_) {
      // If timezone lookup fails, fall back to UTC
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    _initialized = true;
  }

  static const int _weightReminderId = 1000;

  Future<void> scheduleDailyWeightReminder({
    required TimeOfDay time,
    String title = constants.appName,
    String body = "Don't forget to log your weight today!",
  }) async {
    await _init();

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
          'weight_reminder_channel',
          'Weight reminders',
          channelDescription: 'Daily reminders to log body weight',
          importance: Importance.high,
          priority: Priority.high,
        );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.zonedSchedule(
      _weightReminderId,
      title,
      body,
      scheduled,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelWeightReminder() async {
    await _init();
    await _plugin.cancel(_weightReminderId);
  }
}
