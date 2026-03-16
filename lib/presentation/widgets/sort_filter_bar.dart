import 'package:clear_task/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

enum SortOption { defaultSort, dueDate, priority, alphabetical }

class SortFilterBottomSheet extends StatefulWidget {
  final SortOption selectedSort;
  final bool uncompletedFirst;
  final ValueChanged<SortOption> onSortChanged;
  final ValueChanged<bool> onUncompletedFirstChanged;

  const SortFilterBottomSheet({
    super.key,
    required this.selectedSort,
    required this.uncompletedFirst,
    required this.onSortChanged,
    required this.onUncompletedFirstChanged,
  });

  @override
  State<SortFilterBottomSheet> createState() => _SortFilterBottomSheetState();
}

class _SortFilterBottomSheetState extends State<SortFilterBottomSheet> {
  late SortOption _currentSort;
  late bool _currentUncompletedFirst;

  static const List<_SortItem> _sortItems = [
    _SortItem(option: SortOption.defaultSort, label: 'Default', icon: HugeIcons.strokeRoundedDashboardSquare01),
    _SortItem(option: SortOption.dueDate,     label: 'Due Date', icon: HugeIcons.strokeRoundedCalendar04),
    _SortItem(option: SortOption.priority,    label: 'Priority', icon: HugeIcons.strokeRoundedFlag03),
    _SortItem(option: SortOption.alphabetical, label: 'A → Z',  icon: HugeIcons.strokeRoundedSorting01),
  ];

  @override
  void initState() {
    super.initState();
    _currentSort = widget.selectedSort;
    _currentUncompletedFirst = widget.uncompletedFirst;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Sort & Filter",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.primaryFontColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(HugeIcons.strokeRoundedCancel01),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ── Sort by section ───────────────────────────────────────────
            Text(
              "Sort by",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.secondaryFontColor,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(_sortItems.length, (index) {
              final item = _sortItems[index];
              final bool isSelected = _currentSort == item.option;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Material(
                  color: isSelected
                      ? AppColors.primaryColor.withValues(alpha: 0.2)
                      : context.inputBorderColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    splashColor: AppColors.primaryColorTransparent,
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      setState(() => _currentSort = item.option);
                      widget.onSortChanged(item.option);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(width: 1, color: AppColors.primaryColor)
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : context.secondaryFontColor,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                item.label,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : context.primaryFontColor,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                HugeIcons.strokeRoundedTick02,
                                size: 20,
                                color: AppColors.primaryColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // ── Filter section ────────────────────────────────────────────
            Text(
              "Filter",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.secondaryFontColor,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Material(
                color: _currentUncompletedFirst
                    ? AppColors.success.withValues(alpha: 0.15)
                    : context.inputBorderColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  splashColor: AppColors.primaryColorTransparent,
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    setState(() => _currentUncompletedFirst = !_currentUncompletedFirst);
                    widget.onUncompletedFirstChanged(_currentUncompletedFirst);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: _currentUncompletedFirst
                          ? Border.all(width: 1, color: AppColors.success)
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(
                            HugeIcons.strokeRoundedFilterHorizontal,
                            size: 20,
                            color: _currentUncompletedFirst
                                ? AppColors.success
                                : context.secondaryFontColor,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              "Pending First",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: _currentUncompletedFirst
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: _currentUncompletedFirst
                                    ? AppColors.success
                                    : context.primaryFontColor,
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _currentUncompletedFirst
                                  ? AppColors.success
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _currentUncompletedFirst
                                    ? AppColors.success
                                    : context.inputBorderColor,
                                width: 1.5,
                              ),
                            ),
                            child: _currentUncompletedFirst
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SortItem {
  final SortOption option;
  final String label;
  final IconData icon;

  const _SortItem({
    required this.option,
    required this.label,
    required this.icon,
  });
}
