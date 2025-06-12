import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/utils/helper_functions/get_filtered_tasks.dart';
import 'package:clear_task/presentation/blocs/task/task_bloc.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
import 'package:clear_task/presentation/blocs/task/task_state.dart';
import 'package:clear_task/presentation/screens/celebrate_success_screen.dart';
import 'package:clear_task/presentation/screens/create_task_screen.dart';
import 'package:clear_task/presentation/widgets/task_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  final List<String> _tabTitles = [
    "All",
    "Today",
    "Tomorrow",
    "Upcoming",
    "Anytime",
    "Completed",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this, initialIndex: 1);
    context.read<TaskBloc>().add(FetchTasks());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {}, icon: const Icon(HugeIcons.strokeRoundedMenu02)),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(HugeIcons.strokeRoundedSearch02)),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                "https://images.unsplash.com/photo-1613323593608-abc90fec84ff?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
              ),
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          splashBorderRadius: BorderRadius.circular(30),
          indicatorColor: AppColors.primaryColor,
          indicatorWeight: 3,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.secondaryFontColor,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create Task',
        onPressed: () => Get.to(() => const CreateTaskScreen()),
        child: const Icon(HugeIcons.strokeRoundedTaskAdd01, size: 30),
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is CelebrateSuccess) {
            Get.offAll(() => const CelebrateSuccessScreen());
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskLoaded) {
            return TabBarView(
              controller: _tabController,
              children: _tabTitles.map((title) {
                final filteredTasks = getFilteredTasks(title, state.tasks);
                return TaskListWidget(
                  tab: title,
                  tasks: filteredTasks,
                  onToggleChange: (task) {
                    context.read<TaskBloc>().add(ToggleTaskCompletion(task: task));
                  },
                );
              }).toList(),
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
}
