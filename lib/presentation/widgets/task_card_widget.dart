import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/utils/formatter/date_formatter.dart';
import 'package:clear_task/core/utils/helper_functions/get_priority_color.dart';
import 'package:clear_task/core/utils/helper_functions/get_task_type_color.dart';
import 'package:clear_task/core/utils/helper_functions/get_task_type_emoji.dart';
import 'package:clear_task/core/utils/widgets/custom_divider.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:clear_task/presentation/blocs/task/task_bloc.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
import 'package:clear_task/presentation/screens/create_task/create_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class TaskCardWidget extends StatelessWidget {
  final Task task;
  final Function(Task task) onToggleChange;

  const TaskCardWidget({
    super.key,
    required this.task,
    required this.onToggleChange,
  });

  @override
  Widget build(BuildContext context) {
    final taskTypeColor = getTaskTypeColor(task.taskType);
    final priorityColor = getPriorityColor(task.priority);
    final hasPriority = task.priority != 'none';
    final hasSubtasks = task.subtasks.isNotEmpty;
    final completedCount = task.subtasks.where((s) => s.isCompleted).length;

    return GestureDetector(
      onTap: () {
        // Only toggle at the task level when there are no subtasks.
        if (!hasSubtasks) onToggleChange(task);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            width: 1,
            color: context.inputBorderColor,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        color: context.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Main task row ─────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox (non-interactive when task has subtasks)
                  GestureDetector(
                    onTap: hasSubtasks ? null : () => onToggleChange(task),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: hasSubtasks
                              ? taskTypeColor.withValues(alpha: 0.3)
                              : task.isCompleted
                                  ? taskTypeColor.withValues(alpha: 0.3)
                                  : taskTypeColor.withValues(alpha: 0.6),
                          width: task.isCompleted ? 1 : 1.5,
                        ),
                      ),
                      child: task.isCompleted
                          ? Padding(
                              padding: const EdgeInsets.all(1),
                              child: Image.asset('assets/icons/clear_task_icon_png.png'),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if (hasPriority) ...[
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: priorityColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                        decorationColor: context.secondaryFontColor,
                                        color: task.isCompleted
                                            ? context.secondaryFontColor
                                            : context.primaryFontColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Progress badge when task has subtasks
                            if (hasSubtasks) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: task.isCompleted
                                      ? taskTypeColor.withValues(alpha: 0.25)
                                      : context.inputBorderColor.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "$completedCount / ${task.subtasks.length}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: task.isCompleted ? taskTypeColor : context.secondaryFontColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              HugeIcons.strokeRoundedCalendar04,
                              size: 14,
                              color: context.secondaryFontColor.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.dueDate != null
                                  ? DateFormatter.toLongMonthDayYear(task.dueDate.toString())
                                  : "Anytime",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: context.secondaryFontColor,
                              ),
                            ),
                            if (task.sendNotification) ...[
                              const SizedBox(width: 8),
                              const Icon(HugeIcons.strokeRoundedNotification03,
                                  size: 16, color: Colors.orangeAccent),
                            ],
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: taskTypeColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "${getTaskTypeEmoji(task.taskType)} ${task.taskType[0].toUpperCase()}${task.taskType.substring(1)}",
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: taskTypeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: InkWell(
                      onTap: () => showBottomModal(context, hasPriority, priorityColor, taskTypeColor),
                      splashColor: AppColors.primaryColorTransparent,
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          HugeIcons.strokeRoundedMoreVertical,
                          color: context.secondaryFontColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Subtask list ──────────────────────────────────────────────
              if (hasSubtasks) ...[
                const SizedBox(height: 10),
                const CustomDivider(),
                const SizedBox(height: 8),
                ...task.subtasks.map((subtask) => _SubtaskRow(
                      subtask: subtask,
                      accentColor: taskTypeColor,
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void showBottomModal(BuildContext context, bool hasPriority, Color priorityColor, Color taskTypeColor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) {
        return Material(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 50,
                  decoration: BoxDecoration(
                    color: context.secondaryFontColor.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: taskTypeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        getTaskTypeEmoji(task.taskType),
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: context.primaryFontColor,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${task.taskType[0].toUpperCase()}${task.taskType.substring(1)}",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: taskTypeColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 22),
                const CustomDivider(),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Icon(
                      HugeIcons.strokeRoundedCalendar04,
                      size: 18,
                      color: context.secondaryFontColor.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      task.dueDate != null
                          ? DateFormatter.toLongMonthDayYear(task.dueDate.toString())
                          : "Anytime",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: context.secondaryFontColor,
                      ),
                    ),
                  ],
                ),
                if (task.sendNotification) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedNotification03,
                        size: 18,
                        color: context.secondaryFontColor.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatter.toLongMonthDayYearTime(task.notificationTime.toString()),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: context.secondaryFontColor,
                        ),
                      ),
                    ],
                  ),
                ],
                if (hasPriority) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: priorityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${task.priority[0].toUpperCase()}${task.priority.substring(1)} Priority",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: priorityColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => CreateTaskScreen(editTask: task));
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text("Edit Task", style: GoogleFonts.poppins()),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    context.read<TaskBloc>().add(DeleteTask(task.id!));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(
                    "Delete Task",
                    style: GoogleFonts.poppins(),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Subtask row widget ─────────────────────────────────────────────────────────

class _SubtaskRow extends StatelessWidget {
  final Subtask subtask;
  final Color accentColor;

  const _SubtaskRow({required this.subtask, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          // Subtask checkbox
          GestureDetector(
            onTap: () => context.read<TaskBloc>().add(
              ToggleSubtaskCompletion(subtask: subtask),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: subtask.isCompleted
                      ? accentColor.withValues(alpha: 0.4)
                      : accentColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: subtask.isCompleted
                  ? Padding(
                padding: const EdgeInsets.all(1),
                child: Image.asset('assets/icons/clear_task_icon_png.png'),
              )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Subtask title
          Expanded(
            child: GestureDetector(
              onTap: () => context.read<TaskBloc>().add(
                ToggleSubtaskCompletion(subtask: subtask),
              ),
              child: Text(
                subtask.title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: subtask.isCompleted
                      ? context.secondaryFontColor
                      : context.primaryFontColor,
                  decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: context.secondaryFontColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
