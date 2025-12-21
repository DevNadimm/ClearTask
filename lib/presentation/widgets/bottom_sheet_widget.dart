import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/utils/helper_functions/get_task_type_emoji.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class BottomSheetWidget extends StatelessWidget {
  final String type;
  final List<String> types;
  final Function(String type) selectType;

  const BottomSheetWidget({
    super.key,
    required this.type,
    required this.types,
    required this.selectType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Type",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryFontColor,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(HugeIcons.strokeRoundedCancel01),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: types.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final taskType = types[index];
                  final bool isSelected = type == taskType;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Material(
                      color: isSelected
                          ? AppColors.primaryColor.withValues(alpha: 0.2)
                          : AppColors.inputBorderColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        splashColor: AppColors.primaryColorTransparent,
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          selectType(taskType);
                          Get.back();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(width: 1, color: AppColors.primaryColor)
                                : null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              "${getTaskTypeEmoji(taskType)} $taskType",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppColors.primaryFontColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
