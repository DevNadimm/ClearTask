import 'package:flutter/material.dart';

/// Light and Dark color sets for the app.
class AppColors {
  AppColors._();

  // ── Primary (shared) ──────────────────────────────────────────────────────
  static const Color primaryColor = Color(0xffc496fd);
  static const Color primaryColorTransparent = Color(0x80BD85FC);

  // Status Colors (shared)
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Constant references
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;

  // ── Dark Theme Colors ─────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF111111);
  static const Color darkCard = Color(0xFF232323);
  static const Color darkPrimaryFont = Color(0xFFF5F5F5);
  static const Color darkSecondaryFont = Color(0xFFB0B0B0);
  static const Color darkButtonFont = Color(0xFF190736);
  static const Color darkInputBorder = Color(0xff575161);
  static const Color darkInputBorderFocused = Color(0xffc496fd);
  static const Color darkCardOverlay = Color(0x55232323);

  // ── Light Theme Colors ────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F5F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightPrimaryFont = Color(0xFF1A1A2E);
  static const Color lightSecondaryFont = Color(0xFF6B6B7B);
  static const Color lightButtonFont = Color(0xFFFFFFFF);
  static const Color lightInputBorder = Color(0xFFD1C8E0);
  static const Color lightInputBorderFocused = Color(0xFF9B6FD4);
  static const Color lightCardOverlay = Color(0x22E0E0E0);
}

/// Extension to easily pull theme-aware colors from [BuildContext].
extension ThemeColors on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  Color get backgroundColor =>
      _isDark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get cardColor =>
      _isDark ? AppColors.darkCard : AppColors.lightCard;
  Color get primaryFontColor =>
      _isDark ? AppColors.darkPrimaryFont : AppColors.lightPrimaryFont;
  Color get secondaryFontColor =>
      _isDark ? AppColors.darkSecondaryFont : AppColors.lightSecondaryFont;
  Color get buttonFontColor =>
      _isDark ? AppColors.darkButtonFont : AppColors.lightButtonFont;
  Color get inputBorderColor =>
      _isDark ? AppColors.darkInputBorder : AppColors.lightInputBorder;
  Color get inputBorderFocusedColor =>
      _isDark ? AppColors.darkInputBorderFocused : AppColors.lightInputBorderFocused;
  Color get dividerColor =>
      _isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0);
  Color get cardOverlay =>
      _isDark ? AppColors.darkCardOverlay : AppColors.lightCardOverlay;
}
