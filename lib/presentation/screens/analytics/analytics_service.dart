import 'package:clear_task/data/models/task_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsService {
  /// Calculates the productivity score for a given task.
  /// IF task has NO subtasks: completed -> 1.0, not completed -> 0.0
  /// IF task HAS subtasks: score = completedSubtasks / totalSubtasks
  static double calculateTaskScore(Task task) {
    if (task.subtasks.isEmpty) {
      return task.isCompleted ? 1.0 : 0.0;
    }
    int completedSubtasks = task.subtasks.where((s) => s.isCompleted).length;
    return completedSubtasks / task.subtasks.length;
  }

  /// Calculates the total sum of scores for all tasks/subtasks completed on a specific day.
  /// It considers both `task.completedAt` and `subtask.completedAt`.
  static double calculateDailyScore(List<Task> tasks, DateTime day) {
    double dailyScore = 0.0;
    final dayStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

    for (var task in tasks) {
      if (task.subtasks.isEmpty) {
        if (task.isCompleted && task.completedAt != null) {
          try {
            final tDate = DateTime.parse(task.completedAt!);
            if (tDate.year == day.year && tDate.month == day.month && tDate.day == day.day) {
              dailyScore += 1.0;
            }
          } catch (_) {}
        }
      } else {
        double subtaskWeight = 1.0 / task.subtasks.length;
        for (var subtask in task.subtasks) {
          if (subtask.isCompleted && subtask.completedAt != null) {
            try {
              final sDate = DateTime.parse(subtask.completedAt!);
              if (sDate.year == day.year && sDate.month == day.month && sDate.day == day.day) {
                dailyScore += subtaskWeight;
              }
            } catch (_) {}
          } else if (subtask.isCompleted && task.completedAt != null) {
             // Fallback if subtask has no completedAt, use task completedAt
            try {
              final tDate = DateTime.parse(task.completedAt!);
              if (tDate.year == day.year && tDate.month == day.month && tDate.day == day.day) {
                dailyScore += subtaskWeight;
              }
            } catch (_) {}
          }
        }
      }
    }
    return dailyScore;
  }

  /// Calculates the overall score representation (sum of all task scores)
  static double calculateOverallScore(List<Task> tasks) {
    double totalScore = 0.0;
    for (var task in tasks) {
      totalScore += calculateTaskScore(task);
    }
    return totalScore;
  }

  /// The true completion count: total completed subtasks + completed standalone tasks
  static int getTrueCompletionCount(List<Task> tasks) {
    int count = 0;
    for (var task in tasks) {
      if (task.subtasks.isEmpty) {
        if (task.isCompleted) count += 1;
      } else {
        count += task.subtasks.where((s) => s.isCompleted).length;
      }
    }
    return count;
  }
  
  /// Total number of units (subtasks + standalone tasks)
  static int getTotalUnits(List<Task> tasks) {
    int count = 0;
    for (var task in tasks) {
      if (task.subtasks.isEmpty) {
        count += 1;
      } else {
        count += task.subtasks.length;
      }
    }
    return count;
  }

  /// Gets the total pending units (subtasks + standalone)
  static int getTotalIncompleteUnits(List<Task> tasks) {
    return getTotalUnits(tasks) - getTrueCompletionCount(tasks);
  }

  /// Calculates the Subtask Completion Rate across all tasks (0.0 to 100.0)
  static double getSubtaskCompletionRate(List<Task> tasks) {
    int totalSubtasks = 0;
    int completedSubtasks = 0;
    for (var task in tasks) {
      totalSubtasks += task.subtasks.length;
      completedSubtasks += task.subtasks.where((s) => s.isCompleted).length;
    }
    if (totalSubtasks == 0) return 0.0;
    return (completedSubtasks / totalSubtasks) * 100;
  }

  /// Generates the bar groups for the weekly chart based on productivity scores.
  static List<BarChartGroupData> getWeeklyData(List<Task> tasks, BuildContext context, Color primaryColor) {
    final now = DateTime.now();
    List<BarChartGroupData> groups = [];
    
    double maxScore = 5; // Minimum Y height
    
    // Check max score first for scaling
    for (int i = 0; i < 7; i++) {
       final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
       final score = calculateDailyScore(tasks, day);
       if (score > maxScore) {
         maxScore = score;
       }
    }

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final score = calculateDailyScore(tasks, date);
      
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: score,
              color: primaryColor,
              width: 14,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxScore + 1,
                color: Theme.of(context).inputDecorationTheme.border?.borderSide.color.withValues(alpha: 0.15) ?? Colors.grey.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      );
    }
    return groups;
  }
  
  /// Gets the maximum weekly score for BarChart scaling
  static double getMaxWeeklyScore(List<Task> tasks) {
    final now = DateTime.now();
    double maxScore = 5;
    for (int i = 0; i < 7; i++) {
       final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
       final score = calculateDailyScore(tasks, day);
       if (score > maxScore) maxScore = score;
    }
    return maxScore;
  }

  /// Groups productivity scores by Task Category
  static Map<String, double> getCategoryBreakdown(List<Task> tasks) {
    final Map<String, double> categories = {};
    for (var task in tasks) {
      double score = calculateTaskScore(task);
      if (score > 0) {
        categories[task.taskType] = (categories[task.taskType] ?? 0.0) + score;
      }
    }
    return categories;
  }
}
