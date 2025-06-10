import 'package:clear_task/core/utils/formatter/date_formatter.dart';
import 'package:flutter/material.dart';

class Task {
  final int? id;
  final String title;
  final String? dueDate;
  final String taskType;
  final bool sendNotification;
  final String? notificationTime;
  bool isCompleted;

  Task({
    this.id,
    required this.title,
    this.dueDate,
    required this.taskType,
    this.sendNotification = false,
    this.notificationTime,
    this.isCompleted = false,
  });

  static Map<String, dynamic> toMap(Task task) {
    final map = {
      "title": task.title,
      "dueDate": task.dueDate,
      "taskType": task.taskType,
      "sendNotification": task.sendNotification ? 1 : 0,
      "notificationTime": task.notificationTime,
      "isCompleted": task.isCompleted ? 1 : 0,
    };
    if (task.id != null) {
      map['id'] = task.id;
    }
    return map;
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map["title"],
      dueDate: map["dueDate"],
      taskType: map["taskType"],
      sendNotification: map["sendNotification"] == 1,
      notificationTime: map["notificationTime"],
      isCompleted: map["isCompleted"] == 1,
    );
  }
}

String getTaskTypeEmoji(String taskType) {
  final type = taskType.toLowerCase();
  if (type == 'office')
    return '💼'; // Office Work
  else if (type == 'home')
    return '🏠'; // Household Task
  else if (type == 'study')
    return '📖'; // Study or Learning
  else if (type == 'personal')
    return '🧘'; // Personal Care
  else if (type == 'shopping')
    return '🛒'; // Shopping
  else if (type == 'fitness')
    return '💪'; // Fitness or Workout
  else if (type == 'health')
    return '🩺'; // Health or Medical
  else if (type == 'finance')
    return '💳'; // Financial Task
  else if (type == 'travel')
    return '✈️'; // Travel or Trip
  else if (type == 'event')
    return '📅'; // Event or Reminder
  else
    return '📝'; // Default: General Task
}

Color getTaskTypeColor(String taskType) {
  final type = taskType.toLowerCase();
  if (type == 'office')
    return const Color(0xFF90CAF9); // Blue 300 (darker)
  else if (type == 'home')
    return const Color(0xFFA5D6A7); // Green 300
  else if (type == 'study')
    return const Color(0xFFB39DDB); // Purple 300
  else if (type == 'personal')
    return const Color(0xFF80CBC4); // Teal 300
  else if (type == 'shopping')
    return const Color(0xFFFFCC80); // Orange 300
  else if (type == 'fitness')
    return const Color(0xFFEF9A9A); // Red 300
  else if (type == 'health')
    return const Color(0xFFF48FB1); // Pink 300
  else if (type == 'finance')
    return const Color(0xFF9FA8DA); // Indigo 300
  else if (type == 'travel')
    return const Color(0xFF80DEEA); // Cyan 300
  else if (type == 'event')
    return const Color(0xFFFFF59D); // Amber 300
  else
    return const Color(0xFFE0E0E0); // Grey 300 (Default)
}

List<Task> filterTasks(String tab, List<Task> tasks) {
  final DateTime today = DateTime.now();
  final DateTime tomorrow = today.add(const Duration(days: 1));

  bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  return switch (tab) {
    "All" => tasks,
    "Today" => tasks
        .where((task) =>
            task.dueDate != null &&
            isSameDate(DateFormatter.parseDateTime(task.dueDate!), today))
        .toList(),
    "Tomorrow" => tasks
        .where((task) =>
            task.dueDate != null &&
            isSameDate(DateFormatter.parseDateTime(task.dueDate!), tomorrow))
        .toList(),
    "Upcoming" => tasks
        .where((task) =>
            task.dueDate != null &&
            DateFormatter.parseDateTime(task.dueDate!).isAfter(tomorrow))
        .toList(),
    "Anytime" => tasks.where((task) => task.dueDate == null).toList(),
    "Completed" => tasks.where((task) => task.isCompleted).toList(),
    _ => [],
  };
}
