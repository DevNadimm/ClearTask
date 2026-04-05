class Subtask {
  int? id;
  final int taskId;
  final String title;
  bool isCompleted;
  final String? completedAt;

  Subtask({
    this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
  });

  @override
  String toString() {
    return 'Subtask(id: $id, taskId: $taskId, title: $title, isCompleted: $isCompleted, completedAt: $completedAt)';
  }

  static Map<String, dynamic> toMap(Subtask subtask) {
    final map = {
      'taskId': subtask.taskId,
      'title': subtask.title,
      'isCompleted': subtask.isCompleted ? 1 : 0,
      'completedAt': subtask.completedAt,
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
      completedAt: map['completedAt'],
    );
  }

  Subtask copyWith({int? id, int? taskId, String? title, bool? isCompleted, String? completedAt}) {
    return Subtask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class Task {
  int? id;
  final String title;
  final String? note;
  final String? dueDate;
  final String taskType;
  final String priority;
  final bool sendNotification;
  final String? notificationTime;
  final String? completedAt;

  // Cloud sync fields
  final String? cloudId;
  final bool isSynced;
  final bool isDeleted;
  final String? calendarEventId;

  /// Internal stored value – used only when there are no subtasks.
  bool _isCompleted;

  /// Subtasks belonging to this task.
  List<Subtask> subtasks;

  Task({
    this.id,
    required this.title,
    this.note,
    this.dueDate,
    required this.taskType,
    this.priority = 'none',
    this.sendNotification = false,
    this.notificationTime,
    this.completedAt,
    this.cloudId,
    this.isSynced = false,
    this.isDeleted = false,
    this.calendarEventId,
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
  completedAt: $completedAt,
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
    final map = <String, dynamic>{
      'title': task.title,
      'note': task.note,
      'dueDate': task.dueDate,
      'taskType': task.taskType,
      'priority': task.priority,
      'sendNotification': task.sendNotification ? 1 : 0,
      'notificationTime': task.notificationTime,
      'completedAt': task.completedAt,
      'isSynced': task.isSynced ? 1 : 0,
      'isDeleted': task.isDeleted ? 1 : 0,
      // Persist the stored value (not the computed getter) so plain tasks work.
      'isCompleted': task._isCompleted ? 1 : 0,
    };
    if (task.id != null) map['id'] = task.id;
    if (task.cloudId != null) map['cloudId'] = task.cloudId;
    if (task.calendarEventId != null) map['calendarEventId'] = task.calendarEventId;
    return map;
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      note: map['note'],
      dueDate: map['dueDate'],
      taskType: map['taskType'],
      priority: map['priority'] ?? 'none',
      sendNotification: map['sendNotification'] == 1,
      notificationTime: map['notificationTime'],
      completedAt: map['completedAt'],
      cloudId: map['cloudId'],
      isSynced: map['isSynced'] == 1,
      isDeleted: map['isDeleted'] == 1,
      calendarEventId: map['calendarEventId'],
      isCompleted: map['isCompleted'] == 1,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    Object? note = _sentinel,
    String? dueDate,
    String? taskType,
    String? priority,
    bool? sendNotification,
    Object? notificationTime = _sentinel,
    String? completedAt,
    String? cloudId,
    bool? isSynced,
    bool? isDeleted,
    String? calendarEventId,
    bool? isCompleted,
    List<Subtask>? subtasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note == _sentinel ? this.note : (note as String?),
      dueDate: dueDate ?? this.dueDate,
      taskType: taskType ?? this.taskType,
      priority: priority ?? this.priority,
      sendNotification: sendNotification ?? this.sendNotification,
      notificationTime: notificationTime == _sentinel
          ? this.notificationTime
          : (notificationTime as String?),
      completedAt: completedAt ?? this.completedAt,
      cloudId: cloudId ?? this.cloudId,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      calendarEventId: calendarEventId ?? this.calendarEventId,
      isCompleted: isCompleted ?? _isCompleted,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  static const _sentinel = Object();
}
