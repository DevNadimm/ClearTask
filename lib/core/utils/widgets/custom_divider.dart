import 'package:clear_task/core/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double? height;
  final double? width;

  const CustomDivider({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 1,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.inputBorderColor.withValues(alpha: 0.1),
            context.inputBorderColor,
            context.inputBorderColor.withValues(alpha: 0.1),
          ],
        ),
      ),
    );
  }
}
