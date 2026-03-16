import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/utils/helper_functions/ad_helper.dart';
import 'package:clear_task/core/utils/helper_functions/get_filtered_tasks.dart';
import 'package:clear_task/core/utils/widgets/custom_divider.dart';
import 'package:clear_task/presentation/blocs/task/task_bloc.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
import 'package:clear_task/presentation/blocs/task/task_state.dart';
import 'package:clear_task/presentation/blocs/theme/theme_cubit.dart';
import 'package:clear_task/presentation/screens/celebrate_success_screen.dart';
import 'package:clear_task/presentation/screens/create_task/create_task_screen.dart';
import 'package:clear_task/presentation/screens/search_task_screen.dart';
import 'package:clear_task/presentation/screens/analytics/analytics_screen.dart';
import 'package:clear_task/presentation/screens/pomodoro/pomodoro_screen.dart';
import 'package:clear_task/presentation/screens/cloud_backup_screen.dart';
import 'package:clear_task/presentation/screens/developer_info_screen.dart';
import 'package:clear_task/core/services/contact_service.dart';
import 'package:clear_task/presentation/widgets/task_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  void _loadBannerAd() {
    // Dispose old ad first
    _bannerAd?.dispose();
    _bannerAd = null;

    setState(() {
      _isAdLoaded = false;
    });

    final ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _bannerAd = ad as BannerAd;
            _isAdLoaded = true;
// 👈 new key = new AdWidget instance
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    ad.load();
  }

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
    _tabController = TabController(
      length: _tabTitles.length,
      vsync: this,
      initialIndex: 1,
    );

    final currentState = context.read<TaskBloc>().state;
    if (currentState is! TasksLoaded) {
      context.read<TaskBloc>().add(FetchTasks());
    }

    _loadBannerAd();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return HugeIcons.strokeRoundedSun03;
      case ThemeMode.dark:
        return HugeIcons.strokeRoundedMoon02;
      case ThemeMode.system:
        return HugeIcons.strokeRoundedSmartPhone01;
    }
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light Theme';
      case ThemeMode.dark:
        return 'Dark Theme';
      case ThemeMode.system:
        return 'System Theme';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.normal, fontSize: 14),
          tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
        ),
      ),
      drawer: Drawer(
        backgroundColor: context.backgroundColor,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: context.cardColor),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/clear_task_icon_png.png', scale: 15),
                    const SizedBox(height: 10),
                    Text(
                      'Clear Task',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: context.primaryFontColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(HugeIcons.strokeRoundedAnalytics01, color: AppColors.primaryColor),
              title: Text('Analytics', style: GoogleFonts.poppins(color: context.primaryFontColor)),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const AnalyticsScreen());
              },
            ),
            ListTile(
              leading: const Icon(HugeIcons.strokeRoundedTimer01, color: AppColors.primaryColor),
              title: Text('Focus Timer', style: GoogleFonts.poppins(color: context.primaryFontColor)),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const PomodoroScreen());
              },
            ),
            ListTile(
              leading: const Icon(HugeIcons.strokeRoundedCloud, color: AppColors.primaryColor),
              title: Text('Cloud Backup', style: GoogleFonts.poppins(color: context.primaryFontColor)),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const CloudBackupScreen());
              },
            ),
            ListTile(
              leading: const Icon(HugeIcons.strokeRoundedUser03, color: AppColors.primaryColor),
              title: Text('Developer Info', style: GoogleFonts.poppins(color: context.primaryFontColor)),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const DeveloperInfoScreen());
              },
            ),
            ListTile(
              leading: const Icon(HugeIcons.strokeRoundedAlertCircle, color: AppColors.primaryColor),
              title: Text('Report Bug', style: GoogleFonts.poppins(color: context.primaryFontColor)),
              onTap: () {
                Navigator.pop(context);
                ContactService.reportBug();
              },
            ),
            const CustomDivider(),
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) {
                return ListTile(
                  leading: Icon(_themeIcon(mode), color: AppColors.primaryColor),
                  title: Text(_themeLabel(mode), style: GoogleFonts.poppins(color: context.primaryFontColor)),
                  subtitle: Text(
                    'Tap to switch',
                    style: GoogleFonts.poppins(fontSize: 11, color: context.secondaryFontColor),
                  ),
                  onTap: () => context.read<ThemeCubit>().toggleTheme(),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
              child: Text(
                'Version 1.0.0',
                style: GoogleFonts.poppins(color: context.secondaryFontColor, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create Task',
        onPressed: () => Get.to(() => const CreateTaskScreen()),
        child: const Icon(HugeIcons.strokeRoundedAdd01, size: 30),
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is CelebrateSuccess) {
            Get.to(() => const CelebrateSuccessScreen());
          }
          // 👇 Reload ad whenever task list changes to avoid stale AdWidget
          if (state is TaskDeleted || state is AllTasksDeleted) {
            _loadBannerAd();
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // In BlocConsumer builder, TasksLoaded section:
          if (state is TasksLoaded) {
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
                  bannerAd: (_isAdLoaded && title == 'All') ? _bannerAd : null, // no adKey
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