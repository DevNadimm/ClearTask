import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Select Type",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(HugeIcons.strokeRoundedCancel01))
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: types.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final taskType = types[index];
                final bool isSelected = type == taskType;
                return Card(
                  color: AppColors.cardColor,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text("${getTaskTypeEmoji(taskType)} $taskType"),
                    trailing: isSelected
                        ? const Icon(
                      HugeIcons.strokeRoundedCheckmarkCircle03,
                      color: AppColors.primaryColor,
                    )
                        : const SizedBox(),
                    onTap: () {
                      selectType(taskType);
                      Get.back();
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
