import 'package:clear_task/data/models/task_model.dart';

abstract class TaskEvent {}

class FetchTasks extends TaskEvent {}

class CreateTask extends TaskEvent {
  final Task task;

  CreateTask(this.task);
}

class UpdateTask extends TaskEvent {
  final Task task;

  UpdateTask(this.task);
}

class DeleteTask extends TaskEvent {
  final int id;

  DeleteTask(this.id);
}

class DeleteAllTasks extends TaskEvent {}

class ToggleTaskCompletion extends TaskEvent {
  final Task task;

  ToggleTaskCompletion({required this.task});
}

class CelebrateAllTasksCompleted extends TaskEvent {}

class SearchTasks extends TaskEvent {
  final String query;

  SearchTasks(this.query);
}

// ── Subtask events ────────────────────────────────────────────────────────────

class AddSubtask extends TaskEvent {
  final int taskId;
  final Subtask subtask;

  AddSubtask({required this.taskId, required this.subtask});
}

class ToggleSubtaskCompletion extends TaskEvent {
  final Subtask subtask;

  ToggleSubtaskCompletion({required this.subtask});
}

class DeleteSubtask extends TaskEvent {
  final Subtask subtask;

  DeleteSubtask({required this.subtask});
}
