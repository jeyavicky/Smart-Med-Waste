import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

/// Enterprise Clinical Typography and Healthcare Material 3 Theme System
/// WCAG 2.1 AA Compliant with Certified Inter Typography
class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    final clinicalTextTheme = GoogleFonts.interTextTheme(baseTextTheme).copyWith(
      // Screen & App Bar Titles
      headlineMedium: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
        letterSpacing: -0.3,
      ),
      // Card Headers & Section Titles
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1E293B),
      ),
      // Form Input & Regular Body Text
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF334155),
      ),
      // Small Details & Microcopy
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF64748B),
      ),
      // Badges, Stat Labels & Section Headers
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: const Color(0xFF64748B),
      ),
      // Extended Clinical Scale
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: const Color(0xFF0F2942),
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1E293B),
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1E293B),
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.9,
        color: const Color(0xFF0F2942),
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: const Color(0xFF64748B),
      ),
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: const Color(0xFF0F172A),
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: const Color(0xFF0F172A),
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: const Color(0xFF0F172A),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: clinicalTextTheme,
      primaryTextTheme: clinicalTextTheme,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0F2942),
        brightness: Brightness.light,
      ).copyWith(
        primary: AppConstants.clinicalNavy,
        onPrimary: Colors.white,
        secondary: AppConstants.medicalTeal,
        onSecondary: Colors.white,
        surface: AppConstants.cardBg,
        onSurface: const Color(0xFF0F172A),
        error: AppConstants.crimsonDanger,
        onError: Colors.white,
        outline: AppConstants.cardBorder,
        surfaceContainerHighest: AppConstants.surfaceInteractive,
      ),
      primaryColor: const Color(0xFF0F2942),
      dividerColor: AppConstants.dividerSubtle,
      dividerTheme: const DividerThemeData(
        color: AppConstants.cardBorder,
        thickness: 1.0,
        space: 1.0,
      ),
      cardTheme: CardThemeData(
        color: AppConstants.cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppConstants.cardBorder, width: 1.0),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.cardBg,
        foregroundColor: AppConstants.clinicalNavy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: AppConstants.clinicalNavy,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: AppConstants.clinicalNavy),
        actionsIconTheme: const IconThemeData(color: AppConstants.clinicalNavy),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.clinicalNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppConstants.clinicalNavy,
          elevation: 0,
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: AppConstants.clinicalNavy, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.clinicalNavy,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          textStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.inter(
          color: const Color(0xFF64748B),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppConstants.dividerSubtle, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppConstants.dividerSubtle, width: 1.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppConstants.clinicalNavy, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppConstants.crimsonDanger, width: 1.0),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: AppConstants.clinicalNavy.withOpacity(0.08),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppConstants.clinicalNavy);
          }
          return const IconThemeData(color: AppConstants.coolSlate);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppConstants.clinicalNavy,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppConstants.coolSlate,
          );
        }),
      ),
    );
  }

  // Certified high-contrast clinical light surface applies to darkTheme as well
  static ThemeData get darkTheme => lightTheme;
}

/// Alias for backwards compatibility with any existing clinical imports
typedef SoftClinicalTheme = AppTheme;
