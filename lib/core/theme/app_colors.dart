import 'package:flutter/material.dart';

/// Curated color palette for Al-Fajr application.
class AppColors {
  // Emerald Islamic Primary
  static const Color primary = Color(0xFF0D5C3A);
  static const Color primaryLight = Color(0xFF168052);
  static const Color primaryDark = Color(0xFF073823);
  static const Color primaryAccent = Color(0xFF10B981);

  // Gold / Amber Accent
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3E5AB);
  static const Color goldDark = Color(0xFF997A15);
  static const Color amber = Color(0xFFF59E0B);

  // Status Colors
  static const Color statusPrayed = Color(0xFF10B981); // Green
  static const Color statusAwake = Color(0xFFF59E0B); // Amber / Yellow
  static const Color statusCalling = Color(0xFF3B82F6); // Blue
  static const Color statusNoAnswer = Color(0xFFEF4444); // Red
  static const Color statusPending = Color(0xFF6B7280); // Slate Gray
  static const Color statusSnoozed = Color(0xFF8B5CF6); // Purple
  static const Color statusOptedOut = Color(0xFF9CA3AF); // Muted Gray

  // Dark Theme Backgrounds
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkSurfaceElevated = Color(0xFF334155); // Slate 700
  static const Color darkBorder = Color(0xFF334155);

  // Light Theme Backgrounds
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textLightPrimary = Color(0xFF0F172A);
  static const Color textLightSecondary = Color(0xFF64748B);
  static const Color textDarkPrimary = Color(0xFFF8FAFC);
  static const Color textDarkSecondary = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient fajrGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF0A3A24),
      Color(0xFF14532D),
      Color(0xFF064E3B),
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEAB308),
      Color(0xFFD97706),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B),
      Color(0xFF0F172A),
    ],
  );
}
