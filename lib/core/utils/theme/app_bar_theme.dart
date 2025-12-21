import 'package:clear_task/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AppBarTheme appBarTheme = AppBarTheme(
  backgroundColor: AppColors.backgroundColor,
  foregroundColor: AppColors.primaryFontColor,
  scrolledUnderElevation: 0,
  centerTitle: false,
  titleTextStyle: GoogleFonts.poppins(
    fontSize: 20,
    color: AppColors.primaryFontColor,
    fontWeight: FontWeight.w600,
  ),
);
