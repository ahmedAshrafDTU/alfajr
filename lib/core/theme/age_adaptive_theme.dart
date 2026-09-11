import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class AgeAdaptiveTheme {
  static ThemeData getThemeFor(AgeGroup ageGroup) {
    switch (ageGroup) {
      case AgeGroup.kids:
        return _buildKidsTheme();
      case AgeGroup.teen:
        return _buildTeenTheme();
      case AgeGroup.adult:
        return _buildAdultTheme();
      case AgeGroup.elderly:
        return _buildElderlyTheme();
    }
  }

  static ThemeData _buildKidsTheme() {
    return ThemeData(
      primarySwatch: Colors.lightBlue,
      scaffoldBackgroundColor: Colors.blue[50],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.blueGrey),
        bodyMedium: TextStyle(fontSize: 18, color: Colors.blueGrey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static ThemeData _buildTeenTheme() {
    return ThemeData(
      primarySwatch: Colors.indigo,
      scaffoldBackgroundColor: Colors.grey[50],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData _buildAdultTheme() {
    return ThemeData(
      primarySwatch: Colors.teal,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),
    );
  }

  static ThemeData _buildElderlyTheme() {
    return ThemeData(
      primarySwatch: Colors.teal,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 4,
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 24, color: Colors.black87),
        labelLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 60),
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      iconTheme: const IconThemeData(size: 40),
    );
  }
}
