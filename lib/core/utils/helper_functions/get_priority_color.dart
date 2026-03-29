import 'package:clear_task/core/constants/colors.dart';
import 'package:flutter/material.dart';

Color getPriorityColor(BuildContext context, String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return const Color(0xFFEF5350); // Red
    case 'medium':
      return const Color(0xFFFFA726); // Orange
    case 'low':
      return const Color(0xFF42A5F5); // Blue
    default:
      return context.secondaryFontColor;
  }
}

String getPriorityLabel(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return '🔴 High';
    case 'medium':
      return '🟠 Medium';
    case 'low':
      return '🔵 Low';
    default:
      return '⚪ None';
  }
}

int getPriorityValue(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return 3;
    case 'medium':
      return 2;
    case 'low':
      return 1;
    default:
      return 0;
  }
}
