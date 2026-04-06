import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/utils/theme/app_bar_theme.dart';
import 'package:clear_task/core/utils/theme/elevated_button_theme.dart';
import 'package:clear_task/core/utils/theme/input_decoration_theme.dart';
import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryColor,
  appBarTheme: darkAppBarTheme,
  elevatedButtonTheme: darkElevatedButtonTheme,
  inputDecorationTheme: darkInputDecorationTheme,
  scaffoldBackgroundColor: AppColors.darkBackground,
  cardColor: AppColors.darkCard,
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: AppColors.darkButtonFont,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primaryColor;
      return AppColors.darkSecondaryFont;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primaryColor.withValues(alpha: 0.4);
      return AppColors.darkInputBorder;
    }),
  ),
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryColor,
    secondary: AppColors.primaryColor,
    surface: AppColors.darkCard,
  ),
);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryColor,
  appBarTheme: lightAppBarTheme,
  elevatedButtonTheme: lightElevatedButtonTheme,
  inputDecorationTheme: lightInputDecorationTheme,
  scaffoldBackgroundColor: AppColors.lightBackground,
  cardColor: AppColors.lightCard,
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: AppColors.lightButtonFont,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primaryColor;
      return AppColors.lightSecondaryFont;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primaryColor.withValues(alpha: 0.4);
      return AppColors.lightInputBorder;
    }),
  ),
  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryColor,
    secondary: AppColors.primaryColor,
    surface: AppColors.lightCard,
  ),
);
