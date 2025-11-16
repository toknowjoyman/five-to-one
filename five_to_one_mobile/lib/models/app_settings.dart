import 'package:flutter/material.dart';

/// App settings model that stores all user preferences
class AppSettings {
  // Theme settings
  final ThemeMode themeMode;
  final String accentColor;
  final BackgroundType backgroundType;
  final String backgroundValue; // Color hex, gradient JSON, or image path
  final double backgroundOpacity;

  // Font settings
  final double fontScale;
  final String fontFamily;
  final FontWeight fontWeight;

  // UI Preferences
  final bool showCompletedTasks;
  final bool enableAnimations;
  final bool enableHaptics;
  final bool enableSoundEffects;
  final bool compactMode;

  // Notification settings
  final bool enableNotifications;
  final bool enableReminders;
  final int reminderMinutesBefore;

  // Privacy & Security
  final bool requireBiometrics;
  final bool requirePIN;
  final String? pinCode;
  final bool autoLockEnabled;
  final int autoLockMinutes;

  // Productivity settings
  final bool enableStreaks;
  final bool enableGamification;
  final bool showProductivityStats;
  final int dailyGoalTasks;

  // Data & Sync
  final bool autoBackup;
  final bool offlineMode;
  final bool syncOnWifiOnly;

  // Accessibility
  final bool highContrastMode;
  final bool largeTextMode;
  final bool reduceMotion;
  final bool screenReaderOptimized;

  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.accentColor = '#6B2E9E',
    this.backgroundType = BackgroundType.solidColor,
    this.backgroundValue = '#1A1A2E',
    this.backgroundOpacity = 1.0,
    this.fontScale = 1.0,
    this.fontFamily = 'System',
    this.fontWeight = FontWeight.normal,
    this.showCompletedTasks = true,
    this.enableAnimations = true,
    this.enableHaptics = true,
    this.enableSoundEffects = false,
    this.compactMode = false,
    this.enableNotifications = true,
    this.enableReminders = true,
    this.reminderMinutesBefore = 15,
    this.requireBiometrics = false,
    this.requirePIN = false,
    this.pinCode,
    this.autoLockEnabled = false,
    this.autoLockMinutes = 5,
    this.enableStreaks = true,
    this.enableGamification = true,
    this.showProductivityStats = true,
    this.dailyGoalTasks = 5,
    this.autoBackup = true,
    this.offlineMode = false,
    this.syncOnWifiOnly = false,
    this.highContrastMode = false,
    this.largeTextMode = false,
    this.reduceMotion = false,
    this.screenReaderOptimized = false,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? accentColor,
    BackgroundType? backgroundType,
    String? backgroundValue,
    double? backgroundOpacity,
    double? fontScale,
    String? fontFamily,
    FontWeight? fontWeight,
    bool? showCompletedTasks,
    bool? enableAnimations,
    bool? enableHaptics,
    bool? enableSoundEffects,
    bool? compactMode,
    bool? enableNotifications,
    bool? enableReminders,
    int? reminderMinutesBefore,
    bool? requireBiometrics,
    bool? requirePIN,
    String? pinCode,
    bool? autoLockEnabled,
    int? autoLockMinutes,
    bool? enableStreaks,
    bool? enableGamification,
    bool? showProductivityStats,
    int? dailyGoalTasks,
    bool? autoBackup,
    bool? offlineMode,
    bool? syncOnWifiOnly,
    bool? highContrastMode,
    bool? largeTextMode,
    bool? reduceMotion,
    bool? screenReaderOptimized,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundValue: backgroundValue ?? this.backgroundValue,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      fontScale: fontScale ?? this.fontScale,
      fontFamily: fontFamily ?? this.fontFamily,
      fontWeight: fontWeight ?? this.fontWeight,
      showCompletedTasks: showCompletedTasks ?? this.showCompletedTasks,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
      compactMode: compactMode ?? this.compactMode,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableReminders: enableReminders ?? this.enableReminders,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      requireBiometrics: requireBiometrics ?? this.requireBiometrics,
      requirePIN: requirePIN ?? this.requirePIN,
      pinCode: pinCode ?? this.pinCode,
      autoLockEnabled: autoLockEnabled ?? this.autoLockEnabled,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      enableStreaks: enableStreaks ?? this.enableStreaks,
      enableGamification: enableGamification ?? this.enableGamification,
      showProductivityStats: showProductivityStats ?? this.showProductivityStats,
      dailyGoalTasks: dailyGoalTasks ?? this.dailyGoalTasks,
      autoBackup: autoBackup ?? this.autoBackup,
      offlineMode: offlineMode ?? this.offlineMode,
      syncOnWifiOnly: syncOnWifiOnly ?? this.syncOnWifiOnly,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      largeTextMode: largeTextMode ?? this.largeTextMode,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      screenReaderOptimized: screenReaderOptimized ?? this.screenReaderOptimized,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'accentColor': accentColor,
      'backgroundType': backgroundType.index,
      'backgroundValue': backgroundValue,
      'backgroundOpacity': backgroundOpacity,
      'fontScale': fontScale,
      'fontFamily': fontFamily,
      'fontWeight': fontWeight.index,
      'showCompletedTasks': showCompletedTasks,
      'enableAnimations': enableAnimations,
      'enableHaptics': enableHaptics,
      'enableSoundEffects': enableSoundEffects,
      'compactMode': compactMode,
      'enableNotifications': enableNotifications,
      'enableReminders': enableReminders,
      'reminderMinutesBefore': reminderMinutesBefore,
      'requireBiometrics': requireBiometrics,
      'requirePIN': requirePIN,
      'pinCode': pinCode,
      'autoLockEnabled': autoLockEnabled,
      'autoLockMinutes': autoLockMinutes,
      'enableStreaks': enableStreaks,
      'enableGamification': enableGamification,
      'showProductivityStats': showProductivityStats,
      'dailyGoalTasks': dailyGoalTasks,
      'autoBackup': autoBackup,
      'offlineMode': offlineMode,
      'syncOnWifiOnly': syncOnWifiOnly,
      'highContrastMode': highContrastMode,
      'largeTextMode': largeTextMode,
      'reduceMotion': reduceMotion,
      'screenReaderOptimized': screenReaderOptimized,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] ?? 2],
      accentColor: json['accentColor'] ?? '#6B2E9E',
      backgroundType: BackgroundType.values[json['backgroundType'] ?? 0],
      backgroundValue: json['backgroundValue'] ?? '#1A1A2E',
      backgroundOpacity: json['backgroundOpacity'] ?? 1.0,
      fontScale: json['fontScale'] ?? 1.0,
      fontFamily: json['fontFamily'] ?? 'System',
      fontWeight: FontWeight.values[json['fontWeight'] ?? 3],
      showCompletedTasks: json['showCompletedTasks'] ?? true,
      enableAnimations: json['enableAnimations'] ?? true,
      enableHaptics: json['enableHaptics'] ?? true,
      enableSoundEffects: json['enableSoundEffects'] ?? false,
      compactMode: json['compactMode'] ?? false,
      enableNotifications: json['enableNotifications'] ?? true,
      enableReminders: json['enableReminders'] ?? true,
      reminderMinutesBefore: json['reminderMinutesBefore'] ?? 15,
      requireBiometrics: json['requireBiometrics'] ?? false,
      requirePIN: json['requirePIN'] ?? false,
      pinCode: json['pinCode'],
      autoLockEnabled: json['autoLockEnabled'] ?? false,
      autoLockMinutes: json['autoLockMinutes'] ?? 5,
      enableStreaks: json['enableStreaks'] ?? true,
      enableGamification: json['enableGamification'] ?? true,
      showProductivityStats: json['showProductivityStats'] ?? true,
      dailyGoalTasks: json['dailyGoalTasks'] ?? 5,
      autoBackup: json['autoBackup'] ?? true,
      offlineMode: json['offlineMode'] ?? false,
      syncOnWifiOnly: json['syncOnWifiOnly'] ?? false,
      highContrastMode: json['highContrastMode'] ?? false,
      largeTextMode: json['largeTextMode'] ?? false,
      reduceMotion: json['reduceMotion'] ?? false,
      screenReaderOptimized: json['screenReaderOptimized'] ?? false,
    );
  }
}

enum BackgroundType {
  solidColor,
  gradient,
  image,
  pattern,
}

/// Predefined color palettes for quick selection
class ColorPalette {
  final String name;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;

  const ColorPalette({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
  });

  static const psychedelic = ColorPalette(
    name: 'Psychedelic',
    primary: Color(0xFF6B2E9E),
    secondary: Color(0xFFFF6B35),
    background: Color(0xFF1A1A2E),
    surface: Color(0xFF16213E),
  );

  static const ocean = ColorPalette(
    name: 'Ocean',
    primary: Color(0xFF0077BE),
    secondary: Color(0xFF00D9FF),
    background: Color(0xFF001F3F),
    surface: Color(0xFF003D5C),
  );

  static const forest = ColorPalette(
    name: 'Forest',
    primary: Color(0xFF2D5016),
    secondary: Color(0xFF8BC34A),
    background: Color(0xFF1B2E0F),
    surface: Color(0xFF2A4317),
  );

  static const sunset = ColorPalette(
    name: 'Sunset',
    primary: Color(0xFFFF6B6B),
    secondary: Color(0xFFFFE66D),
    background: Color(0xFF2C1810),
    surface: Color(0xFF4A2C1E),
  );

  static const midnight = ColorPalette(
    name: 'Midnight',
    primary: Color(0xFF4A148C),
    secondary: Color(0xFF9C27B0),
    background: Color(0xFF0A0A0A),
    surface: Color(0xFF1E1E1E),
  );

  static const mint = ColorPalette(
    name: 'Mint',
    primary: Color(0xFF00897B),
    secondary: Color(0xFF4DB6AC),
    background: Color(0xFF0D2926),
    surface: Color(0xFF1A4D47),
  );

  static const rose = ColorPalette(
    name: 'Rose',
    primary: Color(0xFFC2185B),
    secondary: Color(0xFFF06292),
    background: Color(0xFF2A1420),
    surface: Color(0xFF4A2336),
  );

  static const amber = ColorPalette(
    name: 'Amber',
    primary: Color(0xFFFF8F00),
    secondary: Color(0xFFFFB300),
    background: Color(0xFF2A1F0A),
    surface: Color(0xFF4A3714),
  );

  static List<ColorPalette> get allPalettes => [
        psychedelic,
        ocean,
        forest,
        sunset,
        midnight,
        mint,
        rose,
        amber,
      ];
}
