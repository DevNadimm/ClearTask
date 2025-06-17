import 'package:clear_task/core/services/notification_service.dart';
import 'package:clear_task/core/utils/formatter/date_formatter.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:flutter/material.dart';

class NotificationController {
  static Future<void> scheduleTaskNotifications(Task task) async {
    if (!task.sendNotification || task.notificationTime == null) {
      debugPrint('⚠️ Notification skipped for Task[${task.id}] - Missing time or disabled.');
      return;
    }

    try {
      final DateTime scheduleDateTime = DateFormatter.parseDateTime(task.notificationTime!);
      final int notificationId = task.id ?? DateTime.now().millisecondsSinceEpoch;

      if (scheduleDateTime.isBefore(DateTime.now())) {
        debugPrint('⏰ [SKIP] Task "${task.title}" notification time $scheduleDateTime is in the past. Skipping scheduling.');
        return;
      }

      await NotificationService().scheduleNotification(
        id: notificationId,
        title: task.title,
        body: 'Don’t forget: ${task.title}',
        scheduledDateTime: scheduleDateTime,
      );

      debugPrint('📅 [NOTIFY] Task "${task.title}" scheduled for $scheduleDateTime (ID: $notificationId)');
    } catch (e) {
      debugPrint('❌ [NOTIFY ERROR] Task "${task.title}" failed to schedule: $e');
    }
  }

  Future<void> cancelScheduledTaskNotification({required int id}) async {
    try {
      await NotificationService().cancelNotification(id);
      debugPrint('🗑️ [NOTIFY CANCELLED] Notification with ID $id successfully cancelled.');
    } catch (e) {
      debugPrint('❌ [CANCEL ERROR] Failed to cancel notification with ID $id: $e');
    }
  }
}
