import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Segoe UI',
    );
  }

  // Header text style
  static const TextStyle headerTitle = TextStyle(
    fontSize: AppFontSizes.headerTitle,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle headerSubtitle = TextStyle(
    fontSize: AppFontSizes.headerSubtitle,
    color: Colors.white70,
  );

  // Service button styles
  static const TextStyle serviceTitle = TextStyle(
    fontSize: AppFontSizes.serviceTitle,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle serviceDescription = TextStyle(
    fontSize: AppFontSizes.serviceDescription,
    color: AppColors.textSecondary,
  );

  // Footer text style
  static const TextStyle footerText = TextStyle(
    fontSize: AppFontSizes.footerText,
    color: Colors.white70,
  );

  // Clock text style
  static const TextStyle clockText = TextStyle(
    fontSize: AppFontSizes.clockText,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
  );
}
