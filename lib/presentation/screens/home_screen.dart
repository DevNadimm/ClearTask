import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/utils/helper_functions/get_filtered_tasks.dart';
import 'package:clear_task/presentation/blocs/auth/auth_cubit.dart';
import 'package:clear_task/presentation/blocs/task/task_bloc.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
import 'package:clear_task/presentation/blocs/task/task_state.dart';
import 'package:clear_task/presentation/screens/create_task/create_task_screen.dart';
import 'package:clear_task/presentation/screens/search_task_screen.dart';
import 'package:clear_task/presentation/screens/analytics/analytics_screen.dart';
import 'package:clear_task/presentation/blocs/wallet/wallet_cubit.dart';
import 'package:clear_task/data/repositories/user_stats_repository.dart';
import 'package:clear_task/presentation/widgets/home_drawer_column.dart';
import 'package:clear_task/presentation/widgets/level_up_dialog.dart';
import 'package:clear_task/presentation/widgets/task_completion_dialog.dart';
import 'package:clear_task/presentation/widgets/daily_bonus_dialog.dart';
import 'package:clear_task/presentation/widgets/signup_bonus_dialog.dart';
import 'package:clear_task/presentation/widgets/task_list_widget.dart';
import 'package:clear_task/data/datasources/preferences_helper.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  StreamSubscription<int>? _levelUpSubscription;

  final List<Future<dynamic> Function()> _dialogQueue = [];
  bool _isProcessingQueue = false;

  void _enqueueDialog(Future<dynamic> Function() dialogBuilder) {
    _dialogQueue.add(dialogBuilder);
    if (!_isProcessingQueue) {
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    _isProcessingQueue = true;
    while (_dialogQueue.isNotEmpty) {
      if (!mounted) break;
      final builder = _dialogQueue.removeAt(0);
      await builder();
    }
    _isProcessingQueue = false;
  }

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
    _tabController = TabController(
      length: _tabTitles.length,
      vsync: this,
      initialIndex: 1,
    );

    final currentState = context.read<TaskBloc>().state;
    if (currentState is! TasksLoaded) {
      context.read<TaskBloc>().add(FetchTasks());
    }

    _levelUpSubscription =
        UserStatsRepository().levelUpStream.listen((newLevel) {
      _enqueueDialog(
        () => Get.dialog(
          LevelUpDialog(newLevel: newLevel),
          barrierDismissible: false,
        ),
      );
    });

    // Check for daily login bonus (XP + Coins)
    _checkDailyBonus();
  }

  Future<void> _checkDailyBonus() async {
    // Small delay to ensure the screen is stable and navigation has finished
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    final pref = PreferencesHelper();
    final authState = context.read<AuthCubit>().state;
    if (authState.status != AuthStatus.authenticated) return;
    final userId = authState.user!.uid;

    // 1. Check for Signup Bonus
    final isNewUser = await pref.wasJustSignedUp();
    if (isNewUser && mounted) {
      // Wait extra time for AuthService._initializeUserData to complete
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      // Refresh wallet from Firestore (now it should have 45 coins)
      await context.read<WalletCubit>().fetchWallet(userId);

      _enqueueDialog(() => Get.dialog(
            const SignupBonusDialog(),
            barrierDismissible: false,
          ));
      // Reset the flag so it doesn't show again
      await pref.setJustSignedUp(false);
    }

    // 2. Check for Daily Login Bonus (XP + Coins) — returning users OR new users arriving for the first time
    final wasAwarded = await UserStatsRepository().checkAndAwardLoginBonus();
    if (wasAwarded && mounted) {
      // Claim coins in Firestore
      await context.read<WalletCubit>().claimDailyReward(userId);
      _enqueueDialog(() => Get.dialog(
            const DailyBonusDialog(),
            barrierDismissible: false,
          ));
    }

    // Always refresh wallet to keep UI in sync
    if (mounted) {
      await context.read<WalletCubit>().fetchWallet(userId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _levelUpSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, current) =>
          prev.status != current.status &&
          current.status == AuthStatus.authenticated,
      listener: (context, authState) {
        // Re-trigger bonus check whenever the user becomes authenticated
        // (Handles sign-ups from Cloud Backup or other sub-screens)
        _checkDailyBonus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(HugeIcons.strokeRoundedMenu02),
            ),
          ),
          title: Row(
            children: [
              Image.asset(
                'assets/icons/clear_task_icon_png.png',
                scale: 44,
              ),
              const SizedBox(width: 8),
              Text(
                'Clear Task',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => Get.to(() => const AnalyticsScreen()),
              icon: const Icon(HugeIcons.strokeRoundedAnalytics01),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () => Get.to(() => const SearchTaskScreen()),
                icon: const Icon(HugeIcons.strokeRoundedSearch01),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: EdgeInsets.zero,
            splashBorderRadius: BorderRadius.circular(30),
            indicatorColor: AppColors.primaryColor,
            indicatorWeight: 3,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: context.secondaryFontColor,
            labelStyle:
                GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.normal, fontSize: 14),
            tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
          ),
        ),
        drawer: Drawer(
          backgroundColor: context.backgroundColor,
          child: const HomeDrawerColumn(),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Create Task',
          onPressed: () => Get.to(() => const CreateTaskScreen()),
          child: const Icon(HugeIcons.strokeRoundedAdd01, size: 30),
        ),
        body: BlocConsumer<TaskBloc, TaskState>(
          listener: (context, state) {
            if (state is CelebrateSuccess) {
              _enqueueDialog(() => Get.dialog(
                    const TaskCompletionDialog(),
                    barrierDismissible: false,
                  ));
            }
          },
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TasksLoaded) {
              return TabBarView(
                controller: _tabController,
                children: _tabTitles.map((title) {
                  final filteredTasks = getFilteredTasks(title, state.tasks);
                  return TaskListWidget(
                    tab: title,
                    tasks: filteredTasks,
                    onToggleChange: (task) {
                      context
                          .read<TaskBloc>()
                          .add(ToggleTaskCompletion(task: task));
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
        ), // closes BlocBuilder inside Scaffold
      ), // closes Scaffold
    ); // closes BlocListener
  }
}
