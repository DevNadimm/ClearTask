import 'package:clear_task/data/models/task_model.dart';

abstract class TaskEvent {}

class FetchTasks extends TaskEvent {}

class CreateTask extends TaskEvent {
  final Task task;

  CreateTask(this.task);
}

class EditTask extends TaskEvent {
  final Task task;

  EditTask(this.task);
}

class DeleteTask extends TaskEvent {
  final int id;

  DeleteTask(this.id);
}

class DeleteAllTasks extends TaskEvent {}

class UpdateTaskCompletion extends TaskEvent {
  final Task task;

  UpdateTaskCompletion({required this.task});
}
