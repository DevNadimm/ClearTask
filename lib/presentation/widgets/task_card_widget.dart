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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        color: AppColors.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => onToggleChange(task),
                    activeColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(HugeIcons.strokeRoundedCalendar03, size: 16, color: AppColors.secondaryFontColor.withOpacity(0.8)),
                            const SizedBox(width: 4),
                            Text(
                              task.dueDate != null
                                  ? "Due: ${DateFormatter.toLongMonthDayYear(task.dueDate.toString())}"
                                  : "Due: Anytime",
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.secondaryFontColor,
                              ),
                            ),
                            if (task.sendNotification) ...[
                              const SizedBox(width: 10),
                              const Icon(HugeIcons.strokeRoundedNotification03, size: 16, color: Colors.orangeAccent),
                            ]
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: taskTypeColor.withOpacity(0.3),
                            border: Border.all(width: 0.5, color:  taskTypeColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${getTaskTypeEmoji(task.taskType)} ${task.taskType.toUpperCase()}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryFontColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => showBottomModal(context, taskTypeColor),
                    icon: const Icon(HugeIcons.strokeRoundedMoreVertical),
                  ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColors.secondaryFontColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                tileColor: AppColors.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                title: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(HugeIcons.strokeRoundedCalendar03, size: 16, color: AppColors.secondaryFontColor.withOpacity(0.8)),
                        const SizedBox(width: 4),
                        Text(
                          task.dueDate != null
                              ? "Due: ${DateFormatter.toLongMonthDayYear(task.dueDate.toString())}"
                              : "Due: Anytime",
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.secondaryFontColor,
                          ),
                        ),
                      ],
                    ),
                    if (task.sendNotification)
                      Column(
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(HugeIcons.strokeRoundedNotification03, size: 16, color: AppColors.secondaryFontColor.withOpacity(0.8)),
                              const SizedBox(width: 4),
                              Text(
                                "Notification: ${DateFormatter.toLongMonthDayYearTime(task.notificationTime.toString())}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondaryFontColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(HugeIcons.strokeRoundedEdit03, size: 18),
                label: const Text("Edit Task"),
                iconAlignment: IconAlignment.end,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  context.read<TaskBloc>().add(DeleteTask(task.id!));
                },
                icon: const Icon(HugeIcons.strokeRoundedDelete02, size: 18),
                label: const Text("Delete Task"),
                iconAlignment: IconAlignment.end,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
