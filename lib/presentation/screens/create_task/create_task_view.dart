import 'dart:convert';
import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/constants/task_type.dart';
import 'package:clear_task/core/utils/formatter/date_formatter.dart';
import 'package:clear_task/core/utils/helper_functions/get_priority_color.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:clear_task/data/repositories/task_local_repository.dart';
import 'package:clear_task/presentation/blocs/notification/notification_cubit.dart';
import 'package:clear_task/presentation/blocs/task/task_bloc.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
import 'package:clear_task/presentation/widgets/bottom_sheet_widget.dart';
import 'package:clear_task/presentation/widgets/custom_text_field.dart';
import 'package:clear_task/presentation/widgets/rich_text_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:clear_task/data/services/ai_service.dart';
import 'package:clear_task/presentation/blocs/premium/premium_cubit.dart';
import 'package:clear_task/presentation/widgets/ai_limit_dialog.dart';

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
  final ScrollController _scrollController = ScrollController();
  final FocusNode _noteFocusNode = FocusNode();
  final GlobalKey _noteKey = GlobalKey();

  /// New subtask fields (not yet persisted).
  final List<TextEditingController> _newSubtaskControllers = [];
  final List<FocusNode> _subtaskFocusNodes = [];
  final List<GlobalKey> _subtaskKeys = [];

  /// Copy of existing subtasks shown when editing (mutated by delete).
  late List<Subtask> _existingSubtasks;

  /// Subtasks marked for deletion (executed on save).
  final List<Subtask> _subtasksToDelete = [];

  bool _isGeneratingSubtasks = false;
  String _selectedPriority = 'none';

  /// Rich text note stored as Delta JSON string.
  String? _noteJson;

  static const List<String> _priorities = ['none', 'low', 'medium', 'high'];

  bool get _isEditing => widget.editTask != null;

  @override
  void initState() {
    super.initState();
    _existingSubtasks = List.from(widget.editTask?.subtasks ?? []);

    if (_isEditing) {
      final t = widget.editTask!;
      title.text = t.title;
      taskType.text = t.taskType;
      _selectedPriority = t.priority;
      _noteJson = t.note;

      if (t.dueDate != null) {
        dueDate.text = DateFormatter.toLongMonthDayYear(t.dueDate!);
      }
      if (t.notificationTime != null) {
        notificationDateAndTime.text = DateFormatter.toLongMonthDayYearTime(t.notificationTime!);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<NotificationCubit>().toggleNotification(t.sendNotification);
      });
    }

    _noteFocusNode.addListener(_onNoteFocusChange);
  }

  void _onNoteFocusChange() {
    if (_noteFocusNode.hasFocus) {
      // Small delay to allow the keyboard to show up and layout to adjust
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_noteKey.currentContext != null) {
          Scrollable.ensureVisible(
            _noteKey.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.0, // 0.0 means top of viewport
          );
        }
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
    for (final f in _subtaskFocusNodes) {
      f.dispose();
    }
    _noteFocusNode.removeListener(_onNoteFocusChange);
    _noteFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addSubtaskField() {
    setState(() {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      final key = GlobalKey();
      
      _newSubtaskControllers.add(controller);
      _subtaskFocusNodes.add(focusNode);
      _subtaskKeys.add(key);

      focusNode.addListener(() => _onSubtaskFocusChange(focusNode, key));
    });
  }

  void _onSubtaskFocusChange(FocusNode node, GlobalKey key) {
    if (node.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.0,
          );
        }
      });
    }
  }

  void _removeNewSubtaskField(int index) {
    _newSubtaskControllers[index].dispose();
    _subtaskFocusNodes[index].dispose();
    setState(() {
      _newSubtaskControllers.removeAt(index);
      _subtaskFocusNodes.removeAt(index);
      _subtaskKeys.removeAt(index);
    });
  }

  void _deleteExistingSubtask(Subtask subtask) {
    _subtasksToDelete.add(subtask);
    setState(() => _existingSubtasks.removeWhere((s) => s.id == subtask.id));
  }

  Future<void> _generateSubtasks() async {
    final messenger = ScaffoldMessenger.of(context);
    
    if (title.text.trim().isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text("Please enter a task title first to generate subtasks.", style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final premiumCubit = context.read<PremiumCubit>();
    if (!premiumCubit.state.canUseAi) {
      AiLimitDialog.show(context);
      return;
    }

    setState(() => _isGeneratingSubtasks = true);

    final allowed = await premiumCubit.tryUseAi();
    if (!allowed) {
      if (mounted) setState(() => _isGeneratingSubtasks = false);
      AiLimitDialog.show(context);
      return;
    }

    try {
      String? cleanNote;
      if (_noteJson != null && _noteJson!.isNotEmpty) {
        try {
          final List<dynamic> delta = jsonDecode(_noteJson!);
          final buffer = StringBuffer();
          for (final op in delta) {
            if (op['insert'] is String) {
              buffer.write(op['insert']);
            }
          }
          cleanNote = buffer.toString().trim();
        } catch (_) {
          cleanNote = _noteJson;
        }
      }

      final generatedSubtasks = await AiService.generateSubtasks(
        title: title.text,
        taskType: taskType.text,
        note: cleanNote,
      );
      if (generatedSubtasks.isNotEmpty) {
        setState(() {
          for (final subtaskTitle in generatedSubtasks) {
            final controller = TextEditingController(text: subtaskTitle);
            final focusNode = FocusNode();
            final key = GlobalKey();
            
            _newSubtaskControllers.add(controller);
            _subtaskFocusNodes.add(focusNode);
            _subtaskKeys.add(key);
            
            focusNode.addListener(() => _onSubtaskFocusChange(focusNode, key));
          }
        });
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text("AI couldn't generate subtasks for this title.", style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      messenger.showSnackBar(
        SnackBar(
          content: Text("Failed to generate subtasks: ${e.toString()}", style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGeneratingSubtasks = false);
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  void _submitTask() async {
    if (!(_globalKey.currentState?.validate() ?? false)) return;

    final sendNotification = context.read<NotificationCubit>().state;
    final bloc = context.read<TaskBloc>();

    final newSubtaskTitles = _newSubtaskControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

    if (_isEditing) {
      // ── Edit mode ──────────────────────────────────────────────────────────
      final updatedTask = widget.editTask!.copyWith(
        title: title.text,
        note: _noteJson,
        taskType: taskType.text,
        priority: _selectedPriority,
        dueDate: dueDate.text.isNotEmpty
            ? DateFormatter.toRawDateTime(dueDate.text)
            : null,
        notificationTime: notificationDateAndTime.text.isNotEmpty
            ? DateFormatter.fromLongMonthDayYearTime(
                notificationDateAndTime.text)
            : null,
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
      }

      // Actually delete subtasks that were removed in the UI.
      if (_subtasksToDelete.isNotEmpty) {
        for (final s in _subtasksToDelete) {
          bloc.add(DeleteSubtask(subtask: s));
        }
      }

      bloc.add(FetchTasks());
    } else {
      // ── Create mode ────────────────────────────────────────────────────────
      final task = Task(
        title: title.text,
        note: _noteJson,
        taskType: taskType.text,
        priority: _selectedPriority,
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
          onPressed: () => Get.back(),
          icon: Icon(
            HugeIcons.strokeRoundedArrowLeft01,
            size: 30,
            color: context.primaryFontColor,
          ),
        ),
        title: Text(_isEditing ? "Edit Task" : "Create Task"),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
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

              // ── Priority selector ─────────────────────────────────────────
              Text(
                "Priority",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.primaryFontColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: context.cardColor, //context.inputBorderColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: context.inputBorderColor,
                    width: 1.4,
                  ),
                ),
                child: Row(
                  children: _priorities.map((p) {
                    final bool isSelected = _selectedPriority == p;
                    final Color chipColor = getPriorityColor(context, p);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPriority = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? chipColor.withValues(alpha: 0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              getPriorityLabel(p),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? chipColor
                                    : context.secondaryFontColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: dueDate,
                label: "Due Date",
                hintText: "Select date",
                validationLabel: "Due date",
                readOnly: true,
                onTap: () async {
                  DateTime now = DateTime.now();
                  DateTime initialDate = now;
                  if (dueDate.text.isNotEmpty) {
                    initialDate =
                        DateTime.parse(DateFormatter.toRawDateTime(dueDate.text));
                  }
                  
                  // If initialDate is in the past, we must set firstDate to initialDate (or earlier) 
                  // to avoid Flutter throwing an error.
                  DateTime firstDate = initialDate.isBefore(now) ? initialDate : now;

                  DateTime? selected = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: firstDate,
                    lastDate:
                        now.add(const Duration(days: 365 * 2)),
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
                            color: context.primaryFontColor,
                          ),
                        ),
                        tileColor: context.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                              width: 1.4,
                              color: context.inputBorderColor),
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

              // ── Note (Rich Text) section ────────────────────────────────
              const SizedBox(height: 24),
              RichTextEditor(
                key: _noteKey,
                focusNode: _noteFocusNode,
                initialDeltaJson: _noteJson,
                onChanged: (json) => _noteJson = json,
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
                      color: context.primaryFontColor,
                    ),
                  ),
                  const Spacer(),
                  if (_isGeneratingSubtasks)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                        ),
                      ),
                    )
                  else
                    TextButton.icon(
                      onPressed: _generateSubtasks,
                      icon: HugeIcon(icon: HugeIcons.strokeRoundedAiMagic, size: 18, color: Colors.amber.shade600),
                      label: Text("AI", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                      style: TextButton.styleFrom(foregroundColor: Colors.amber.shade600),
                    ),
                  TextButton.icon(
                    onPressed: _addSubtaskField,
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 18, color: AppColors.primaryColor),
                    label: Text("Add", style: GoogleFonts.poppins(fontSize: 13)),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
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
                          color: context.secondaryFontColor),
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
                                  ? context.secondaryFontColor
                                  : context.primaryFontColor,
                              decoration: subtask.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: context.secondaryFontColor,
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
                        color: context.secondaryFontColor),
                  ),
                ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _newSubtaskControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    key: _subtaskKeys[index],
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _newSubtaskControllers[index],
                            focusNode: _subtaskFocusNodes[index],
                            style: GoogleFonts.poppins(color: context.primaryFontColor),
                            decoration: InputDecoration(
                              hintText: "New subtask ${index + 1}",
                              hintStyle: GoogleFonts.poppins(color: context.secondaryFontColor),
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
    DateTime now = DateTime.now();
    DateTime initialDate = now;
    TimeOfDay initialTime = TimeOfDay.now();

    if (notificationDateAndTime.text.isNotEmpty) {
      final parsed = DateTime.parse(DateFormatter.toRawDateTime(notificationDateAndTime.text));
      initialDate = parsed;
      initialTime = TimeOfDay(hour: parsed.hour, minute: parsed.minute);
    }

    // firstDate must be <= initialDate
    DateTime firstDate = initialDate.isBefore(now) ? initialDate : now;

    // lastDate must be >= initialDate
    DateTime lastDate = now.add(const Duration(days: 30));
    if (dueDate.text.isNotEmpty) {
      lastDate = DateTime.parse(DateFormatter.toRawDateTime(dueDate.text));
    }
    if (lastDate.isBefore(firstDate)) {
      lastDate = firstDate.add(const Duration(days: 30));
    }

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (selectedDate == null) return null;

    if (!context.mounted) return null;
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
