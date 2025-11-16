import 'package:flutter/material.dart';
import '../models/app_settings.dart';

class AppTheme {
  // Default Color Palette - The Doors psychedelic vibe
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
  static const Color lightBackground = Color(0xFFF5F5F5);    // Light mode bg
  static const Color lightCardBackground = Color(0xFFFFFFFF); // Light card bg
  static const Color textPrimary = Color(0xFFECF0F1);        // Light text
  static const Color textSecondary = Color(0xFFBDC3C7);      // Secondary text
  static const Color textPrimaryDark = Color(0xFF2C3E50);    // Dark text for light mode
  static const Color textSecondaryDark = Color(0xFF7F8C8D);  // Secondary dark text

  /// Generate dynamic theme based on settings
  static ThemeData getTheme(AppSettings settings, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primaryColor = _hexToColor(settings.accentColor);
    final backgroundColor = _hexToColor(settings.backgroundValue);

    // Determine surface color based on background
    final surfaceColor = isDark
        ? (backgroundColor == darkBackground ? cardBackground : _adjustBrightness(backgroundColor, 0.1))
        : (backgroundColor == lightBackground ? lightCardBackground : _adjustBrightness(backgroundColor, 0.05));

    final textColor = isDark ? textPrimary : textPrimaryDark;
    final secondaryTextColor = isDark ? textSecondary : textSecondaryDark;

    // Apply high contrast adjustments
    final adjustedTextColor = settings.highContrastMode
        ? (isDark ? Colors.white : Colors.black)
        : textColor;

    // Apply font scale
    final fontScale = settings.largeTextMode ? 1.3 : settings.fontScale;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryColor,
              secondary: accentOrange,
              surface: surfaceColor,
              background: backgroundColor,
              error: urgentRed,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: adjustedTextColor,
              onBackground: adjustedTextColor,
            )
          : ColorScheme.light(
              primary: primaryColor,
              secondary: accentOrange,
              surface: surfaceColor,
              background: backgroundColor,
              error: urgentRed,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: adjustedTextColor,
              onBackground: adjustedTextColor,
            ),

      scaffoldBackgroundColor: backgroundColor,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20 * fontScale,
          fontWeight: FontWeight.bold,
          color: adjustedTextColor,
          fontFamily: settings.fontFamily != 'System' ? settings.fontFamily : null,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: settings.highContrastMode ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: settings.highContrastMode
              ? BorderSide(color: adjustedTextColor.withOpacity(0.2), width: 1)
              : BorderSide.none,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: 32 * (settings.compactMode ? 0.8 : 1.0),
            vertical: 16 * (settings.compactMode ? 0.8 : 1.0),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: 16 * fontScale,
            fontWeight: FontWeight.bold,
            fontFamily: settings.fontFamily != 'System' ? settings.fontFamily : null,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: settings.highContrastMode
              ? BorderSide(color: adjustedTextColor.withOpacity(0.3))
              : BorderSide.none,
        ),
        hintStyle: TextStyle(
          color: secondaryTextColor,
          fontFamily: settings.fontFamily != 'System' ? settings.fontFamily : null,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32 * fontScale,
          fontWeight: FontWeight.bold,
          color: adjustedTextColor,
          fontFamily: settings.fontFamily != 'System' ? settings.fontFamily : null,
        ),
        displayMedium: TextStyle(
          fontSize: 24 * fontScale,
          fontWeight: FontWeight.bold,
          color: adjustedTextColor,
          fontFamily: settings.fontFamily != 'System' ? settings.fontFamily : null,
        ),
        bodyLarge: TextStyle(
          fontSize: 16 * fontScale,
          color: adjustedTextColor,
          fontFamily: settings.fontFamily != 'System' ? settings.fontFamily : null,
        ),
        bodyMedium: TextStyle(
          fontSize: 14 * fontScale,
          color: secondaryTextColor,
          fontFamily: settings.fontFamily != 'System' ? settings.fontFamily : null,
        ),
        labelMedium: TextStyle(
          fontSize: 14 * fontScale,
          fontStyle: FontStyle.italic,
          color: secondaryTextColor,
          fontFamily: settings.fontFamily != 'System' ? settings.fontFamily : null,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return null;
        }),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        thumbColor: primaryColor,
        inactiveTrackColor: primaryColor.withOpacity(0.3),
      ),
    );
  }

  // Legacy dark theme for backward compatibility
  static ThemeData get darkTheme {
    return getTheme(const AppSettings(), Brightness.dark);
  }

  // Helper functions
  static Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Color _adjustBrightness(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final adjustedLightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(adjustedLightness).toColor();
  }
}

