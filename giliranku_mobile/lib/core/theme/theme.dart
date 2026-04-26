import 'package:flutter/material.dart';

// ─── DESIGN TOKENS ────────────────────────────────────────────────────────────
// Filosofi: satu dominant (teal), satu aksen (amber), sisanya monokrom.
// Tidak ada rainbow — warna hanya untuk makna, bukan dekorasi.
class AppColors {
  // Primary — deep teal
  static const Color primary      = Color(0xFF0F7B6C);
  static const Color primaryLight = Color(0xFF1A9B8A);
  static const Color primaryDark  = Color(0xFF095C50);
  static const Color primarySurf  = Color(0xFFEAF4F2); // bg lembut primary
  static const Color primarySurface = primarySurf;

  // Aksen — warm amber (hanya untuk notif/reminder, bukan menu)
  static const Color amber     = Color(0xFFE8960A);
  static const Color amberSurf = Color(0xFFFDF3DC);

  // Monokrom — semua abu dari satu ramp
  static const Color ink0  = Color(0xFF111827); // teks utama
  static const Color ink1  = Color(0xFF374151); // teks sekunder
  static const Color ink2  = Color(0xFF6B7280); // teks muted
  static const Color ink3  = Color(0xFF9CA3AF); // placeholder
  static const Color ink4  = Color(0xFFE5E7EB); // divider
  static const Color ink5  = Color(0xFFF3F4F6); // surface alt
  static const Color white = Color(0xFFFFFFFF);

  // Alias legacy — agar tidak error di file lain
  static const Color gold          = amber;
  static const Color secondary     = Color(0xFF2563EB);
  static const Color info          = Color(0xFF0284C7);
  static const Color success       = Color(0xFF16A34A);
  static const Color warning       = Color(0xFFF59E0B);
  static const Color error         = Color(0xFFDC2626);

  static const Color surface       = white;
  static const Color background    = Color(0xFFF7F9F8); // sedikit warm
  static const Color divider       = ink4;
  static const Color cardShadow    = Color(0x0A000000);
  static const Color containerLight = primarySurf;

  static const Color textPrimary   = ink0;
  static const Color textSecondary = ink1;
  static const Color textMuted     = ink2;
}

// ─── TYPOGRAPHY SCALE ─────────────────────────────────────────────────────────
class AppText {
  static const String font = 'PlusJakartaSans';

  static const TextStyle h1 = TextStyle(
    fontFamily: font, fontSize: 26, fontWeight: FontWeight.w800,
    color: AppColors.ink0, letterSpacing: -0.8, height: 1.15,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: font, fontSize: 20, fontWeight: FontWeight.w800,
    color: AppColors.ink0, letterSpacing: -0.5, height: 1.2,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: font, fontSize: 15, fontWeight: FontWeight.w700,
    color: AppColors.ink0, letterSpacing: -0.2,
  );
  static const TextStyle body = TextStyle(
    fontFamily: font, fontSize: 13, fontWeight: FontWeight.w400,
    color: AppColors.ink1, height: 1.5,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: font, fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.ink2,
  );
  static const TextStyle label = TextStyle(
    fontFamily: font, fontSize: 12, fontWeight: FontWeight.w600,
    color: AppColors.ink0, letterSpacing: 0.1,
  );
}

// ─── THEME ────────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.divider,
      fontFamily: AppText.font,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        brightness: Brightness.light,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider, width: 0.8),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: AppText.h2,
      ),
    );
  }
}