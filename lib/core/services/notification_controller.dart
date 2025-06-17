import 'package:clear_task/core/services/notification_service.dart';
import 'package:clear_task/core/utils/formatter/date_formatter.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:flutter/material.dart';

class NotificationController {
  static Future<void> scheduleTaskNotifications(Task task) async {
    if (!task.sendNotification || task.notificationTime == null) return;

    try {
      final DateTime scheduleDateTime = DateFormatter.parseDateTime(task.notificationTime!);

      final int notificationId = task.id ?? DateTime.now().millisecondsSinceEpoch;

      await NotificationService().scheduleNotification(
        id: notificationId,
        title: task.title,
        body: 'Don’t forget: ${task.title}',
        scheduledDateTime: scheduleDateTime,
      );

      debugPrint('✅ Notification scheduled at $scheduleDateTime with ID: $notificationId');
    } catch (e) {
      debugPrint('❌ Failed to schedule notification: $e');
    }
  }
}
