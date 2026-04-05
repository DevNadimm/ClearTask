import 'package:clear_task/core/constants/error_messages.dart';
import 'package:clear_task/core/services/notification_controller.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:clear_task/data/repositories/task_local_repository.dart';
import 'package:clear_task/data/repositories/user_stats_repository.dart';
import 'package:clear_task/presentation/blocs/sync/sync_cubit.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
import 'package:clear_task/presentation/blocs/task/task_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskLocalRepository taskLocalRepository = TaskLocalRepository();
  final UserStatsRepository userStatsRepository = UserStatsRepository();
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
      if (state is! TasksLoaded) {
        emit(TaskLoading());
      }
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
        _syncCubit?.pushIfLoggedIn();
      } catch (e) {
        emit(TaskError(ErrorMessages.deleteAllFailed));
      }
    });

    // Toggle task completion (only for tasks without subtasks)
    on<ToggleTaskCompletion>((event, emit) async {
      if (state is TasksLoaded) {
        try {
          // 1. Get the LATEST version from cache to avoid race conditions
          final taskIndex = _cachedTasks.indexWhere((t) => t.id == event.task.id);
          if (taskIndex == -1) return;
          final latestTask = _cachedTasks[taskIndex];

          // 2. If the task has subtasks, toggling is driven by subtask completion.
          if (latestTask.subtasks.isNotEmpty) return;

          final bool newCompletedStatus = !latestTask.isCompleted;
          debugPrint('🔄 Toggling task "${latestTask.title}": isCompleted=${latestTask.isCompleted} -> $newCompletedStatus, isXpAwarded=${latestTask.isXpAwarded}');
          
          Task updatedTask = latestTask.copyWith(
            isCompleted: newCompletedStatus,
            completedAt: newCompletedStatus ? DateTime.now().toIso8601String() : null,
          );
          
          // 3. Award XP only if transition to COMPLETED and not awarded yet
          if (updatedTask.isCompleted && !latestTask.isXpAwarded) {
            debugPrint('🎊 Awarding 10 XP for task "${latestTask.title}"');
            updatedTask = updatedTask.copyWith(isXpAwarded: true);
            
            // Update cache and UI immediately so rapid taps see the 'isXpAwarded: true'
            _cachedTasks[taskIndex] = updatedTask;
            emit(TasksLoaded(List.from(_cachedTasks)));
            
            // Award XP in background (sequential transformer ensures next toggle waits)
            await userStatsRepository.addXp(10);
          } else {
            if (updatedTask.isCompleted && latestTask.isXpAwarded) {
              debugPrint('ℹ️ Task "${latestTask.title}" already has XP awarded. Skipping XP.');
            }
            _cachedTasks[taskIndex] = updatedTask;
            emit(TasksLoaded(List.from(_cachedTasks)));
          }

          // 4. Update Database
          debugPrint('💾 Saving task to DB: id=${updatedTask.id}, isCompleted=${updatedTask.isCompleted}, isXpAwarded=${updatedTask.isXpAwarded}');
          debugPrint('   Raw Map: ${Task.toMap(updatedTask)}');
          await taskLocalRepository.updateTask(updatedTask);
          _syncCubit?.pushIfLoggedIn();

          // 5. Daily Goal Celebration
          bool isAllCompleted = _cachedTasks.length > 1 && _cachedTasks.every((task) => task.isCompleted);
          if (isAllCompleted) add(CelebrateAllTasksCompleted());
        } catch (e) {
          debugPrint('❌ Error in ToggleTaskCompletion: $e');
          emit(state);
        }
      }
    }, transformer: sequential());

    // Celebrate all tasks completed
    on<CelebrateAllTasksCompleted>((event, emit) {
      userStatsRepository.awardDailyBonus();
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
        final taskIndex = _cachedTasks.indexWhere((t) => t.id == event.subtask.taskId);
        if (taskIndex == -1) return;
        
        final task = _cachedTasks[taskIndex];
        final subtaskIndex = task.subtasks.indexWhere((s) => s.id == event.subtask.id);
        if (subtaskIndex == -1) return;
        
        final latestSubtask = task.subtasks[subtaskIndex];
        final bool isNowCompleted = !latestSubtask.isCompleted;
        debugPrint('🔄 Toggling subtask "${latestSubtask.title}": isCompleted=${latestSubtask.isCompleted} -> $isNowCompleted, isXpAwarded=${latestSubtask.isXpAwarded}');
        
        Subtask updatedSubtask = latestSubtask.copyWith(
          isCompleted: isNowCompleted,
          completedAt: isNowCompleted ? DateTime.now().toIso8601String() : null,
        );
        
        if (isNowCompleted && !latestSubtask.isXpAwarded) {
          debugPrint('🎊 Awarding 2 XP for subtask "${latestSubtask.title}"');
          updatedSubtask = updatedSubtask.copyWith(isXpAwarded: true);
          
          // Update cache immediately
          task.subtasks[subtaskIndex] = updatedSubtask;
          emit(TasksLoaded(List.from(_cachedTasks)));
          
          await userStatsRepository.addXp(2);
        } else {
          task.subtasks[subtaskIndex] = updatedSubtask;
          emit(TasksLoaded(List.from(_cachedTasks)));
        }

        // Update database
        debugPrint('💾 Saving subtask to DB: id=${updatedSubtask.id}, isXpAwarded=${updatedSubtask.isXpAwarded}');
        await taskLocalRepository.updateSubtask(updatedSubtask);

        // Update parent task completedAt if completion status changed
        final bool isParentNowCompleted = task.isCompleted;
        final bool hasCompletedAt = task.completedAt != null;

        if (isParentNowCompleted && !hasCompletedAt) {
          final updatedParent = task.copyWith(completedAt: DateTime.now().toIso8601String());
          await taskLocalRepository.updateTask(updatedParent);
          _cachedTasks[taskIndex] = updatedParent;
        } else if (!isParentNowCompleted && hasCompletedAt) {
          final updatedParent = task.copyWith(completedAt: null);
          await taskLocalRepository.updateTask(updatedParent);
          _cachedTasks[taskIndex] = updatedParent;
        }

        emit(TasksLoaded(List.from(_cachedTasks)));
        _syncCubit?.pushIfLoggedIn();

        // Check if all tasks (and their subtasks) are now completed
        bool isAllCompleted = _cachedTasks.length > 1 && _cachedTasks.every((task) => task.isCompleted);
        if (isAllCompleted) add(CelebrateAllTasksCompleted());
      } catch (e) {
        emit(state);
      }
    }, transformer: sequential());

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
