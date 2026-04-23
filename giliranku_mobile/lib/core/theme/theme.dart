import 'package:flutter/material.dart';

class AppColors {
  // --- WARNA UTAMA (Brand Colors) ---
  static const Color primary = Color(0xFF25A699);     
  static const Color primaryLight = Color(0xFFE9F6F5); 
  static const Color primarySurface = Color(0xFFE9F6F5); // Tambahan agar error hilang
  static const Color secondary = Color(0xFF2F7BFF);   
  static const Color info = Color(0xFF2D9CDB);           // Tambahan agar error hilang
  static const Color gold = Color(0xFFF9A825);        

  // --- WARNA BACKGROUND & SURFACE ---
  static const Color white = Colors.white;           
  static const Color surface = Colors.white;
  static const Color background = Color(0xFFF8FBFB);  

  // --- WARNA TEXT ---
  static const Color textPrimary = Color(0xFF1D2121);   
  static const Color textSecondary = Color(0xFF626A6A); 
  static const Color textMuted = Color(0xFFA0A7A7);     

  // --- WARNA STATUS ---
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFD32F2F);

  // --- KOMPONEN ---
  static const Color divider = Color(0xFFE2E8E8);      
  static const Color cardShadow = Color(0x0F000000);   
  static const Color containerLight = Color(0xFFE9F6F5);

  static Null get primaryDark => null;
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.divider,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      // Perbaikan Error: Menggunakan CardThemeData
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      fontFamily: 'Inter', 
    );
  }
}