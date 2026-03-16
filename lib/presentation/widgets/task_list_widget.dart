import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/utils/formatter/date_formatter.dart';
import 'package:clear_task/core/utils/helper_functions/get_empty_message.dart';
import 'package:clear_task/core/utils/helper_functions/get_priority_color.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:clear_task/presentation/widgets/sort_filter_bar.dart';
import 'package:clear_task/presentation/widgets/task_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hugeicons/hugeicons.dart';

class TaskListWidget extends StatefulWidget {
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

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  // Keep a stable widget instance — never rebuild unless ad object changes
  Widget? _adWidget;
  BannerAd? _lastAd;

  // Sort & filter state
  SortOption _selectedSort = SortOption.defaultSort;
  bool _uncompletedFirst = false;

  Widget _getAdWidget(BannerAd ad) {
    if (_lastAd != ad || _adWidget == null) {
      _lastAd = ad;
      _adWidget = SizedBox(
        key: UniqueKey(),
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      );
    }
    return _adWidget!;
  }

  final String searchNotFoundMessage = "No tasks found!\nPlease try a different keyword.";
  final String noTasksMessage = "No tasks yet!\nStart by creating a new one.";

  String _buildEmptyStateMessage() {
    if (widget.showTabEmptyMessage) return getEmptyMessage(widget.tab);
    if (widget.isInSearchMode) return searchNotFoundMessage;
    return noTasksMessage;
  }

  bool get _isFilterActive =>
      _selectedSort != SortOption.defaultSort || _uncompletedFirst;

  void _openSortFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) {
        return SortFilterBottomSheet(
          selectedSort: _selectedSort,
          uncompletedFirst: _uncompletedFirst,
          onSortChanged: (sort) => setState(() => _selectedSort = sort),
          onUncompletedFirstChanged: (val) =>
              setState(() => _uncompletedFirst = val),
        );
      },
    );
  }

  List<Task> _applySortAndFilter(List<Task> tasks) {
    List<Task> result = List.from(tasks);

    // Apply sort
    switch (_selectedSort) {
      case SortOption.dueDate:
        result.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return DateFormatter.parseDateTime(a.dueDate!)
              .compareTo(DateFormatter.parseDateTime(b.dueDate!));
        });
        break;
      case SortOption.priority:
        result.sort((a, b) {
          return getPriorityValue(b.priority)
              .compareTo(getPriorityValue(a.priority));
        });
        break;
      case SortOption.alphabetical:
        result.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.defaultSort:
        break;
    }

    // Apply uncompleted-first filter
    if (_uncompletedFirst) {
      final uncompleted = result.where((t) => !t.isCompleted).toList();
      final completed = result.where((t) => t.isCompleted).toList();
      result = [...uncompleted, ...completed];
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
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
                  color: context.primaryFontColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sortedTasks = _applySortAndFilter(widget.tasks);
    final bool showAd = widget.bannerAd != null &&
        widget.tab == 'All' &&
        sortedTasks.length >= 3;
    final int taskLength = sortedTasks.length + (showAd ? 1 : 0);

    return Column(
      children: [
        // ── Filter button row ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 8, top: 8),
          child: Row(
            children: [
              Text(
                "${widget.tasks.length} task${widget.tasks.length == 1 ? '' : 's'}",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: context.secondaryFontColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Material(
                color: _isFilterActive
                    ? AppColors.primaryColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: _openSortFilterSheet,
                  borderRadius: BorderRadius.circular(10),
                  splashColor: AppColors.primaryColorTransparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          HugeIcons.strokeRoundedFilterHorizontal,
                          size: 18,
                          color: _isFilterActive
                              ? AppColors.primaryColor
                              : context.secondaryFontColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isFilterActive ? "Filtered" : "Filter",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: _isFilterActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: _isFilterActive
                                ? AppColors.primaryColor
                                : context.secondaryFontColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Task list ─────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: taskLength,
            itemBuilder: (context, index) {
              if (showAd && index == taskLength - 1) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _getAdWidget(widget.bannerAd!),
                );
              }

              final task = sortedTasks[index];
              return TaskCardWidget(
                task: task,
                onToggleChange: (task) => widget.onToggleChange(task),
              );
            },
          ),
        ),
      ],
    );
  }
}