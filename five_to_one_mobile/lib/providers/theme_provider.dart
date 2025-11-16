import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_settings.dart';
import '../services/preferences_service.dart';

/// Provider for managing app theme and settings
class ThemeProvider extends ChangeNotifier {
  AppSettings _settings = const AppSettings();
  final PreferencesService _preferencesService = PreferencesService();

  AppSettings get settings => _settings;

  ThemeProvider() {
    _loadSettings();
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    _settings = await _preferencesService.getAppSettings();
    notifyListeners();
  }

  /// Save current settings to storage
  Future<void> _saveSettings() async {
    await _preferencesService.saveAppSettings(_settings);
    notifyListeners();
  }

  // Theme Mode
  ThemeMode get themeMode => _settings.themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _saveSettings();
  }

  // Accent Color
  Color get accentColor => _hexToColor(_settings.accentColor);

  Future<void> setAccentColor(Color color) async {
    _settings = _settings.copyWith(accentColor: _colorToHex(color));
    await _saveSettings();
  }

  // Background
  BackgroundType get backgroundType => _settings.backgroundType;
  String get backgroundValue => _settings.backgroundValue;
  double get backgroundOpacity => _settings.backgroundOpacity;

  Future<void> setBackground({
    BackgroundType? type,
    String? value,
    double? opacity,
  }) async {
    _settings = _settings.copyWith(
      backgroundType: type,
      backgroundValue: value,
      backgroundOpacity: opacity,
    );
    await _saveSettings();
  }

  // Apply a predefined color palette
  Future<void> applyColorPalette(ColorPalette palette) async {
    _settings = _settings.copyWith(
      accentColor: _colorToHex(palette.primary),
      backgroundValue: _colorToHex(palette.background),
      backgroundType: BackgroundType.solidColor,
    );
    await _saveSettings();
  }

  // Font Settings
  double get fontScale => _settings.fontScale;
  String get fontFamily => _settings.fontFamily;
  FontWeight get fontWeight => _settings.fontWeight;

  Future<void> setFontScale(double scale) async {
    _settings = _settings.copyWith(fontScale: scale);
    await _saveSettings();
  }

  Future<void> setFontFamily(String family) async {
    _settings = _settings.copyWith(fontFamily: family);
    await _saveSettings();
  }

  Future<void> setFontWeight(FontWeight weight) async {
    _settings = _settings.copyWith(fontWeight: weight);
    await _saveSettings();
  }

  // UI Preferences
  bool get showCompletedTasks => _settings.showCompletedTasks;
  bool get enableAnimations => _settings.enableAnimations;
  bool get enableHaptics => _settings.enableHaptics;
  bool get enableSoundEffects => _settings.enableSoundEffects;
  bool get compactMode => _settings.compactMode;

  Future<void> setShowCompletedTasks(bool value) async {
    _settings = _settings.copyWith(showCompletedTasks: value);
    await _saveSettings();
  }

  Future<void> setEnableAnimations(bool value) async {
    _settings = _settings.copyWith(enableAnimations: value);
    await _saveSettings();
  }

  Future<void> setEnableHaptics(bool value) async {
    _settings = _settings.copyWith(enableHaptics: value);
    await _saveSettings();
  }

  Future<void> setEnableSoundEffects(bool value) async {
    _settings = _settings.copyWith(enableSoundEffects: value);
    await _saveSettings();
  }

  Future<void> setCompactMode(bool value) async {
    _settings = _settings.copyWith(compactMode: value);
    await _saveSettings();
  }

  // Notification Settings
  bool get enableNotifications => _settings.enableNotifications;
  bool get enableReminders => _settings.enableReminders;
  int get reminderMinutesBefore => _settings.reminderMinutesBefore;

  Future<void> setEnableNotifications(bool value) async {
    _settings = _settings.copyWith(enableNotifications: value);
    await _saveSettings();
  }

  Future<void> setEnableReminders(bool value) async {
    _settings = _settings.copyWith(enableReminders: value);
    await _saveSettings();
  }

  Future<void> setReminderMinutesBefore(int value) async {
    _settings = _settings.copyWith(reminderMinutesBefore: value);
    await _saveSettings();
  }

  // Privacy & Security
  bool get requireBiometrics => _settings.requireBiometrics;
  bool get requirePIN => _settings.requirePIN;
  String? get pinCode => _settings.pinCode;
  bool get autoLockEnabled => _settings.autoLockEnabled;
  int get autoLockMinutes => _settings.autoLockMinutes;

  Future<void> setRequireBiometrics(bool value) async {
    _settings = _settings.copyWith(requireBiometrics: value);
    await _saveSettings();
  }

  Future<void> setRequirePIN(bool value) async {
    _settings = _settings.copyWith(requirePIN: value);
    await _saveSettings();
  }

  Future<void> setPinCode(String? code) async {
    _settings = _settings.copyWith(pinCode: code);
    await _saveSettings();
  }

  Future<void> setAutoLockEnabled(bool value) async {
    _settings = _settings.copyWith(autoLockEnabled: value);
    await _saveSettings();
  }

  Future<void> setAutoLockMinutes(int value) async {
    _settings = _settings.copyWith(autoLockMinutes: value);
    await _saveSettings();
  }

  // Productivity Settings
  bool get enableStreaks => _settings.enableStreaks;
  bool get enableGamification => _settings.enableGamification;
  bool get showProductivityStats => _settings.showProductivityStats;
  int get dailyGoalTasks => _settings.dailyGoalTasks;

  Future<void> setEnableStreaks(bool value) async {
    _settings = _settings.copyWith(enableStreaks: value);
    await _saveSettings();
  }

  Future<void> setEnableGamification(bool value) async {
    _settings = _settings.copyWith(enableGamification: value);
    await _saveSettings();
  }

  Future<void> setShowProductivityStats(bool value) async {
    _settings = _settings.copyWith(showProductivityStats: value);
    await _saveSettings();
  }

  Future<void> setDailyGoalTasks(int value) async {
    _settings = _settings.copyWith(dailyGoalTasks: value);
    await _saveSettings();
  }

  // Data & Sync
  bool get autoBackup => _settings.autoBackup;
  bool get offlineMode => _settings.offlineMode;
  bool get syncOnWifiOnly => _settings.syncOnWifiOnly;

  Future<void> setAutoBackup(bool value) async {
    _settings = _settings.copyWith(autoBackup: value);
    await _saveSettings();
  }

  Future<void> setOfflineMode(bool value) async {
    _settings = _settings.copyWith(offlineMode: value);
    await _saveSettings();
  }

  Future<void> setSyncOnWifiOnly(bool value) async {
    _settings = _settings.copyWith(syncOnWifiOnly: value);
    await _saveSettings();
  }

  // Accessibility
  bool get highContrastMode => _settings.highContrastMode;
  bool get largeTextMode => _settings.largeTextMode;
  bool get reduceMotion => _settings.reduceMotion;
  bool get screenReaderOptimized => _settings.screenReaderOptimized;

  Future<void> setHighContrastMode(bool value) async {
    _settings = _settings.copyWith(highContrastMode: value);
    await _saveSettings();
  }

  Future<void> setLargeTextMode(bool value) async {
    _settings = _settings.copyWith(largeTextMode: value);
    await _saveSettings();
  }

  Future<void> setReduceMotion(bool value) async {
    _settings = _settings.copyWith(reduceMotion: value);
    await _saveSettings();
  }

  Future<void> setScreenReaderOptimized(bool value) async {
    _settings = _settings.copyWith(screenReaderOptimized: value);
    await _saveSettings();
  }

  // Haptic feedback helper
  void triggerHaptic() {
    if (_settings.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  // Helper functions
  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
