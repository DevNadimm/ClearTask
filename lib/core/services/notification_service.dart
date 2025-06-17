import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    /// Initialize timezones
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

    /// Request Android 13+ notification permission
    final androidImplementation = _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      if (granted != true) {
        debugPrint('Notification permission denied on Android');
      }
    }

    /// Initialize plugin settings
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('clear_task_icon_notification');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// For general notification
  Future<void> sendNotification({
    required String title,
    required String body,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'notification',
          'General Notifications',
          channelDescription: 'Channel for general notifications',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'clear_task_channel',
      'Clear Task Notifications',
      channelDescription: 'Reminders for your tasks in Clear Task app',
      importance: Importance.max,
      priority: Priority.max,
    );
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDateTime, tz.local),
        const NotificationDetails(
          android: androidDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Trying inexact fallback...');

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDateTime, tz.local),
        const NotificationDetails(
          android: androidDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.inexact,
      );
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
