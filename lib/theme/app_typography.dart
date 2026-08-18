import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Clean, modern typography scale for RunMate based on Inter
class AppTypography {
  AppTypography._();

  static TextStyle displayLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 38,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.8,
        color: color ?? AppColors.primaryText,
      );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.5,
        color: color ?? AppColors.primaryText,
      );

  static TextStyle headingLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.4,
        color: color ?? AppColors.primaryText,
      );

  static TextStyle headingMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.3,
        color: color ?? AppColors.primaryText,
      );

  static TextStyle headingSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
        color: color ?? AppColors.primaryText,
      );

  static TextStyle bodyLarge({Color? color, FontWeight? fontWeight}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: fontWeight ?? FontWeight.w500,
        height: 1.4,
        color: color ?? AppColors.primaryText,
      );

  static TextStyle bodyMedium({Color? color, FontWeight? fontWeight}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: fontWeight ?? FontWeight.w400,
        height: 1.4,
        color: color ?? AppColors.primaryText,
      );

  static TextStyle caption({Color? color, FontWeight? fontWeight}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: fontWeight ?? FontWeight.w500,
        height: 1.3,
        color: color ?? AppColors.mutedText,
      );

  static TextStyle metricLabel({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.6,
        color: color ?? AppColors.mutedText,
      );

  static TextStyle buttonText({Color? color}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: color ?? Colors.white,
      );
}
