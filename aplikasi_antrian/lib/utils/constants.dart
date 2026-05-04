import 'package:flutter/material.dart';

// Colors
class AppColors {
  static const Color primary = Color(0xFF5FA092); // Teal green
  static const Color secondary = Color(0xFF8CC63F); // Lime green
  static const Color accent = Color(0xFF0066CC); // Blue
  static const Color background = Color(0xFFF3F4F6); // Light gray
  static const Color footer = Color(0xFF4D4D4D); // Dark gray
  static const Color textPrimary = Color(0xFF1F2937); // Dark gray text
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray text
  static const Color white = Colors.white;
}

// Font sizes
class AppFontSizes {    
  static const double headerTitle = 22.0;
  static const double headerSubtitle = 18.0;
  static const double serviceTitle = 18.0;
  static const double serviceDescription = 12.0;
  static const double footerText = 12.0;
  static const double clockText = 14.0;
}

// Padding & Spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

// Border radius
class AppRadius {
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 50.0;
}

// Hospital info
class HospitalInfo {
  static const String name = 'RSUD Porsea';
  static const String fullName = 'Selamat Datang di RSUD Porsea';
  static const String subtitle = 'Silahkan Pilih Layanan';
  static const String copyright = '© 2026 Institut Teknologi Del. All Rights Reserved.';
}
