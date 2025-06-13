import 'package:clear_task/core/constants/error_messages.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:clear_task/data/repositories/task_local_repository.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
import 'package:clear_task/presentation/blocs/task/task_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskLocalRepository taskLocalRepository = TaskLocalRepository();

  TaskBloc() : super(TaskInitial()) {
    // Fetch all tasks
    on<FetchTasks>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await taskLocalRepository.fetchTasks();
        emit(TasksLoaded(tasks));
      } catch (e) {
        emit(TaskError(ErrorMessages.fetchFailed));
      }
    });

    // Create a new task
    on<CreateTask>((event, emit) async {
      final currentState = state;
      try {
        emit(TaskLoading());
        Task newTask = await taskLocalRepository.createTask(event.task);

        if (currentState is TasksLoaded) {
          final List<Task> updatedTasks = List.from(currentState.tasks)
            ..add(newTask);
          emit(TasksLoaded(updatedTasks));
        } else {
          // If no tasks loaded yet, start with new task
          emit(TasksLoaded([newTask]));
        }
      } catch (e) {
        emit(TaskError(ErrorMessages.createFailed));
      }
    });

    // Edit/update an existing task
    on<UpdateTask>((event, emit) async {
      final currentState = state;
      try {
        emit(TaskLoading());

        if (currentState is TasksLoaded) {
          final List<Task> tasks = List.from(currentState.tasks);
          final index = tasks.indexWhere((task) => task.id == event.task.id);

          if (index != -1) {
            final updatedTask = await taskLocalRepository.updateTask(event.task);
            tasks[index] = updatedTask;
            emit(TasksLoaded(tasks));
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

        if (currentState is TasksLoaded) {
          final List<Task> tasks = List.from(currentState.tasks);
          await taskLocalRepository.deleteTask(event.id);
          tasks.removeWhere((task) => task.id == event.id);
          emit(TasksLoaded(tasks));
        }
      } catch (e) {
        emit(TaskError(ErrorMessages.deleteFailed));
      }
    });

    // Delete all tasks
    on<DeleteAllTasks>((event, emit) async {
      emit(TaskLoading());
      try {
        await taskLocalRepository.deleteAllTasks();
        emit(TasksLoaded([]));
      } catch (e) {
        emit(TaskError(ErrorMessages.deleteAllFailed));
      }
    });

    // Toggle task completion
    on<ToggleTaskCompletion>((event, emit) async {
      final currentState = state;

      if (currentState is TasksLoaded) {
        try {
          Task updatedTask = event.task;
          updatedTask.isCompleted = !updatedTask.isCompleted;

          await taskLocalRepository.updateTask(updatedTask);

          List<Task> updatedTasks = currentState.tasks.map((task) {
            return task.id == updatedTask.id ? updatedTask : task;
          }).toList();

          emit(TasksLoaded(updatedTasks));

          bool isAllCompleted = updatedTasks.length > 1 && updatedTasks.every((task) => task.isCompleted);
          if (isAllCompleted) {
            add(CelebrateAllTasksCompleted());
          }
        } catch (e) {
          emit(currentState);
        }
      }
    });

    // Celebrate all task completed
    on<CelebrateAllTasksCompleted>((event, emit) {
      emit(CelebrateSuccess());
    });

    // Search tasks
    on<SearchTasks>((event, emit) async {
      try {
        List<Task> allTasks = await taskLocalRepository.fetchTasks();
        String query = event.query.toLowerCase();

        List<Task> filtered = allTasks.where((task) {
          return task.title.toLowerCase().contains(query);
        }).toList();

        emit(TasksLoaded(filtered));
      } catch (e) {
        emit(TaskError(ErrorMessages.fetchFailed));
      }
    });
  }
}
