import 'package:clear_task/core/constants/colors.dart';
import 'package:flutter/material.dart';

InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
  errorMaxLines: 3,
  prefixIconColor: AppColors.secondaryFontColor,
  suffixIconColor: AppColors.secondaryFontColor,
  labelStyle: const TextStyle().copyWith(fontSize: 14, color: AppColors.secondaryFontColor),
  hintStyle: const TextStyle().copyWith(fontSize: 14, color: AppColors.secondaryFontColor),
  errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
  floatingLabelStyle: const TextStyle().copyWith(
    color: Colors.black.withOpacity(0.8),
  ),
  border: const OutlineInputBorder().copyWith(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(width: 1.4, color: AppColors.inputBorderColor),
  ),
  enabledBorder: const OutlineInputBorder().copyWith(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(width: 1.4, color: AppColors.inputBorderColor),
  ),
  focusedBorder: const OutlineInputBorder().copyWith(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(width: 1.7, color: AppColors.inputBorderFocusedColor),
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