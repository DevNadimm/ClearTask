import 'package:clear_task/presentation/blocs/task/task_bloc.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
import 'package:clear_task/presentation/blocs/task/task_state.dart';
import 'package:clear_task/presentation/widgets/task_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:clear_task/core/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class SearchTaskScreen extends StatefulWidget {
  const SearchTaskScreen({super.key});

  @override
  State<SearchTaskScreen> createState() => _SearchTaskScreenState();
}

class _SearchTaskScreenState extends State<SearchTaskScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(FetchTasks());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.read<TaskBloc>().add(FetchTasks());
            Get.back();
          },
          icon: const Icon(
            HugeIcons.strokeRoundedArrowLeft01,
            size: 34,
          ),
        ),
        title: _buildSearchField(),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(8),
          child: SizedBox(height: 8),
        ),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TasksLoaded) {
            return TaskListWidget(
              tasks: state.tasks,
              isInSearchMode: _searchController.text.isNotEmpty,
              showTabEmptyMessage: false,
              onToggleChange: (task) {
                context.read<TaskBloc>().add(ToggleTaskCompletion(task: task));
              },
            );
          }

          if (state is TaskError) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/icons/error.png", scale: 5),
                    const SizedBox(height: 20),
                    Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      onChanged: (value) {
        context.read<TaskBloc>().add(SearchTasks(value));
      },
      decoration: InputDecoration(
        hintText: 'Search tasks...',
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: AppColors.cardColor,
        prefixIcon: const Icon(HugeIcons.strokeRoundedSearch02, color: Colors.white70),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(HugeIcons.strokeRoundedCancel01, color: Colors.white70),
                onPressed: () {
                  _searchController.clear();
                  FocusScope.of(context).unfocus();
                  context.read<TaskBloc>().add(FetchTasks());
                },
              )
            : null,
        border: _buildOutlineInputBorder(),
        enabledBorder: _buildOutlineInputBorder(),
        focusedBorder: _buildOutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }

  OutlineInputBorder _buildOutlineInputBorder () {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    );
  }
}
