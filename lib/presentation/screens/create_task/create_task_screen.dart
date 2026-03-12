import 'package:clear_task/data/models/task_model.dart';
import 'package:clear_task/presentation/blocs/notification/notification_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_task_view.dart';

class CreateTaskScreen extends StatelessWidget {
  /// When provided the screen opens in edit mode.
  final Task? editTask;

  const CreateTaskScreen({super.key, this.editTask});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationCubit(),
      child: CreateTaskView(editTask: editTask),
    );
  }
}
