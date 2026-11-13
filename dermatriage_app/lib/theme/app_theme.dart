import 'package:flutter/material.dart';

class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration fluid = Duration(milliseconds: 350);
  static const Duration entrance = Duration(milliseconds: 500);

  static const Curve curve = Curves.easeOutCubic;
  static const Curve gentleCurve = Curves.fastOutSlowIn;
}

class AppTheme {
  // Brand Clinical Palette
  static const Color primaryTeal = Color(0xFF006A6B);
  static const Color primaryTealLight = Color(0xFF26A69A);
  static const Color primaryTealDark = Color(0xFF004D40);
  static const Color tealAccentDark = Color(0xFF2DD4BF);

  static const Color medicalCyan = Color(0xFF0284C7);
  static const Color medicalCyanLight = Color(0xFF38BDF8);

  // Light Theme Surfaces
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF1F5F9);
  static const Color borderSubtleLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Dark Theme Surfaces
  static const Color backgroundDark = Color(0xFF0B0F17);
  static const Color cardDark = Color(0xFF131B2A);
  static const Color surfaceElevatedDark = Color(0xFF1E293B);
  static const Color borderSubtleDark = Color(0xFF1E293B);
  static const Color borderFocusedDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Triage Urgency Palette - Standardized Medical Stratification
  static const Color level1Red = Color(0xFFDC2626);
  static const Color level1RedBg = Color(0xFFFEF2F2);
  static const Color level1RedBorder = Color(0xFFFCA5A5);
  static const Color level1RedBgDark = Color(0xFF450A0A);
  static const Color level1RedBorderDark = Color(0xFF991B1B);

  static const Color level2Amber = Color(0xFFD97706);
  static const Color level2AmberBg = Color(0xFFFFFBEB);
  static const Color level2AmberBorder = Color(0xFFFCD34D);
  static const Color level2AmberBgDark = Color(0xFF451A03);
  static const Color level2AmberBorderDark = Color(0xFFB45309);

  static const Color level3Blue = Color(0xFF2563EB);
  static const Color level3BlueBg = Color(0xFFEFF6FF);
  static const Color level3BlueBorder = Color(0xFF93C5FD);
  static const Color level3BlueBgDark = Color(0xFF172554);
  static const Color level3BlueBorderDark = Color(0xFF1D4ED8);

  static const Color level4Green = Color(0xFF059669);
  static const Color level4GreenBg = Color(0xFFECFDF5);
  static const Color level4GreenBorder = Color(0xFF6EE7B7);
  static const Color level4GreenBgDark = Color(0xFF022C22);
  static const Color level4GreenBorderDark = Color(0xFF047857);

  // Responsive Breakpoints
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        brightness: Brightness.light,
        primary: primaryTeal,
        secondary: medicalCyan,
        surface: cardLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderSubtleLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTeal,
          side: const BorderSide(color: primaryTeal, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        side: const BorderSide(color: borderSubtleLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        brightness: Brightness.dark,
        primary: tealAccentDark,
        secondary: medicalCyanLight,
        surface: cardDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: cardDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderSubtleDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tealAccentDark,
          side: const BorderSide(color: tealAccentDark, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevatedDark,
        side: const BorderSide(color: borderFocusedDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  static Color getUrgencyBg(String urgency, [bool isDark = false]) {
    if (urgency.contains('Level 1') || urgency.contains('High')) {
      return isDark ? level1RedBgDark : level1RedBg;
    } else if (urgency.contains('Level 2') || urgency.contains('Urgent')) {
      return isDark ? level2AmberBgDark : level2AmberBg;
    } else if (urgency.contains('Level 3') || urgency.contains('Standard')) {
      return isDark ? level3BlueBgDark : level3BlueBg;
    }
    return isDark ? level4GreenBgDark : level4GreenBg;
  }

  static Color getUrgencyBorder(String urgency, [bool isDark = false]) {
    if (urgency.contains('Level 1') || urgency.contains('High')) {
      return isDark ? level1RedBorderDark : level1RedBorder;
    } else if (urgency.contains('Level 2') || urgency.contains('Urgent')) {
      return isDark ? level2AmberBorderDark : level2AmberBorder;
    } else if (urgency.contains('Level 3') || urgency.contains('Standard')) {
      return isDark ? level3BlueBorderDark : level3BlueBorder;
    }
    return isDark ? level4GreenBorderDark : level4GreenBorder;
  }
}
