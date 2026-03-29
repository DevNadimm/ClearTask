/// A single task in the AI-generated daily plan.
class PlannedTask {
  final String title;
  final String priority;  // "high", "medium", "low"
  final String timeSlot;  // e.g. "9:00 AM – 10:30 AM"
  final List<String> steps;

  PlannedTask({
    required this.title,
    required this.priority,
    required this.timeSlot,
    this.steps = const [],
  });

  factory PlannedTask.fromJson(Map<String, dynamic> json) {
    return PlannedTask(
      title: json['title'] ?? '',
      priority: json['priority'] ?? 'medium',
      timeSlot: json['timeSlot'] ?? '',
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

/// The complete output of "Plan My Day" AI feature.
class DayPlan {
  final String summary;
  final List<PlannedTask> tasks;

  DayPlan({
    required this.summary,
    required this.tasks,
  });

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      summary: json['summary'] ?? '',
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((e) => PlannedTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
