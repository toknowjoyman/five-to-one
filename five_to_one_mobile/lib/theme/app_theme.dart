import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette - The Doors psychedelic vibe
  static const Color primaryPurple = Color(0xFF6B2E9E);      // Deep purple
  static const Color primaryViolet = Color(0xFF9B59B6);      // Lighter violet
  static const Color accentOrange = Color(0xFFFF6B35);       // Electric orange
  static const Color accentGold = Color(0xFFFFB344);         // Gold
  static const Color successGreen = Color(0xFF2ECC71);       // Task completion
  static const Color urgentRed = Color(0xFFE74C3C);          // Urgent tag
  static const Color importantBlue = Color(0xFF3498DB);      // Important tag
  static const Color avoidGray = Color(0xFF95A5A6);          // Locked/Avoid
  static const Color darkBackground = Color(0xFF1A1A2E);     // Dark mode bg
  static const Color cardBackground = Color(0xFF16213E);     // Card bg
  static const Color textPrimary = Color(0xFFECF0F1);        // Light text
  static const Color textSecondary = Color(0xFFBDC3C7);      // Secondary text

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: accentOrange,
        surface: cardBackground,
        background: darkBackground,
        error: urgentRed,
      ),

      scaffoldBackgroundColor: darkBackground,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: textSecondary),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: textSecondary,
        ),
      ),
    );
  }
}
