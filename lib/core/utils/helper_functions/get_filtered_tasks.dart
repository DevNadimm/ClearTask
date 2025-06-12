import 'package:clear_task/core/utils/formatter/date_formatter.dart';
import 'package:clear_task/data/models/task_model.dart';

List<Task> getFilteredTasks(String tab, List<Task> tasks) {
  final DateTime today = DateTime.now();
  final DateTime tomorrow = today.add(const Duration(days: 1));

  bool isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  return switch (tab) {
    "All" => tasks,
    "Today" => tasks.where((task) => task.dueDate != null && isSameDate(DateFormatter.parseDateTime(task.dueDate!), today)).toList(),
    "Tomorrow" => tasks.where((task) => task.dueDate != null && isSameDate(DateFormatter.parseDateTime(task.dueDate!), tomorrow)).toList(),
    "Upcoming" => tasks.where((task) => task.dueDate != null && DateFormatter.parseDateTime(task.dueDate!).isAfter(tomorrow)).toList(),
    "Anytime" => tasks.where((task) => task.dueDate == null).toList(),
    "Completed" => tasks.where((task) => task.isCompleted).toList(),
    _ => [],
  };
}