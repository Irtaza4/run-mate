import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// ThemeData configurations for RunMate
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryTeal,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryTeal,
        secondary: AppColors.mint,
        surface: AppColors.cardBackground,
        error: AppColors.danger,
        onPrimary: AppColors.primaryText,
        onSecondary: AppColors.primaryText,
        onSurface: AppColors.primaryText,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.primaryText,
        displayColor: AppColors.primaryText,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      splashColor: AppColors.mint.withValues(alpha: 0.2),
      highlightColor: Colors.transparent,
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.darkMint,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkMint,
        secondary: AppColors.primaryTeal,
        surface: AppColors.darkCard,
        error: AppColors.danger,
        onPrimary: AppColors.darkPrimaryText,
        onSecondary: AppColors.darkPrimaryText,
        onSurface: AppColors.darkPrimaryText,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.darkPrimaryText,
        displayColor: AppColors.darkPrimaryText,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),
      splashColor: AppColors.darkMint.withValues(alpha: 0.2),
      highlightColor: Colors.transparent,
    );
  }
}
