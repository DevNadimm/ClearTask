import 'package:clear_task/data/models/task_model.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;

  TaskLoaded(this.tasks);
}

class TaskError extends TaskState {
  final String errorMessage;

  TaskError(this.errorMessage);
}
