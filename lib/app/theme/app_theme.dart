import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design tokens. 8px spacing system, consistent radii & status colours.
class AppColors {
  AppColors._();
  static const Color primary = Color(0xFF155EEF);
  static const Color primaryDark = Color(0xFF0E4AC4);
  static const Color navy = Color(0xFF122A4C);

  static const Color canvas = Color(0xFFF5F7FB);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE7EBF3);

  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF667085);

  static const Color success = Color(0xFF12B76A);
  static const Color successBg = Color(0xFFECFDF3);
  static const Color warning = Color(0xFFF79009);
  static const Color warningBg = Color(0xFFFFFAEB);
  static const Color danger = Color(0xFFD92D20);
  static const Color dangerBg = Color(0xFFFEF3F2);
  static const Color infoBg = Color(0xFFEFF4FF);
  static const Color gray = Color(0xFF98A2B3);
  static const Color grayBg = Color(0xFFF2F4F7);

  // Dark theme counterparts
  static const Color dCanvas = Color(0xFF0D1420);
  static const Color dSurface = Color(0xFF151D2C);
  static const Color dBorder = Color(0xFF26334A);
}

class AppRadius {
  AppRadius._();
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 22;
}

class AppShadows {
  AppShadows._();
  static List<BoxShadow> card = [
    BoxShadow(color: const Color(0xFF101828).withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
  ];
  static List<BoxShadow> raised = [
    BoxShadow(color: const Color(0xFF101828).withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 8)),
  ];
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      surface: isLight ? AppColors.surface : AppColors.dSurface,
    );
    final body = GoogleFonts.ibmPlexSansTextTheme();
    final display = GoogleFonts.soraTextTheme();

    final textTheme = body.copyWith(
      displayLarge: display.displayLarge?.copyWith(fontSize: 30, fontWeight: FontWeight.w700),
      displayMedium: display.displayMedium?.copyWith(fontSize: 24, fontWeight: FontWeight.w700),
      headlineMedium: display.headlineMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: display.headlineSmall?.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
      titleLarge: body.titleLarge?.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
      titleMedium: body.titleMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      titleSmall: body.titleSmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
      bodyLarge: body.bodyLarge?.copyWith(fontSize: 16),
      bodyMedium: body.bodyMedium?.copyWith(fontSize: 14),
      bodySmall: body.bodySmall?.copyWith(fontSize: 13),
      labelLarge: body.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: body.labelMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: body.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.4),
    );

    final borderSide = BorderSide(color: isLight ? AppColors.border : AppColors.dBorder);
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: borderSide,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isLight ? AppColors.canvas : AppColors.dCanvas,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: isLight ? AppColors.textPrimary : Colors.white,
        titleTextStyle: GoogleFonts.sora(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isLight ? AppColors.textPrimary : Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: borderSide),
        color: scheme.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isLight ? AppColors.textPrimary : Colors.white,
          minimumSize: const Size(double.infinity, 52),
          side: borderSide,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: outline,
        enabledBorder: outline,
        focusedBorder: outline.copyWith(borderSide: const BorderSide(color: AppColors.primary, width: 1.6)),
        errorBorder: outline.copyWith(borderSide: const BorderSide(color: AppColors.danger)),
        focusedErrorBorder: outline.copyWith(borderSide: const BorderSide(color: AppColors.danger, width: 1.6)),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.gray),
        prefixIconColor: AppColors.gray,
        suffixIconColor: AppColors.gray,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(color: isLight ? AppColors.border : AppColors.dBorder, thickness: 1, space: 1),
      expansionTileTheme: ExpansionTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: borderSide),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: borderSide),
      ),
    );
  }
}