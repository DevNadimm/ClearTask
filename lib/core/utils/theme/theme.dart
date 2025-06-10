import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/utils/theme/app_bar_theme.dart';
import 'package:clear_task/core/utils/theme/elevated_button_theme.dart';
import 'package:clear_task/core/utils/theme/input_decoration_theme.dart';
import 'package:flutter/material.dart';

ThemeData theme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryColor,
  appBarTheme: appBarTheme,
  elevatedButtonTheme: elevatedButtonTheme,
  inputDecorationTheme: inputDecorationTheme,
  scaffoldBackgroundColor: AppColors.backgroundColor,
);
