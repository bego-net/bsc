import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography definitions using Noto Sans Ethiopic for harmonious Amharic and Latin scripts.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Noto Sans Ethiopic';

  static TextStyle headingLarge({Color color = AppColors.textPrimary}) =>
      GoogleFonts.notoSansEthiopic(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.25,
      );

  static TextStyle heading({Color color = AppColors.textPrimary}) =>
      GoogleFonts.notoSansEthiopic(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.3,
      );

  static TextStyle title({Color color = AppColors.textPrimary}) =>
      GoogleFonts.notoSansEthiopic(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle titleMedium({Color color = AppColors.textPrimary}) =>
      title(color: color);

  static TextStyle cardTitle({Color color = AppColors.textPrimary}) =>
      GoogleFonts.notoSansEthiopic(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle subtitle({Color color = AppColors.textSecondary}) =>
      GoogleFonts.notoSansEthiopic(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle body({
    Color color = AppColors.textPrimary,
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 16,
    double height = 1.4,
  }) =>
      GoogleFonts.notoSansEthiopic(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );

  static TextStyle bodyMuted({
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 14,
  }) =>
      body(color: AppColors.textSecondary, fontWeight: fontWeight, fontSize: fontSize);

  static TextStyle button({Color color = Colors.white, FontWeight fontWeight = FontWeight.bold}) =>
      GoogleFonts.notoSansEthiopic(
        fontSize: 16,
        fontWeight: fontWeight,
        color: color,
      );

  static TextStyle label({
    Color color = AppColors.textPrimary,
    FontWeight fontWeight = FontWeight.w600,
    double fontSize = 14,
  }) =>
      GoogleFonts.notoSansEthiopic(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  static TextStyle caption({
    Color color = AppColors.textSecondary,
    FontWeight fontWeight = FontWeight.w500,
  }) =>
      GoogleFonts.notoSansEthiopic(
        fontSize: 13,
        fontWeight: fontWeight,
        color: color,
      );
}
