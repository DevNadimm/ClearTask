import 'package:clear_task/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AppBarTheme darkAppBarTheme = AppBarTheme(
  backgroundColor: AppColors.darkBackground,
  foregroundColor: AppColors.darkPrimaryFont,
  scrolledUnderElevation: 0,
  centerTitle: false,
  titleTextStyle: GoogleFonts.poppins(
    fontSize: 20,
    color: AppColors.darkPrimaryFont,
    fontWeight: FontWeight.w600,
  ),
);

AppBarTheme lightAppBarTheme = AppBarTheme(
  backgroundColor: AppColors.lightBackground,
  foregroundColor: AppColors.lightPrimaryFont,
  scrolledUnderElevation: 0,
  centerTitle: false,
  titleTextStyle: GoogleFonts.poppins(
    fontSize: 20,
    color: AppColors.lightPrimaryFont,
    fontWeight: FontWeight.w600,
  ),
);
