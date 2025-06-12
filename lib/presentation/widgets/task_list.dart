import 'package:clear_task/core/utils/helper_functions/get_empty_message.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:clear_task/presentation/widgets/task_card.dart';
import 'package:flutter/material.dart';

class TaskList extends StatelessWidget {
  final String tab;
  final List<Task> tasks;
  final Function(Task task) onToggleChange;

  const TaskList({
    super.key,
    required this.tab,
    required this.tasks,
    required this.onToggleChange,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                getEmptyMessage(tab),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: tasks.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onToggleChange: (Task task) => onToggleChange(task),
        );
      },
    );
  }
}
