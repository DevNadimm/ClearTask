import 'package:flutter/material.dart';

Color getTaskTypeColor(String taskType) {
  final type = taskType.toLowerCase();

  if (type == 'office') {
    return const Color(0xFF90CAF9);
  } else if (type == 'home') {
    return const Color(0xFFA5D6A7);
  } else if (type == 'study') {
    return const Color(0xFFB39DDB);
  } else if (type == 'personal') {
    return const Color(0xFF80CBC4);
  } else if (type == 'shopping') {
    return const Color(0xFFFFCC80);
  } else if (type == 'fitness') {
    return const Color(0xFFEF9A9A);
  } else if (type == 'health') {
    return const Color(0xFFF48FB1);
  } else if (type == 'finance') {
    return const Color(0xFF9FA8DA);
  } else if (type == 'travel') {
    return const Color(0xFF80DEEA);
  } else if (type == 'event') {
    return const Color(0xFFFFF59D);
  } else {
    return const Color(0xFFE0E0E0);
  }
}