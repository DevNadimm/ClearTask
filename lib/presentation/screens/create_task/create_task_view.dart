import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/constants/task_type.dart';
import 'package:clear_task/core/utils/formatter/date_formatter.dart';
import 'package:clear_task/data/models/task_model.dart';
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
  const CreateTaskView({super.key});

  @override
  State<CreateTaskView> createState() => _CreateTaskViewState();
}

class _CreateTaskViewState extends State<CreateTaskView> {
  final GlobalKey<FormState> _globalKey = GlobalKey();
  final TextEditingController title = TextEditingController();
  final TextEditingController taskType = TextEditingController();
  final TextEditingController dueDate = TextEditingController();
  final TextEditingController notificationDateAndTime = TextEditingController();

  void _submitTask() async {
    if (_globalKey.currentState?.validate() ?? false) {
      final Task task = Task(
        title: title.text,
        taskType: taskType.text,
        dueDate: dueDate.text.isNotEmpty ? DateFormatter.toRawDateTime(dueDate.text) : null,
        notificationTime: notificationDateAndTime.text.isNotEmpty ? DateFormatter.fromLongMonthDayYearTime(notificationDateAndTime.text) : null,
        isCompleted: false,
        sendNotification: context.read<NotificationCubit>().state,
      );

      context.read<TaskBloc>().add(CreateTask(task));
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01, size: 34),
        ),
        title: const Text("Create Task"),
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
                  );
                  if (selectedDate != null) {
                    dueDate.text = DateFormatter.toLongMonthDayYear(selectedDate.toString());
                  }
                },
              ),
              BlocBuilder<NotificationCubit, bool>(
                builder: (context, sendNotification) {
                  return Column(
                    children: [
                      sendNotification
                          ? const SizedBox(height: 24)
                          : const SizedBox.shrink(),
                      sendNotification
                          ? CustomTextField(
                              controller: notificationDateAndTime,
                              label: "Notification Date & Time",
                              hintText: "Select date & time",
                              validationLabel: "Notification date & time",
                              isRequired: true,
                              readOnly: true,
                              onTap: () async {
                                final dateTimeStr = await pickDateTime(context);
                                if (dateTimeStr != null) {
                                  notificationDateAndTime.text = dateTimeStr;
                                }
                              },
                            )
                          : const SizedBox.shrink(),
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
                          side: const BorderSide(width: 1.4, color: AppColors.inputBorderColor),
                        ),
                        value: sendNotification,
                        onChanged: (val) {
                          if (!val) notificationDateAndTime.clear();
                          context.read<NotificationCubit>().toggleNotification(val);
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitTask,
                  child: const Text("Create Task"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> pickDateTime(BuildContext context) async {
    DateTime? lastDate = dueDate.text.isNotEmpty ? DateFormatter.parseDateTime(DateFormatter.toRawDateTime(dueDate.text)) : null;

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 30)),
    );

    if (selectedDate == null) return null;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return null;

    final fullDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    return DateFormatter.toLongMonthDayYearTime(fullDateTime.toString());
  }
}
