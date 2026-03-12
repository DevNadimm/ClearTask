import 'package:flutter/material.dart';

Color getTaskTypeColor(String taskType) {
  switch (taskType.toLowerCase()) {
    case 'development':
      return const Color(0xFF90CAF9);

    case 'work':
      return const Color(0xFFA5D6A7);

    case 'learning':
      return const Color(0xFFB39DDB);

    case 'projects':
      return const Color(0xFF80CBC4);

    case 'research':
      return const Color(0xFFFFCC80);

    case 'career':
      return const Color(0xFFEF9A9A);

    case 'personal':
      return const Color(0xFFF48FB1);

    case 'health':
      return const Color(0xFF9FA8DA);

    case 'fitness':
      return const Color(0xFF80DEEA);

    case 'finance':
      return const Color(0xFFFFF59D);

    case 'home':
      return const Color(0xFFCE93D8);

    case 'shopping':
      return const Color(0xFFAED581);

    case 'travel':
      return const Color(0xFFFFAB91);

    case 'events':
      return const Color(0xFF81D4FA);

    case 'others':
      return const Color(0xFFBDBDBD);

    default:
      return const Color(0xFFE0E0E0);
  }
}