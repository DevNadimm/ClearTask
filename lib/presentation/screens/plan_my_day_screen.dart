import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/utils/formatter/date_formatter.dart';
import 'package:clear_task/data/models/day_plan_model.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:clear_task/data/services/ai_service.dart';
import 'package:clear_task/presentation/widgets/ai_limit_dialog.dart';
import 'package:clear_task/presentation/blocs/premium/premium_cubit.dart';
import 'package:clear_task/presentation/blocs/task/task_bloc.dart';
import 'package:clear_task/presentation/blocs/task/task_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class PlanMyDayScreen extends StatefulWidget {
  const PlanMyDayScreen({super.key});

  @override
  State<PlanMyDayScreen> createState() => _PlanMyDayScreenState();
}

class _PlanMyDayScreenState extends State<PlanMyDayScreen>
    with SingleTickerProviderStateMixin {
  final Set<int> _selectedTaskIds = {};
  DayPlan? _dayPlan;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  List<Task> _getPendingTasks(TaskState state) {
    if (state is TasksLoaded) {
      return state.tasks.where((t) => !t.isCompleted).toList();
    }
    return [];
  }

  void _toggleTask(int taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  void _selectAll(List<Task> tasks) {
    setState(() {
      if (_selectedTaskIds.length == tasks.length) {
        _selectedTaskIds.clear();
      } else {
        _selectedTaskIds.addAll(tasks.map((t) => t.id!));
      }
    });
  }

  Future<void> _generatePlan(List<Task> allPending) async {
    final premiumCubit = context.read<PremiumCubit>();

    // Check usage limit
    if (!premiumCubit.state.canUseAi) {
      AiLimitDialog.show(context);
      return;
    }

    final selectedTasks =
        allPending.where((t) => _selectedTaskIds.contains(t.id)).toList();

    if (selectedTasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select at least one task',
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _dayPlan = null;
    });

    // Consume one AI use
    final allowed = await premiumCubit.tryUseAi();
    if (!allowed) {
      setState(() => _isLoading = false);
      AiLimitDialog.show(context);
      return;
    }

    try {
      final plan = await AiService.planMyDay(selectedTasks);
      if (mounted) {
        setState(() {
          _dayPlan = plan;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to generate plan. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01, size: 28),
        ),
        title: Row(
          children: [
            const Icon(HugeIcons.strokeRoundedAiBrain01,
                color: AppColors.primaryColor, size: 26),
            const SizedBox(width: 10),
            Text(
              'Plan My Day',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          // Usage counter badge
          BlocBuilder<PremiumCubit, PremiumState>(
            builder: (context, premiumState) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(HugeIcons.strokeRoundedAiBrain01,
                          size: 16, color: AppColors.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        '${premiumState.remainingUses}/${premiumState.totalAllowed}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, taskState) {
          final pendingTasks = _getPendingTasks(taskState);

          if (pendingTasks.isEmpty && _dayPlan == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(HugeIcons.strokeRoundedTaskDone02,
                      size: 64,
                      color: context.secondaryFontColor.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'All tasks are completed!\nNo pending tasks to plan.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: context.secondaryFontColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Task selection section ────────────────────────────
                if (_dayPlan == null) ...[
                  Text(
                    'Select tasks to plan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.primaryFontColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose which tasks you want AI to organize into a daily schedule',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: context.secondaryFontColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Select all toggle
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _selectAll(pendingTasks),
                        child: Row(
                          children: [
                            Icon(
                              _selectedTaskIds.length == pendingTasks.length
                                  ? HugeIcons.strokeRoundedCheckmarkSquare02
                                  : HugeIcons.strokeRoundedSquare,
                              color: AppColors.primaryColor,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Select All',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_selectedTaskIds.length} selected',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: context.secondaryFontColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Task chips
                  ...pendingTasks.map((task) => _buildTaskSelectionCard(task)),

                  const SizedBox(height: 24),

                  // Generate button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : () => _generatePlan(pendingTasks),
                      child: Text(_isLoading ? 'Planning...' : 'Plan My Day'),
                    ),
                  ),
                ],

                // ── Loading skeleton ──────────────────────────────────
                if (_isLoading) ...[
                  const SizedBox(height: 32),
                  _buildLoadingSkeleton(),
                ],

                // ── Error message ─────────────────────────────────────
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(HugeIcons.strokeRoundedAlert02,
                              color: AppColors.error),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.poppins(
                                color: AppColors.error,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Day Plan Results ──────────────────────────────────
                if (_dayPlan != null) ...[
                  _buildDayPlanResults(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _dayPlan = null;
                          _selectedTaskIds.clear();
                        });
                      },
                      child: const Text('Plan Again'),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _buildTaskSelectionCard(Task task) {
    final isSelected = _selectedTaskIds.contains(task.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _toggleTask(task.id!),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryColor.withValues(alpha: 0.08)
                : context.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryColor
                  : context.inputBorderColor.withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected
                      ? HugeIcons.strokeRoundedCheckmarkSquare02
                      : HugeIcons.strokeRoundedSquare,
                  key: ValueKey(isSelected),
                  color: isSelected
                      ? AppColors.primaryColor
                      : context.secondaryFontColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.primaryFontColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.dueDate != null || task.priority != 'none')
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            if (task.priority != 'none')
                              _buildPriorityBadge(task.priority),
                            if (task.dueDate != null) ...[
                              if (task.priority != 'none')
                                const SizedBox(width: 8),
                              Icon(HugeIcons.strokeRoundedCalendar03,
                                  size: 12, color: context.secondaryFontColor),
                              const SizedBox(width: 4),
                              Text(
                                DateFormatter.toLongMonthDayYear(task.dueDate.toString()),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: context.secondaryFontColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = AppColors.error;
        break;
      case 'medium':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${priority[0].toUpperCase()}${priority.substring(1)}',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        context.cardColor,
                        AppColors.primaryColor.withValues(alpha: 0.08),
                        context.cardColor,
                      ],
                      stops: [
                        (_shimmerController.value - 0.3).clamp(0.0, 1.0),
                        _shimmerController.value,
                        (_shimmerController.value + 0.3).clamp(0.0, 1.0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(3, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            context.cardColor,
                            AppColors.primaryColor.withValues(alpha: 0.05),
                            context.cardColor,
                          ],
                          stops: [
                            (_shimmerController.value - 0.3).clamp(0.0, 1.0),
                            _shimmerController.value,
                            (_shimmerController.value + 0.3).clamp(0.0, 1.0),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDayPlanResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withValues(alpha: 0.15),
                AppColors.primaryColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(HugeIcons.strokeRoundedAiBrain01,
                      color: AppColors.primaryColor, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Your Daily Plan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.primaryFontColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _dayPlan!.summary,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: context.secondaryFontColor,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Timeline tasks
        ...List.generate(_dayPlan!.tasks.length, (index) {
          return _buildTimelineCard(_dayPlan!.tasks[index], index);
        }),
      ],
    );
  }

  Widget _buildTimelineCard(PlannedTask task, int index) {
    Color priorityColor;
    switch (task.priority.toLowerCase()) {
      case 'high':
        priorityColor = AppColors.error;
        break;
      case 'medium':
        priorityColor = AppColors.warning;
        break;
      default:
        priorityColor = AppColors.success;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: priorityColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: priorityColor,
                    ),
                  ),
                ),
              ),
              if (index < _dayPlan!.tasks.length - 1)
                Container(
                  width: 2,
                  height: 80,
                  color: priorityColor.withValues(alpha: 0.2),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Task card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: priorityColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: context.primaryFontColor,
                          ),
                        ),
                      ),
                      _buildPriorityBadge(task.priority),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Time slot
                  Row(
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedClock01,
                        size: 14,
                        color: context.secondaryFontColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          task.timeSlot,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: context.secondaryFontColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Steps
                  if (task.steps.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...task.steps.map((step) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor
                                        .withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  step,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: context.secondaryFontColor,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
