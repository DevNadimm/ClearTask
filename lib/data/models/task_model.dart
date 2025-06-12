class Task {
  int? id;
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
