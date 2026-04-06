import 'package:clear_task/core/constants/colors.dart';
import 'package:flutter/material.dart';

InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
  errorMaxLines: 3,
  prefixIconColor: AppColors.darkSecondaryFont,
  suffixIconColor: AppColors.darkSecondaryFont,
  fillColor: AppColors.darkCard,
  filled: true,
  labelStyle: const TextStyle().copyWith(fontSize: 14, color: AppColors.darkSecondaryFont),
  hintStyle: const TextStyle().copyWith(fontSize: 14, color: AppColors.darkSecondaryFont),
  errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
  floatingLabelStyle: const TextStyle().copyWith(
    color: Colors.white.withValues(alpha: 0.8),
  ),
  border: const OutlineInputBorder().copyWith(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(width: 1.4, color: AppColors.darkInputBorder),
  ),
  enabledBorder: const OutlineInputBorder().copyWith(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(width: 1.4, color: AppColors.darkInputBorder),
  ),
  focusedBorder: const OutlineInputBorder().copyWith(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(width: 1.7, color: AppColors.darkInputBorderFocused),
  ),
  errorBorder: const OutlineInputBorder().copyWith(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(width: 1.4, color: Colors.red),
  ),
  focusedErrorBorder: const OutlineInputBorder().copyWith(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(width: 1.7, color: Colors.orange),
  ),
);

InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
  errorMaxLines: 3,
  prefixIconColor: AppColors.lightSecondaryFont,
  suffixIconColor: AppColors.lightSecondaryFont,
  fillColor: AppColors.lightCard,
  filled: true,
  labelStyle: const TextStyle().copyWith(fontSize: 14, color: AppColors.lightSecondaryFont),
  hintStyle: const TextStyle().copyWith(fontSize: 14, color: AppColors.lightSecondaryFont),
  errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
  floatingLabelStyle: const TextStyle().copyWith(
    color: Colors.black.withValues(alpha: 0.8),
  ),
  border: const OutlineInputBorder().copyWith(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(width: 1.4, color: AppColors.lightInputBorder),
  ),
  enabledBorder: const OutlineInputBorder().copyWith(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(width: 1.4, color: AppColors.lightInputBorder),
  ),
  focusedBorder: const OutlineInputBorder().copyWith(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(width: 1.7, color: AppColors.lightInputBorderFocused),
  ),
  errorBorder: const OutlineInputBorder().copyWith(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(width: 1.4, color: Colors.red),
  ),
  focusedErrorBorder: const OutlineInputBorder().copyWith(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(width: 1.7, color: Colors.orange),
  ),
);