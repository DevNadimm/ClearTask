import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/constants/task_type.dart';
import 'package:clear_task/core/utils/formatter/date_formatter.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:clear_task/data/repositories/task_local_repository.dart';
import 'package:clear_task/presentation/blocs/notification/notification_cubit.dart';
import 'package:clear_task/presentation/blocs/task/task_bloc.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
import 'package:clear_task/presentation/widgets/bottom_sheet_widget.dart';
import 'package:clear_task/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class CreateTaskView extends StatefulWidget {
  /// When [editTask] is provided the view runs in edit mode.
  final Task? editTask;

  const CreateTaskView({super.key, this.editTask});

  @override
  State<CreateTaskView> createState() => _CreateTaskViewState();
}

class _CreateTaskViewState extends State<CreateTaskView> {
  final GlobalKey<FormState> _globalKey = GlobalKey();
  final TextEditingController title = TextEditingController();
  final TextEditingController taskType = TextEditingController();
  final TextEditingController dueDate = TextEditingController();
  final TextEditingController notificationDateAndTime = TextEditingController();

  /// New subtask fields (not yet persisted).
  final List<TextEditingController> _newSubtaskControllers = [];

  /// Copy of existing subtasks shown when editing (mutated by delete).
  late List<Subtask> _existingSubtasks;

  bool get _isEditing => widget.editTask != null;

  @override
  void initState() {
    super.initState();
    _existingSubtasks = List.from(widget.editTask?.subtasks ?? []);

    if (_isEditing) {
      final t = widget.editTask!;
      title.text = t.title;
      taskType.text = t.taskType;

      if (t.dueDate != null) {
        dueDate.text = DateFormatter.toLongMonthDayYear(t.dueDate!);
      }
      if (t.notificationTime != null) {
        notificationDateAndTime.text = DateFormatter.toLongMonthDayYearTime(t.notificationTime!);
      }

      // Seed the notification cubit once the widget tree is ready.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<NotificationCubit>().toggleNotification(t.sendNotification);
      });
    }
  }

  @override
  void dispose() {
    title.dispose();
    taskType.dispose();
    dueDate.dispose();
    notificationDateAndTime.dispose();
    for (final c in _newSubtaskControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addSubtaskField() => setState(() => _newSubtaskControllers.add(TextEditingController()));

  void _removeNewSubtaskField(int index) {
    _newSubtaskControllers[index].dispose();
    setState(() => _newSubtaskControllers.removeAt(index));
  }

  void _deleteExistingSubtask(Subtask subtask) {
    context.read<TaskBloc>().add(DeleteSubtask(subtask: subtask));
    setState(() => _existingSubtasks.removeWhere((s) => s.id == subtask.id));
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  void _submitTask() async {
    if (!(_globalKey.currentState?.validate() ?? false)) return;

    final sendNotification = context.read<NotificationCubit>().state;
    final bloc = context.read<TaskBloc>();

    final newSubtaskTitles = _newSubtaskControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

    if (_isEditing) {
      // ── Edit mode ──────────────────────────────────────────────────────────
      final updatedTask = Task(
        id: widget.editTask!.id,
        title: title.text,
        taskType: taskType.text,
        dueDate: dueDate.text.isNotEmpty
            ? DateFormatter.toRawDateTime(dueDate.text)
            : null,
        notificationTime: notificationDateAndTime.text.isNotEmpty
            ? DateFormatter.fromLongMonthDayYearTime(
                notificationDateAndTime.text)
            : null,
        isCompleted: widget.editTask!.isCompleted,
        sendNotification: sendNotification,
        subtasks: _existingSubtasks,
      );

      bloc.add(UpdateTask(updatedTask));

      // Add any newly entered subtasks.
      if (newSubtaskTitles.isNotEmpty) {
        for (final t in newSubtaskTitles) {
          bloc.add(AddSubtask(
            taskId: updatedTask.id!,
            subtask: Subtask(taskId: updatedTask.id!, title: t),
          ));
        }
        bloc.add(FetchTasks());
      }
    } else {
      // ── Create mode ────────────────────────────────────────────────────────
      final task = Task(
        title: title.text,
        taskType: taskType.text,
        dueDate: dueDate.text.isNotEmpty
            ? DateFormatter.toRawDateTime(dueDate.text)
            : null,
        notificationTime: notificationDateAndTime.text.isNotEmpty
            ? DateFormatter.fromLongMonthDayYearTime(
                notificationDateAndTime.text)
            : null,
        isCompleted: false,
        sendNotification: sendNotification,
      );

      if (newSubtaskTitles.isEmpty) {
        bloc.add(CreateTask(task));
      } else {
        final repo = TaskLocalRepository();
        final savedTask = await repo.createTask(task);
        for (final t in newSubtaskTitles) {
          bloc.add(AddSubtask(
            taskId: savedTask.id!,
            subtask: Subtask(taskId: savedTask.id!, title: t),
          ));
        }
        bloc.add(FetchTasks());
      }
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01, size: 34),
        ),
        title: Text(_isEditing ? "Edit Task" : "Create Task"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _globalKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        selectType: (type) => taskType.text = type,
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
                  DateTime initialDate = DateTime.now();
                  if (dueDate.text.isNotEmpty) {
                    initialDate =
                        DateTime.parse(DateFormatter.toRawDateTime(dueDate.text));
                  }
                  DateTime? selected = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (selected != null) {
                    dueDate.text =
                        DateFormatter.toLongMonthDayYear(selected.toString());
                  }
                },
              ),
              BlocBuilder<NotificationCubit, bool>(
                builder: (context, sendNotification) {
                  return Column(
                    children: [
                      if (sendNotification) ...[
                        const SizedBox(height: 24),
                        CustomTextField(
                          controller: notificationDateAndTime,
                          label: "Notification Date & Time",
                          hintText: "Select date & time",
                          validationLabel: "Notification date & time",
                          isRequired: true,
                          readOnly: true,
                          onTap: () async {
                            final dt = await pickDateTime(context);
                            if (dt != null) {
                              notificationDateAndTime.text = dt;
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      SwitchListTile(
                        title: Text(
                          "Send Notification",
                          style: GoogleFonts.poppins(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryFontColor,
                          ),
                        ),
                        tileColor: AppColors.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(
                              width: 1.4,
                              color: AppColors.inputBorderColor),
                        ),
                        value: sendNotification,
                        onChanged: (val) {
                          if (!val) notificationDateAndTime.clear();
                          context
                              .read<NotificationCubit>()
                              .toggleNotification(val);
                        },
                      ),
                    ],
                  );
                },
              ),

              // ── Subtasks section ───────────────────────────────────────────
              const SizedBox(height: 22),
              Row(
                children: [
                  Text(
                    "Subtasks",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryFontColor,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addSubtaskField,
                    icon: const Icon(HugeIcons.strokeRoundedAdd01, size: 18),
                    label: Text("Add subtask",
                        style: GoogleFonts.poppins(fontSize: 13)),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor),
                  ),
                ],
              ),

              // Existing subtasks (edit mode) – deletable but title is read-only
              if (_isEditing) ...[
                if (_existingSubtasks.isEmpty && _newSubtaskControllers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "No subtasks added yet.",
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.secondaryFontColor),
                    ),
                  ),
                ..._existingSubtasks.asMap().entries.map((entry) {
                  final subtask = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        // Completed indicator (read-only in edit form)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(alpha: 0.4),
                              width: 1.4,
                            ),
                          ),
                          child: subtask.isCompleted
                              ? Padding(
                            padding: const EdgeInsets.all(1),
                            child: Image.asset('assets/icons/clear_task_icon_png.png'),
                          )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            subtask.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: subtask.isCompleted
                                  ? AppColors.secondaryFontColor
                                  : AppColors.primaryFontColor,
                              decoration: subtask.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AppColors.secondaryFontColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _deleteExistingSubtask(subtask),
                          icon: const Icon(HugeIcons.strokeRoundedDelete01, size: 20),
                          color: AppColors.error,
                          tooltip: "Remove",
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              // New subtask input fields
              if (!_isEditing &&
                  _newSubtaskControllers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "No subtasks added yet.",
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.secondaryFontColor),
                  ),
                ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _newSubtaskControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _newSubtaskControllers[index],
                            style: GoogleFonts.poppins(color: AppColors.primaryFontColor),
                            decoration: InputDecoration(
                              hintText: "New subtask ${index + 1}",
                              hintStyle: GoogleFonts.poppins(color: AppColors.secondaryFontColor),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _removeNewSubtaskField(index),
                          icon: const Icon(HugeIcons.strokeRoundedDelete01, size: 20),
                          color: AppColors.error,
                          tooltip: "Remove",
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitTask,
                  child: Text(_isEditing ? "Save Changes" : "Create Task"),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> pickDateTime(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    TimeOfDay initialTime = TimeOfDay.now();

    if (notificationDateAndTime.text.isNotEmpty) {
      final parsed = DateTime.parse(DateFormatter.toRawDateTime(notificationDateAndTime.text));
      initialDate = parsed;
      initialTime = TimeOfDay(hour: parsed.hour, minute: parsed.minute);
    }

    DateTime lastDate = DateTime.now().add(const Duration(days: 30));
    if (dueDate.text.isNotEmpty) {
      lastDate = DateTime.parse(DateFormatter.toRawDateTime(dueDate.text));
    }

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: lastDate,
    );
    if (selectedDate == null) return null;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (selectedTime == null) return null;

    final fullDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    return DateFormatter.toLongMonthDayYearTime(fullDateTime.toIso8601String());
  }
}
