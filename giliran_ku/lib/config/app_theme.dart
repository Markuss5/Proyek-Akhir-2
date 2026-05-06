import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2FAE86),
      primary: const Color(0xFF2FAE86),
      secondary: const Color(0xFF6ED6B0),
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF1FBF7),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      bodyMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      bodySmall: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Color(0xFF0A3D2E),
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD7EFE6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD7EFE6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF2FAE86),
          width: 1.5,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2FAE86),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
