import 'package:clear_task/data/models/task_model.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;

  TasksLoaded(this.tasks);
}

class TaskError extends TaskState {
  final String errorMessage;

  TaskError(this.errorMessage);
}

class CelebrateSuccess extends TaskState {}

class TaskDeleted extends TaskState {}

class AllTasksDeleted extends TaskState {}

class TaskCreated extends TaskState {}

class TaskUpdated extends TaskState {}
