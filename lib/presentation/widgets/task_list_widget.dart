import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/utils/helper_functions/get_empty_message.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:clear_task/presentation/widgets/task_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TaskListWidget extends StatelessWidget {
  final String tab;
  final List<Task> tasks;
  final Function(Task task) onToggleChange;
  final BannerAd? bannerAd;

  final bool showTabEmptyMessage;
  final bool isInSearchMode;

  const TaskListWidget({
    super.key,
    this.tab = "All",
    required this.tasks,
    required this.onToggleChange,
    this.bannerAd,
    this.showTabEmptyMessage = true,
    this.isInSearchMode = false,
  });

  final String searchNotFoundMessage = "No tasks found!\nPlease try a different keyword.";
  final String noTasksMessage = "No tasks yet!\nStart by creating a new one.";

  String _buildEmptyStateMessage() {
    if (showTabEmptyMessage) return getEmptyMessage(tab);
    if (isInSearchMode) return searchNotFoundMessage;
    return noTasksMessage;
  }

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _buildEmptyStateMessage(),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.primaryFontColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bool showAd = bannerAd != null && tab == 'All' && tasks.length >= 3;
    final int taskLength = tasks.length + (showAd ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: taskLength,
      itemBuilder: (context, index) {
        if (showAd && index == taskLength - 1) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              width: bannerAd!.size.width.toDouble(),
              height: bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: bannerAd!),
            ),
          );
        }

        final task = tasks[index];
        return TaskCardWidget(
          task: task,
          onToggleChange: (task) => onToggleChange(task),
        );
      },
    );
  }
}