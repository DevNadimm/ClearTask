import 'package:clear_task/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: AppColors.buttonFontColor,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    textStyle: GoogleFonts.poppins(
      fontWeight: FontWeight.w700,
      fontSize: 16,
      height: 1,
    ),
  ),
);
