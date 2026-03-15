class Subtask {
  int? id;
  final int taskId;
  final String title;
  bool isCompleted;

  Subtask({
    this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
  });

  @override
  String toString() {
    return 'Subtask(id: $id, taskId: $taskId, title: $title, isCompleted: $isCompleted)';
  }

  static Map<String, dynamic> toMap(Subtask subtask) {
    final map = {
      'taskId': subtask.taskId,
      'title': subtask.title,
      'isCompleted': subtask.isCompleted ? 1 : 0,
    };
    if (subtask.id != null) map['id'] = subtask.id!;
    return map;
  }

  static Subtask fromMap(Map<String, dynamic> map) {
    return Subtask(
      id: map['id'],
      taskId: map['taskId'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
    );
  }

  Subtask copyWith({int? id, int? taskId, String? title, bool? isCompleted}) {
    return Subtask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Task {
  int? id;
  final String title;
  final String? dueDate;
  final String taskType;
  final bool sendNotification;
  final String? notificationTime;

  /// Internal stored value – used only when there are no subtasks.
  bool _isCompleted;

  /// Subtasks belonging to this task.
  List<Subtask> subtasks;

  Task({
    this.id,
    required this.title,
    this.dueDate,
    required this.taskType,
    this.sendNotification = false,
    this.notificationTime,
    bool isCompleted = false,
    List<Subtask>? subtasks,
  })  : _isCompleted = isCompleted,
        subtasks = subtasks ?? [];

  /// Returns true when all subtasks are done, or the stored value if there
  /// are no subtasks (backward-compatible behaviour).
  bool get isCompleted {
    if (subtasks.isEmpty) return _isCompleted;
    return subtasks.every((s) => s.isCompleted);
  }

  @override
  String toString() {
    return '''
Task(
  id: $id,
  title: $title,
  dueDate: $dueDate,
  taskType: $taskType,
  sendNotification: $sendNotification,
  notificationTime: $notificationTime,
  isCompleted: $isCompleted,
  subtasks: [${subtasks.join(', ')}]
)''';
  }

  /// The raw stored value (unaffected by subtask computation).
  /// Use this when you need to preserve completion state during task update.
  bool get storedIsCompleted => _isCompleted;

  /// Allow manual set only for tasks without subtasks.
  set isCompleted(bool value) {
    _isCompleted = value;
  }

  static Map<String, dynamic> toMap(Task task) {
    final map = {
      'title': task.title,
      'dueDate': task.dueDate,
      'taskType': task.taskType,
      'sendNotification': task.sendNotification ? 1 : 0,
      'notificationTime': task.notificationTime,
      // Persist the stored value (not the computed getter) so plain tasks work.
      'isCompleted': task._isCompleted ? 1 : 0,
    };
    if (task.id != null) map['id'] = task.id;
    return map;
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      dueDate: map['dueDate'],
      taskType: map['taskType'],
      sendNotification: map['sendNotification'] == 1,
      notificationTime: map['notificationTime'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
