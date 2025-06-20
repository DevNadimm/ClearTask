import 'package:clear_task/core/constants/colors.dart';
import 'package:flutter/material.dart';

class AuthFooter extends StatelessWidget {
  final String label;
  final String actionText;
  final VoidCallback onTap;

  const AuthFooter({
    super.key,
    required this.label,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondaryFontColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}