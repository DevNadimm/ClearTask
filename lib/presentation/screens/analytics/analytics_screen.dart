import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:clear_task/presentation/blocs/task/task_bloc.dart';
import 'package:clear_task/presentation/blocs/task/task_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Productivity Analytics',
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01, size: 34),
        ),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is! TasksLoaded) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }

          final tasks = state.tasks;
          final completedTasks = tasks.where((t) => t.isCompleted).toList();
          final pendingTasksCount = tasks.length - completedTasks.length;
          final completionRate = tasks.isEmpty ? 0.0 : (completedTasks.length / tasks.length) * 100;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow(context, completedTasks.length, pendingTasksCount, completionRate),
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
                _buildWeeklyBarChart(context, completedTasks),
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
                _buildCategoryPieChart(context, completedTasks),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, int completed, int pending, double rate) {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard(context, 'Done', completed.toString(), HugeIcons.strokeRoundedTickDouble02, Colors.greenAccent)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard(context, 'Pending', pending.toString(), HugeIcons.strokeRoundedLoading03, Colors.orangeAccent)),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
              color: context.primaryFontColor
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11, 
              fontWeight: FontWeight.w500, 
              color: context.secondaryFontColor
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart(BuildContext context, List<Task> completedTasks) {
    final now = DateTime.now();
    final Map<int, int> dayCounts = {};
    for (int i = 0; i < 7; i++) {
       final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
       dayCounts[day.weekday] = 0;
    }

    for (var task in completedTasks) {
      if (task.completedAt != null) {
        try {
          final date = DateTime.parse(task.completedAt!);
          final difference = now.difference(date).inDays;
          if (difference >= 0 && difference < 7) {
            dayCounts[date.weekday] = (dayCounts[date.weekday] ?? 0) + 1;
          }
        } catch (_) {}
      }
    }

    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<BarChartGroupData> groups = [];
    
    double maxCount = 5;
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final count = dayCounts[date.weekday] ?? 0;
      if (count > maxCount) maxCount = count.toDouble();
      
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: AppColors.primaryColor,
              width: 14,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxCount + 1,
                color: context.inputBorderColor.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 8, right: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(24),
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
                  rod.toY.toInt().toString(),
                  GoogleFonts.poppins(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(BuildContext context, List<Task> completedTasks) {
    if (completedTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            "Complete some tasks to see breakdown", 
            style: GoogleFonts.poppins(color: context.secondaryFontColor)
          )
        ),
      );
    }

    final Map<String, int> categories = {};
    for (var task in completedTasks) {
      categories[task.taskType] = (categories[task.taskType] ?? 0) + 1;
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
          title: '', // Title hidden to make it cleaner
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
        borderRadius: BorderRadius.circular(24),
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
                          style: GoogleFonts.poppins(fontSize: 12, color: context.primaryFontColor)
                        )
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${e.value})', 
                        style: GoogleFonts.poppins(fontSize: 10, color: context.secondaryFontColor)
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
