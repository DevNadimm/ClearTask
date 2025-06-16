import 'package:clear_task/core/constants/error_messages.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:clear_task/data/repositories/task_local_repository.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
import 'package:clear_task/presentation/blocs/task/task_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskLocalRepository taskLocalRepository = TaskLocalRepository();

  // Cache of all tasks
  List<Task> _cachedTasks = [];

  TaskBloc() : super(TaskInitial()) {
    // Fetch all tasks
    on<FetchTasks>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await taskLocalRepository.fetchTasks();
        _cachedTasks = tasks;
        emit(TasksLoaded(tasks));
      } catch (e) {
        emit(TaskError(ErrorMessages.fetchFailed));
      }
    });

    // Create a new task
    on<CreateTask>((event, emit) async {
      try {
        emit(TaskLoading());
        Task newTask = await taskLocalRepository.createTask(event.task);
        _cachedTasks.add(newTask);
        emit(TaskCreated());
        emit(TasksLoaded(List.from(_cachedTasks)));
      } catch (e) {
        emit(TaskError(ErrorMessages.createFailed));
      }
    });

    // Update task
    on<UpdateTask>((event, emit) async {
      try {
        emit(TaskLoading());
        final index = _cachedTasks.indexWhere((task) => task.id == event.task.id);

        if (index != -1) {
          final updatedTask = await taskLocalRepository.updateTask(event.task);
          _cachedTasks[index] = updatedTask;
          emit(TaskUpdated());
          emit(TasksLoaded(List.from(_cachedTasks)));
        } else {
          emit(TaskError(ErrorMessages.taskNotFound));
        }
      } catch (e) {
        emit(TaskError(ErrorMessages.updateFailed));
      }
    });

    // Delete task
    on<DeleteTask>((event, emit) async {
      try {
        // emit(TaskLoading());
        await taskLocalRepository.deleteTask(event.id);
        _cachedTasks.removeWhere((task) => task.id == event.id);
        emit(TaskDeleted());
        emit(TasksLoaded(List.from(_cachedTasks)));
      } catch (e) {
        emit(TaskError(ErrorMessages.deleteFailed));
      }
    });

    // Delete all Tasks
    on<DeleteAllTasks>((event, emit) async {
      // emit(TaskLoading());
      try {
        await taskLocalRepository.deleteAllTasks();
        _cachedTasks.clear(); // Clear cache
        emit(AllTasksDeleted());
        emit(TasksLoaded([]));
      } catch (e) {
        emit(TaskError(ErrorMessages.deleteAllFailed));
      }
    });

    // Toggle task completion
    on<ToggleTaskCompletion>((event, emit) async {
      if (state is TasksLoaded) {
        try {
          Task updatedTask = event.task;
          updatedTask.isCompleted = !updatedTask.isCompleted;
          await taskLocalRepository.updateTask(updatedTask);

          int index = _cachedTasks.indexWhere((task) => task.id == updatedTask.id);
          if (index != -1) _cachedTasks[index] = updatedTask;

          emit(TasksLoaded(List.from(_cachedTasks)));

          bool isAllCompleted = _cachedTasks.length > 1 && _cachedTasks.every((task) => task.isCompleted);
          if (isAllCompleted) add(CelebrateAllTasksCompleted());
        } catch (e) {
          emit(state);
        }
      }
    });

    // Celebrate all tasks completed
    on<CelebrateAllTasksCompleted>((event, emit) {
      emit(CelebrateSuccess());
      emit(TasksLoaded(_cachedTasks));
    });

    // Search Tasks
    on<SearchTasks>((event, emit) async {
      try {
        final query = event.query.toLowerCase();
        final filtered = _cachedTasks.where((task) {
          return task.title.toLowerCase().contains(query);
        }).toList();
        emit(TasksLoaded(filtered));
      } catch (e) {
        emit(TaskError(ErrorMessages.fetchFailed));
      }
    });
  }
}
