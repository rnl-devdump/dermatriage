import 'package:flutter/material.dart';

class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration fluid = Duration(milliseconds: 350);
  static const Duration entrance = Duration(milliseconds: 500);

  static const Curve curve = Curves.easeOutCubic;
  static const Curve gentleCurve = Curves.fastOutSlowIn;
}

/// Poster world in Dermatriage teal: flat colour fields, condensed display
/// capitals, light grotesque text, zero radius, no shadows.
class AppTheme {
  // ---------------------------------------------------------------------------
  // Brand teal (unchanged values from the original palette)
  static const Color primaryTeal = Color(0xFF006A6B);
  static const Color primaryTealLight = Color(0xFF26A69A);
  static const Color primaryTealDark = Color(0xFF004D40);
  static const Color tealAccentDark = Color(0xFF2DD4BF);
  static const Color tealContainer = Color(0xFFCCFBF1);

  static const Color medicalCyan = Color(0xFF0284C7);
  static const Color medicalCyanLight = Color(0xFF38BDF8);

  // ---------------------------------------------------------------------------
  // Poster roles, translated into teal
  /// Main canvas: teal-tinted paper.
  static const Color paper = Color(0xFFEEF8F6);
  /// Stepped bands under the poster (Slate 50 from the original palette).
  static const Color band = Color(0xFFF8FAFC);
  /// Display type and dark fields on light ground.
  static const Color ink = Color(0xFF004D40);
  /// Pale display type on teal fields.
  static const Color pale = Color(0xFFCCFBF1);
  /// One step quieter than the primary teal field.
  static const Color quietPanel = Color(0xFF3B7473);
  /// Full-width accent band: Medical Cyan deepened so its pale text clears AA.
  static const Color cyanBand = Color(0xFF0369A1);
  /// The cool break: a pale cyan field.
  static const Color skyWash = Color(0xFFE0F2FE);
  /// Selection wash on paper.
  static const Color tealWash = Color(0xFFD7F0EB);
  /// Frame around the closing card.
  static const Color frame = Color(0xFF004D40);
  /// Mid ink usable as light-mode text and dark-mode chip ground.
  static const Color inkSlate = Color(0xFF2E4A47);

  // Dark poster roles
  static const Color paperDark = Color(0xFF061B19);
  static const Color bandDark = Color(0xFF0B2724);
  static const Color fieldDark = Color(0xFF134E4A);
  static const Color quietPanelDark = Color(0xFF1C3E3B);
  static const Color cyanBandDark = Color(0xFF075985);
  static const Color skyWashDark = Color(0xFF0C2A3A);
  static const Color tealWashDark = Color(0xFF0F3531);

  // ---------------------------------------------------------------------------
  // Light surfaces (names kept so every screen re-skins from one place)
  static const Color backgroundLight = paper;
  static const Color cardLight = band;
  static const Color surfaceElevatedLight = Color(0xFFE3F2EF);
  static const Color borderSubtleLight = Color(0xFFC2D9D5);
  static const Color textPrimaryLight = Color(0xFF0B3B36);
  static const Color textSecondaryLight = Color(0xFF34524E);
  static const Color textMutedLight = Color(0xFF557471);

  // Dark surfaces
  static const Color backgroundDark = paperDark;
  static const Color cardDark = bandDark;
  static const Color surfaceElevatedDark = Color(0xFF10322E);
  static const Color borderSubtleDark = Color(0xFF1E4A45);
  static const Color borderFocusedDark = Color(0xFF2A5C56);
  static const Color textPrimaryDark = Color(0xFFE6FAF6);
  static const Color textSecondaryDark = Color(0xFFA8C9C4);
  static const Color textMutedDark = Color(0xFF86AAA5);

  // ---------------------------------------------------------------------------
  // Triage urgency palette: clinical semantics, values unchanged
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

  // ---------------------------------------------------------------------------
  // Type families
  static const String display = 'Italiana';
  static const String sans = 'DM Sans';
  static const String mono = 'DM Mono';

  /// Condensed display line: always weight 400, zero tracking, tight leading.
  static TextStyle displayStyle(double size, Color color, {double height = 0.9}) =>
      TextStyle(
        fontFamily: display,
        fontSize: size,
        fontWeight: FontWeight.w400,
        height: height,
        letterSpacing: 0,
        color: color,
      );

  /// Small uppercase label in DM Sans Light.
  static TextStyle labelStyle(Color color, {double size = 12.8, double tracking = 0.48}) =>
      TextStyle(
        fontFamily: sans,
        fontSize: size,
        fontWeight: FontWeight.w300,
        height: 1.1,
        letterSpacing: tracking,
        color: color,
      );

  /// Numeric readout: tabular by construction.
  static TextStyle monoStyle(double size, Color color, {FontWeight weight = FontWeight.w400}) =>
      TextStyle(fontFamily: mono, fontSize: size, fontWeight: weight, color: color, height: 1.2);

  // Responsive breakpoints
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static TextTheme _textTheme(Color primary, Color secondary) {
    TextStyle s(double size, {FontWeight w = FontWeight.w300, double h = 1.3, Color? c}) =>
        TextStyle(fontFamily: sans, fontSize: size, fontWeight: w, height: h, color: c ?? primary);
    return TextTheme(
      displayLarge: displayStyle(96, primary),
      displayMedium: displayStyle(72, primary),
      displaySmall: displayStyle(56, primary),
      headlineLarge: displayStyle(48, primary, height: 1.0),
      headlineMedium: displayStyle(40, primary, height: 1.0),
      headlineSmall: displayStyle(32, primary, height: 1.0),
      titleLarge: s(20, w: FontWeight.w400, h: 1.2),
      titleMedium: s(16, w: FontWeight.w400, h: 1.25),
      titleSmall: s(14, w: FontWeight.w400, h: 1.25),
      bodyLarge: s(16),
      bodyMedium: s(14),
      bodySmall: s(12.8, c: secondary),
      labelLarge: s(13.5, w: FontWeight.w400, h: 1.1),
      labelMedium: s(12.8, h: 1.1),
      labelSmall: s(11.2, h: 1.1),
    );
  }

  static ThemeData _base({
    required Brightness brightness,
    required Color canvas,
    required Color surface,
    required Color hairline,
    required Color textPrimary,
    required Color textSecondary,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      surface: surface,
    ).copyWith(outline: hairline, outlineVariant: hairline, surfaceTint: Colors.transparent);

    final square = const RoundedRectangleBorder(borderRadius: BorderRadius.zero);
    final buttonText = TextStyle(fontFamily: sans, fontSize: 13.5, fontWeight: FontWeight.w400, letterSpacing: 0.2);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: sans,
      textTheme: _textTheme(textPrimary, textSecondary),
      scaffoldBackgroundColor: canvas,
      canvasColor: canvas,
      dividerColor: hairline,
      splashFactory: InkRipple.splashFactory,
      dividerTheme: DividerThemeData(color: hairline, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: hairline)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: square,
          textStyle: buttonText,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: square,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: textPrimary.withValues(alpha: 0.6), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: square,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary, shape: square, textStyle: buttonText),
      ),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(shape: square)),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary,
        side: BorderSide(color: hairline),
        shape: square,
        labelStyle: TextStyle(fontFamily: sans, fontSize: 12.8, fontWeight: FontWeight.w300, color: textPrimary),
        secondaryLabelStyle: TextStyle(fontFamily: sans, fontSize: 12.8, fontWeight: FontWeight.w400, color: onPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: hairline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: hairline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: primary, width: 1.5)),
        hintStyle: TextStyle(fontFamily: sans, fontWeight: FontWeight.w300, color: textSecondary),
      ),
      dialogTheme: DialogThemeData(backgroundColor: canvas, shape: square, elevation: 0),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: canvas, shape: square, elevation: 0),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: TextStyle(fontFamily: sans, fontWeight: FontWeight.w300, color: pale),
        shape: square,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: ink),
        textStyle: TextStyle(fontFamily: sans, fontSize: 12, fontWeight: FontWeight.w300, color: pale),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary, linearTrackColor: hairline),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: hairline,
        thumbColor: primary,
        trackHeight: 2,
        overlayShape: SliderComponentShape.noOverlay,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? onPrimary : textSecondary),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? primary : hairline),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: textPrimary,
        unselectedLabelColor: textSecondary,
        indicatorColor: primary,
        dividerColor: hairline,
        labelStyle: TextStyle(fontFamily: sans, fontSize: 13.5, fontWeight: FontWeight.w400),
        unselectedLabelStyle: TextStyle(fontFamily: sans, fontSize: 13.5, fontWeight: FontWeight.w300),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: canvas,
        elevation: 0,
        height: 66,
        indicatorColor: Colors.transparent,
        indicatorShape: square,
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
              fontFamily: sans,
              fontSize: 11.2,
              letterSpacing: 0.3,
              fontWeight: s.contains(WidgetState.selected) ? FontWeight.w500 : FontWeight.w300,
              color: s.contains(WidgetState.selected) ? textPrimary : textSecondary,
            )),
        iconTheme: WidgetStateProperty.resolveWith(
            (s) => IconThemeData(size: 22, color: s.contains(WidgetState.selected) ? primary : textSecondary)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: primary.withValues(alpha: 0.25),
        selectionHandleColor: primary,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(textSecondary.withValues(alpha: 0.35)),
        radius: Radius.zero,
        thickness: WidgetStateProperty.all(4),
      ),
    );
  }

  static ThemeData get lightTheme => _base(
        brightness: Brightness.light,
        canvas: paper,
        surface: band,
        hairline: borderSubtleLight,
        textPrimary: textPrimaryLight,
        textSecondary: textSecondaryLight,
        primary: primaryTeal,
        onPrimary: Colors.white,
        secondary: medicalCyan,
      );

  static ThemeData get darkTheme => _base(
        brightness: Brightness.dark,
        canvas: paperDark,
        surface: bandDark,
        hairline: borderSubtleDark,
        textPrimary: textPrimaryDark,
        textSecondary: textSecondaryDark,
        primary: tealAccentDark,
        onPrimary: paperDark,
        secondary: medicalCyanLight,
      );

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
