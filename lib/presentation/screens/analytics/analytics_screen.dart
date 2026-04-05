import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:clear_task/data/models/user_profile_model.dart';
import 'package:clear_task/data/repositories/user_stats_repository.dart';
import 'package:clear_task/presentation/blocs/task/task_bloc.dart';
import 'package:clear_task/presentation/blocs/task/task_state.dart';
import 'package:clear_task/presentation/screens/analytics/analytics_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:clear_task/presentation/widgets/level_up_dialog.dart';
import 'dart:async';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
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

  @override
  void initState() {
    super.initState();
    _levelUpSubscription = UserStatsRepository().levelUpStream.listen((newLevel) {
      _enqueueDialog(() => Get.dialog(
        LevelUpDialog(newLevel: newLevel),
        barrierDismissible: false,
      ));
    });
  }

  @override
  void dispose() {
    _levelUpSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity Analytics'),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            HugeIcons.strokeRoundedArrowLeft01,
            size: 30,
            color: context.primaryFontColor,
          ),
        ),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is! TasksLoaded) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }

          final tasks = state.tasks;
          final completedUnits = AnalyticsService.getTrueCompletionCount(tasks);
          final pendingUnits = AnalyticsService.getTotalIncompleteUnits(tasks);
          final totalTasks = tasks.length;
          final overallScore = AnalyticsService.calculateOverallScore(tasks);
          final scoreRate = totalTasks == 0 ? 0.0 : (overallScore / totalTasks) * 100;

          return StreamBuilder<UserProfileModel?>(
            stream: UserStatsRepository().getUserProfileStream(),
            builder: (context, snapshot) {
              final profile = snapshot.data;
              
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (profile != null) ...[
                      _buildLevelProgressCard(context, profile),
                      const SizedBox(height: 24),
                    ],
                    _buildSummaryRow(context, completedUnits, pendingUnits, scoreRate),
                    const SizedBox(height: 32),
                    Text(
                      'Weekly Activity',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.primaryFontColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildWeeklyBarChart(context, tasks),
                    const SizedBox(height: 32),
                    Text(
                      'Category Breakdown',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.primaryFontColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryPieChart(context, tasks),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLevelProgressCard(BuildContext context, UserProfileModel profile) {
    int currentXpInLevel = profile.xp % 100;
    double progress = currentXpInLevel / 100.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${profile.level}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    profile.rankTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(HugeIcons.strokeRoundedCrown, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'XP Progress',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Text(
                '$currentXpInLevel / 100 XP',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, int completed, int pending, double rate) {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard(context, 'Units Done', completed.toString(), HugeIcons.strokeRoundedTickDouble02, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard(context, 'Pending', pending.toString(), HugeIcons.strokeRoundedLoading03, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard(context, 'Score', '${rate.toStringAsFixed(0)}%', HugeIcons.strokeRoundedRocket01, AppColors.primaryColor)),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1, color: context.inputBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.primaryFontColor,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: context.secondaryFontColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart(BuildContext context, List<Task> tasks) {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    List<BarChartGroupData> groups = AnalyticsService.getWeeklyData(tasks, context, AppColors.primaryColor);
    double maxCount = AnalyticsService.getMaxWeeklyScore(tasks);

    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 8, right: 8),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1, color: context.inputBorderColor),
      ),
      child: BarChart(
        BarChartData(
          barGroups: groups,
          maxY: maxCount + 1,
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = now.subtract(Duration(days: 6 - value.toInt()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      weekdays[date.weekday - 1],
                      style: GoogleFonts.poppins(fontSize: 10, color: context.secondaryFontColor),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => context.cardColor,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toStringAsFixed(1),
                  GoogleFonts.poppins(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(BuildContext context, List<Task> tasks) {
    final Map<String, double> categories = AnalyticsService.getCategoryBreakdown(tasks);

    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 1, color: context.inputBorderColor),
        ),
        child: Center(
          child: Text(
            "Complete some tasks to see breakdown",
            style: GoogleFonts.poppins(color: context.secondaryFontColor),
          ),
        ),
      );
    }

    final List<PieChartSectionData> sections = [];
    final List<Color> palette = [
      AppColors.primaryColor,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.redAccent,
      Colors.tealAccent,
      Colors.pinkAccent,
    ];

    int i = 0;
    categories.forEach((cat, count) {
      sections.add(
        PieChartSectionData(
          value: count.toDouble(),
          title: '',
          radius: 20,
          color: palette[i % palette.length],
          showTitle: false,
        ),
      );
      i++;
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1, color: context.inputBorderColor),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 4,
                centerSpaceRadius: 35,
                startDegreeOffset: -90,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categories.entries.map((e) {
                final color = palette[categories.keys.toList().indexOf(e.key) % palette.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          e.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 12, color: context.primaryFontColor),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${e.value.toStringAsFixed(e.value.truncateToDouble() == e.value ? 0 : 1)})',
                        style: GoogleFonts.poppins(fontSize: 10, color: context.secondaryFontColor),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
