import 'package:clear_task/core/constants/task_type.dart';
import 'package:clear_task/core/utils/formatter/date_formatter.dart';
import 'package:clear_task/presentation/widgets/bottom_sheet_widget.dart';
import 'package:clear_task/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/task_model.dart';
import '../blocs/task_bloc.dart';
import '../blocs/task_event.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final GlobalKey<FormState> _globalKey = GlobalKey();
  final TextEditingController title = TextEditingController();
  final TextEditingController taskType = TextEditingController();
  final TextEditingController dueDate = TextEditingController();

  void _submitTask() async {
    if(_globalKey.currentState?.validate() ?? false) {
      final Task task = Task(
        title: title.text,
        taskType: taskType.text,
        dueDate: dueDate.text.isNotEmpty ? DateFormatter.toRawDateTime(dueDate.text) : null,
        isCompleted: false,
      );

      context.read<TaskBloc>().add(CreateTask(task));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Task"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _globalKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: title,
                  label: "Title",
                  hintText: "Enter your title",
                  validationLabel: "Title",
                  isRequired: true,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: taskType,
                  label: "Task Type",
                  hintText: "Select type",
                  validationLabel: "Task type",
                  readOnly: true,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return BottomSheetWidget(
                          type: taskType.text,
                          types: taskTypes,
                          selectType: (type) {
                            taskType.text = type;
                          },
                        );
                      },
                    );
                  },
                  isRequired: true,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: dueDate,
                  label: "Due Date",
                  hintText: "Select date",
                  validationLabel: "Due date",
                  readOnly: true,
                  onTap: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      currentDate: DateTime.now(),
                    );
                    if (selectedDate != null) {
                      dueDate.text = DateFormatter.toLongMonthDayYear(selectedDate.toString());
                    }
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitTask,
                    child: const Text(
                      "Create Task",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
