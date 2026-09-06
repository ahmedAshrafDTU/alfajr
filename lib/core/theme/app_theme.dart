import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppTheme configuration for Light & Dark modes with RTL and Material 3 design.
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.gold,
        onSecondary: Colors.black,
        surface: AppColors.lightSurface,
        onSurface: AppColors.textLightPrimary,
        error: AppColors.statusNoAnswer,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textLightPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textLightPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      fontFamily: 'Cairo',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: Colors.white,
        secondary: AppColors.goldLight,
        onSecondary: Colors.black,
        surface: AppColors.darkSurface,
        onSurface: AppColors.textDarkPrimary,
        error: AppColors.statusNoAnswer,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textDarkPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textDarkPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.goldLight,
          side: const BorderSide(color: AppColors.goldLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      fontFamily: 'Cairo',
    );
  }
}
