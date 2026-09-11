import 'package:flutter/material.dart';

/// Premium Islamic Color Palette for Al-Fajr application.
class AppColors {
  // Primary (Deep Islamic Green)
  static const Color primary = Color(0xFF0C4A34); // Deep Emerald
  static const Color primaryLight = Color(0xFF137351);
  static const Color primaryDark = Color(0xFF072D20);
  static const Color primaryAccent = Color(0xFF0F9B6E);

  // Secondary (Warm Gold & Soft Sand)
  static const Color secondary = Color(0xFFD4AF37); // Warm Gold
  static const Color secondaryLight = Color(0xFFE5C86B);
  static const Color secondaryDark = Color(0xFF997A15);
  static const Color sand = Color(0xFFEBE6D6); // Soft Sand

  // Background & Surface
  static const Color lightBackground = Color(0xFFFBFBF9); // Cream / Off White
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E5E0);

  static const Color darkBackground = Color(0xFF0F1A15); // Deep Charcoal Green
  static const Color darkSurface = Color(0xFF16261E); // Elevated Dark
  static const Color darkBorder = Color(0xFF233D31);

  // Semantic & Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  static const Color statusPrayed = success;
  static const Color statusAwake = warning;
  static const Color statusCalling = info;
  static const Color statusNoAnswer = error;

  // Legacy / Backward Compatibility Colors
  static const Color amber = warning;
  static const Color gold = secondary;
  static const Color goldLight = secondaryLight;
  static const Color statusSnoozed = Color(0xFF8B5CF6);
  static const Color statusPending = Color(0xFF6B7280);
  static const Color statusOptedOut = Color(0xFF9CA3AF);

  // Typography
  static const Color textLightPrimary = Color(0xFF1A1A1A);
  static const Color textLightSecondary = Color(0xFF6B7280);
  
  static const Color textDarkPrimary = Color(0xFFF3F4F6);
  static const Color textDarkSecondary = Color(0xFF9CA3AF);

  // Gradients
  static const LinearGradient premiumGreenGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF093626),
      Color(0xFF0C4A34),
      Color(0xFF137351),
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE5C86B),
      Color(0xFFD4AF37),
    ],
  );
}
