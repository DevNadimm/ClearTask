import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/utils/formatter/date_formatter.dart';
import 'package:clear_task/core/utils/helper_functions/get_task_type_color.dart';
import 'package:clear_task/core/utils/helper_functions/get_task_type_emoji.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:clear_task/presentation/blocs/task/task_bloc.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
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

    return GestureDetector(
      onTap: () => onToggleChange(task),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            width: 1,
            color: AppColors.inputBorderColor,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        color: AppColors.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => onToggleChange(task),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: task.isCompleted
                              ? taskTypeColor.withValues(alpha: 0.3)
                              : taskTypeColor.withValues(alpha: 0.6),
                          width: task.isCompleted ? 1 : 1.5,
                        ),
                      ),
                      child: task.isCompleted
                          ? Padding(
                              padding: const EdgeInsets.all(1),
                              child: Image.asset(
                                  'assets/icons/clear_task_icon_png.png'),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: AppColors.secondaryFontColor,
                            color: task.isCompleted
                                ? AppColors.secondaryFontColor
                                : AppColors.primaryFontColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(HugeIcons.strokeRoundedCalendar04,
                                size: 14,
                                color: AppColors.secondaryFontColor
                                    .withValues(alpha: 0.8)),
                            const SizedBox(width: 4),
                            Text(
                                task.dueDate != null
                                    ? DateFormatter.toLongMonthDayYear(
                                        task.dueDate.toString())
                                    : "Anytime",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.secondaryFontColor,
                                )),
                            if (task.sendNotification) ...[
                              const SizedBox(width: 8),
                              const Icon(HugeIcons.strokeRoundedNotification03,
                                  size: 16, color: Colors.orangeAccent),
                            ],
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: taskTypeColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
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
                      onTap: () => showBottomModal(context, taskTypeColor),
                      splashColor: AppColors.primaryColorTransparent,
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          HugeIcons.strokeRoundedMoreVertical,
                          color: AppColors.secondaryFontColor,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                  // IconButton(
                  //   onPressed: () => showBottomModal(context, taskTypeColor),
                  //   icon: const Icon(
                  //     HugeIcons.strokeRoundedMoreVertical,
                  //     color: AppColors.secondaryFontColor,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showBottomModal(BuildContext context, Color taskTypeColor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) {
        return Material(
          color: AppColors.cardColor,
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
                    color: AppColors.secondaryFontColor.withValues(alpha: 0.7),
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
                              color: AppColors.primaryFontColor,
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
                Divider(
                  color: AppColors.inputBorderColor.withValues(alpha: 0.6),
                  height: 1,
                  thickness: 1,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Icon(
                      HugeIcons.strokeRoundedCalendar04,
                      size: 18,
                      color:
                          AppColors.secondaryFontColor.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      task.dueDate != null
                          ? DateFormatter.toLongMonthDayYear(
                              task.dueDate.toString())
                          : "Anytime",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.secondaryFontColor,
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
                        color:
                            AppColors.secondaryFontColor.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatter.toLongMonthDayYearTime(
                            task.notificationTime.toString()),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.secondaryFontColor,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 28),
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
