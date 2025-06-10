import 'package:clear_task/core/constants/error_messages.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:clear_task/data/repositories/repository.dart';
import 'package:clear_task/presentation/blocs/task_event.dart';
import 'package:clear_task/presentation/blocs/task_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final Repository repository = Repository();

  TaskBloc() : super(TaskInitial()) {
    // Fetch all tasks
    on<FetchTasks>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await repository.fetchTasks();
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError(ErrorMessages.fetchFailed));
      }
    });

    // Create a new task
    on<CreateTask>((event, emit) async {
      final currentState = state;
      try {
        emit(TaskLoading());
        Task newTask = await repository.createTask(event.task);

        if (currentState is TaskLoaded) {
          final List<Task> updatedTasks = List.from(currentState.tasks)
            ..add(newTask);
          emit(TaskLoaded(updatedTasks));
        } else {
          // If no tasks loaded yet, start with new task
          emit(TaskLoaded([newTask]));
        }
      } catch (e) {
        emit(TaskError(ErrorMessages.createFailed));
      }
    });

    // Edit/update an existing task
    on<EditTask>((event, emit) async {
      final currentState = state;
      try {
        emit(TaskLoading());

        if (currentState is TaskLoaded) {
          final List<Task> tasks = List.from(currentState.tasks);
          final index = tasks.indexWhere((task) => task.id == event.task.id);

          if (index != -1) {
            final updatedTask = await repository.updateTask(event.task);
            tasks[index] = updatedTask;
            emit(TaskLoaded(tasks));
          } else {
            emit(TaskError(ErrorMessages.taskNotFound));
          }
        }
      } catch (e) {
        emit(TaskError(ErrorMessages.updateFailed));
      }
    });

    // Delete a task
    on<DeleteTask>((event, emit) async {
      final currentState = state;
      try {
        emit(TaskLoading());

        if (currentState is TaskLoaded) {
          final List<Task> tasks = List.from(currentState.tasks);
          await repository.deleteTask(event.id);
          tasks.removeWhere((task) => task.id == event.id);
          emit(TaskLoaded(tasks));
        }
      } catch (e) {
        emit(TaskError(ErrorMessages.deleteFailed));
      }
    });

    // Delete all tasks
    on<DeleteAllTasks>((event, emit) async {
      emit(TaskLoading());
      try {
        await repository.deleteAllTasks();
        emit(TaskLoaded([]));
      } catch (e) {
        emit(TaskError(ErrorMessages.deleteAllFailed));
      }
    });

    // Update task completion
    on<UpdateTaskCompletion>((event, emit) async {
      final currentState = state;

      if (currentState is TaskLoaded) {
        try {
          Task updatedTask = event.task;
          updatedTask.isCompleted = !updatedTask.isCompleted;

          await repository.updateTask(updatedTask);

          List<Task> updatedTasks = currentState.tasks.map((task) {
            return task.id == updatedTask.id ? updatedTask : task;
          }).toList();

          emit(TaskLoaded(updatedTasks));
        } catch (e) {
          emit(currentState);
        }
      }
    });
  }
}
