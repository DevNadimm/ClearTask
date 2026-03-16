import 'package:clear_task/core/constants/error_messages.dart';
import 'package:clear_task/core/services/notification_controller.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:clear_task/data/repositories/task_local_repository.dart';
import 'package:clear_task/presentation/blocs/sync/sync_cubit.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
import 'package:clear_task/presentation/blocs/task/task_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskLocalRepository taskLocalRepository = TaskLocalRepository();
  SyncCubit? _syncCubit;

  /// Call this once to wire up auto-sync.
  void setSyncCubit(SyncCubit syncCubit) {
    _syncCubit = syncCubit;
  }

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

        await NotificationController.scheduleTaskNotifications(event.task);
        _syncCubit?.pushIfLoggedIn();
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
          final oldTask = _cachedTasks[index];
          final updatedTask = await taskLocalRepository.updateTask(event.task);
          _cachedTasks[index] = updatedTask;
          emit(TaskUpdated());
          emit(TasksLoaded(List.from(_cachedTasks)));

          // Cancel the old notification if it existed
          if (oldTask.sendNotification) {
            await NotificationController.cancelScheduledTaskNotification(id: event.task.id!);
          }
          
          // Schedule the new notification (controller handles validation)
          if (updatedTask.sendNotification) {
            await NotificationController.scheduleTaskNotifications(updatedTask);
          }
          _syncCubit?.pushIfLoggedIn();
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
        await taskLocalRepository.deleteTask(event.id);
        _cachedTasks.removeWhere((task) => task.id == event.id);

        emit(TaskDeleted());
        emit(TasksLoaded(List.from(_cachedTasks)));

        await NotificationController.cancelScheduledTaskNotification(id: event.id);
        _syncCubit?.pushIfLoggedIn();
      } catch (e) {
        emit(TaskError(ErrorMessages.deleteFailed));
      }
    });

    // Delete all Tasks
    on<DeleteAllTasks>((event, emit) async {
      try {
        // Cancel all notifications before clearing cache
        for (final task in _cachedTasks) {
          if (task.sendNotification && task.id != null) {
            await NotificationController.cancelScheduledTaskNotification(id: task.id!);
          }
        }
        await taskLocalRepository.deleteAllTasks();
        _cachedTasks.clear();
        emit(AllTasksDeleted());
        emit(TasksLoaded([]));
      } catch (e) {
        emit(TaskError(ErrorMessages.deleteAllFailed));
      }
    });

    // Toggle task completion (only for tasks without subtasks)
    on<ToggleTaskCompletion>((event, emit) async {
      if (state is TasksLoaded) {
        try {
          // If the task has subtasks, toggling is driven by subtask completion.
          if (event.task.subtasks.isNotEmpty) return;

          final bool newCompletedStatus = !event.task.isCompleted;
          Task updatedTask = event.task.copyWith(
            isCompleted: newCompletedStatus,
            completedAt: newCompletedStatus ? DateTime.now().toIso8601String() : null,
          );
          await taskLocalRepository.updateTask(updatedTask);

          int index = _cachedTasks.indexWhere((task) => task.id == updatedTask.id);
          if (index != -1) _cachedTasks[index] = updatedTask;

          emit(TasksLoaded(List.from(_cachedTasks)));
          _syncCubit?.pushIfLoggedIn();

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

    // ── Subtask events ──────────────────────────────────────────────────────────

    // Add a subtask to an existing task
    on<AddSubtask>((event, emit) async {
      try {
        final saved = await taskLocalRepository.createSubtask(event.subtask);
        final index = _cachedTasks.indexWhere((t) => t.id == event.taskId);
        if (index != -1) {
          _cachedTasks[index].subtasks.add(saved);
        }
        emit(TasksLoaded(List.from(_cachedTasks)));
        _syncCubit?.pushIfLoggedIn();
      } catch (e) {
        emit(TaskError(ErrorMessages.createFailed));
      }
    });

    // Toggle a subtask's completion status
    on<ToggleSubtaskCompletion>((event, emit) async {
      try {
        final updatedSubtask = event.subtask.copyWith(isCompleted: !event.subtask.isCompleted);
        await taskLocalRepository.updateSubtask(updatedSubtask);

        final taskIndex = _cachedTasks.indexWhere((t) => t.id == updatedSubtask.taskId);
        if (taskIndex != -1) {
          final task = _cachedTasks[taskIndex];
          final subtaskIndex = task.subtasks.indexWhere((s) => s.id == updatedSubtask.id);
          if (subtaskIndex != -1) {
            task.subtasks[subtaskIndex] = updatedSubtask;

            // Update parent task completedAt if completion status changed
            final bool isNowCompleted = task.isCompleted;
            final bool hasCompletedAt = task.completedAt != null;

            if (isNowCompleted && !hasCompletedAt) {
              final updatedParent = task.copyWith(completedAt: DateTime.now().toIso8601String());
              await taskLocalRepository.updateTask(updatedParent);
              _cachedTasks[taskIndex] = updatedParent;
            } else if (!isNowCompleted && hasCompletedAt) {
              final updatedParent = task.copyWith(completedAt: null);
              await taskLocalRepository.updateTask(updatedParent);
              _cachedTasks[taskIndex] = updatedParent;
            }
          }
        }

        emit(TasksLoaded(List.from(_cachedTasks)));
        _syncCubit?.pushIfLoggedIn();

        // Check if all tasks (and their subtasks) are now completed
        bool isAllCompleted = _cachedTasks.length > 1 && _cachedTasks.every((task) => task.isCompleted);
        if (isAllCompleted) add(CelebrateAllTasksCompleted());
      } catch (e) {
        emit(state);
      }
    });

    // Delete a subtask
    on<DeleteSubtask>((event, emit) async {
      try {
        await taskLocalRepository.deleteSubtask(event.subtask.id!);
        final taskIndex = _cachedTasks.indexWhere((t) => t.id == event.subtask.taskId);
        if (taskIndex != -1) {
          _cachedTasks[taskIndex].subtasks.removeWhere((s) => s.id == event.subtask.id);
        }
        emit(TasksLoaded(List.from(_cachedTasks)));
        _syncCubit?.pushIfLoggedIn();
      } catch (e) {
        emit(state);
      }
    });
  }
}
