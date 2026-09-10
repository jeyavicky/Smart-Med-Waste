import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Clinical healthcare Material 3 Theme definition
class AppTheme {
  // Dark Theme (Default high-tech clinical HUD mode)
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: AppConstants.tealAccent,
      onPrimary: Colors.black,
      primaryContainer: AppConstants.tealPrimary,
      onPrimaryContainer: Colors.white,
      secondary: AppConstants.amberWarning,
      onSecondary: Colors.black,
      error: AppConstants.crimsonDanger,
      onError: Colors.white,
      surface: AppConstants.surfaceSlate,
      onSurface: Color(0xFFF1F5F9),
      surfaceContainerHighest: Color(0xFF243247),
      outline: AppConstants.borderSlate,
      outlineVariant: Color(0xFF475569),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppConstants.darkSlate,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.darkSlate,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 2,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppConstants.surfaceSlate,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppConstants.borderSlate, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.tealPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.tealAccent,
          side: const BorderSide(color: AppConstants.tealPrimary, width: 1.5),
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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF131D31),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.borderSlate),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.borderSlate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.tealAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.crimsonDanger),
        ),
        hintStyle: const TextStyle(color: AppConstants.neutralGrey, fontSize: 14),
        labelStyle: const TextStyle(color: AppConstants.lightSlate, fontSize: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0C1322),
        elevation: 8,
        indicatorColor: AppConstants.tealPrimary.withOpacity(0.25),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppConstants.tealAccent,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppConstants.neutralGrey,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: AppConstants.tealAccent, size: 24);
          }
          return const IconThemeData(color: AppConstants.neutralGrey, size: 24);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppConstants.borderSlate,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Light Theme (Clean Medical Clinical Light Mode)
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: AppConstants.medicalTeal,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFCCFBF1),
      onPrimaryContainer: Color(0xFF115E59),
      secondary: AppConstants.clinicalNavy,
      onSecondary: Colors.white,
      surface: AppConstants.cardBg,
      onSurface: AppConstants.textPrimary,
      surfaceContainerHighest: AppConstants.surfaceInteractive,
      outline: Color(0xFFCBD5E1),
      outlineVariant: AppConstants.cardBorder,
      error: AppConstants.crimsonDanger,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppConstants.canvasBg,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.clinicalNavy,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: AppConstants.clinicalNavy,
        ),
        iconTheme: IconThemeData(
          color: AppConstants.clinicalNavy,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: const Color(0xFF0F172A).withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppConstants.cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.medicalTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.medicalTeal,
          side: const BorderSide(color: AppConstants.medicalTeal, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.surfaceInteractive,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.medicalTeal, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppConstants.textSecondary, fontSize: 14),
        labelStyle: const TextStyle(color: AppConstants.textSecondary, fontSize: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: const Color(0xFF0F172A).withOpacity(0.08),
        indicatorColor: AppConstants.medicalTeal.withOpacity(0.15),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppConstants.medicalTeal,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppConstants.textSecondary,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: AppConstants.medicalTeal, size: 24);
          }
          return const IconThemeData(color: AppConstants.textSecondary, size: 24);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppConstants.cardBorder,
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppConstants.textPrimary),
        bodyMedium: TextStyle(color: AppConstants.textPrimary),
        bodySmall: TextStyle(color: AppConstants.textSecondary),
        titleLarge: TextStyle(color: AppConstants.clinicalNavy, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: AppConstants.clinicalNavy, fontWeight: FontWeight.w700),
        titleSmall: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w600),
      ),
    );
  }
}
