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

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: AppColors.cardColor,
      child: CheckboxListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        title: Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              tileColor: AppColors.cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              title: Text(
                                task.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              subtitle: subTitleWidget(
                                task: task,
                                taskTypeColor: taskTypeColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                label: const Text("Edit Task"),
                                icon: const Icon(
                                  HugeIcons.strokeRoundedEdit03,
                                  size: 18,
                                ),
                                iconAlignment: IconAlignment.end,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white),
                                onPressed: () {
                                  Get.back();
                                  context.read<TaskBloc>().add(DeleteTask(task.id!));
                                },
                                label: const Text("Delete Task"),
                                icon: const Icon(
                                  HugeIcons.strokeRoundedDelete02,
                                  size: 18,
                                ),
                                iconAlignment: IconAlignment.end,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.more_vert)),
          ],
        ),
        subtitle: subTitleWidget(
          task: task,
          taskTypeColor: taskTypeColor,
        ),
        value: task.isCompleted,
        onChanged: (_) => onToggleChange(task),
        activeColor: Theme.of(context).primaryColor,
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget subTitleWidget({
    required Task task,
    required Color taskTypeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: taskTypeColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              "${getTaskTypeEmoji(task.taskType)} ${task.taskType.toUpperCase()}",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Due: ${task.dueDate != null ? DateFormatter.toLongMonthDayYear(task.dueDate.toString()) : "Anytime"}",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
