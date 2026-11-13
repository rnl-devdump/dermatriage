import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF006A6B);
  static const Color primaryTealLight = Color(0xFF26A69A);
  static const Color primaryTealDark = Color(0xFF004D40);

  static const Color medicalCyan = Color(0xFF0284C7);
  static const Color surfaceSlate = Color(0xFF0F172A);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderSubtle = Color(0xFFE2E8F0);

  // Triage Urgency Palette
  static const Color level1Red = Color(0xFFDC2626);
  static const Color level1RedBg = Color(0xFFFEF2F2);
  static const Color level1RedBorder = Color(0xFFFCA5A5);

  static const Color level2Amber = Color(0xFFD97706);
  static const Color level2AmberBg = Color(0xFFFFFBEB);
  static const Color level2AmberBorder = Color(0xFFFCD34D);

  static const Color level3Blue = Color(0xFF2563EB);
  static const Color level3BlueBg = Color(0xFFEFF6FF);
  static const Color level3BlueBorder = Color(0xFF93C5FD);

  static const Color level4Green = Color(0xFF059669);
  static const Color level4GreenBg = Color(0xFFECFDF5);
  static const Color level4GreenBorder = Color(0xFF6EE7B7);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: medicalCyan,
        surface: cardLight,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: surfaceSlate,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: surfaceSlate,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTeal,
          side: const BorderSide(color: primaryTeal, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        side: const BorderSide(color: borderSubtle),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static Color getUrgencyColor(String urgency) {
    if (urgency.contains('Level 1') || urgency.contains('High')) {
      return level1Red;
    } else if (urgency.contains('Level 2') || urgency.contains('Urgent')) {
      return level2Amber;
    } else if (urgency.contains('Level 3') || urgency.contains('Standard')) {
      return level3Blue;
    }
    return level4Green;
  }

  static Color getUrgencyBg(String urgency) {
    if (urgency.contains('Level 1') || urgency.contains('High')) {
      return level1RedBg;
    } else if (urgency.contains('Level 2') || urgency.contains('Urgent')) {
      return level2AmberBg;
    } else if (urgency.contains('Level 3') || urgency.contains('Standard')) {
      return level3BlueBg;
    }
    return level4GreenBg;
  }

  static Color getUrgencyBorder(String urgency) {
    if (urgency.contains('Level 1') || urgency.contains('High')) {
      return level1RedBorder;
    } else if (urgency.contains('Level 2') || urgency.contains('Urgent')) {
      return level2AmberBorder;
    } else if (urgency.contains('Level 3') || urgency.contains('Standard')) {
      return level3BlueBorder;
    }
    return level4GreenBorder;
  }
}
