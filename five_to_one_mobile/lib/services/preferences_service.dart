import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user preferences and app settings
class PreferencesService {
  static const _enabledFrameworksKey = 'enabled_frameworks';
  static const _hasCompletedOnboardingKey = 'has_completed_onboarding';

  /// Get list of enabled framework IDs
  Future<List<String>> getEnabledFrameworks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_enabledFrameworksKey) ?? [];
  }

  /// Enable a framework
  Future<void> enableFramework(String frameworkId) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = await getEnabledFrameworks();

    if (!enabled.contains(frameworkId)) {
      enabled.add(frameworkId);
      await prefs.setStringList(_enabledFrameworksKey, enabled);
    }
  }

  /// Disable a framework
  Future<void> disableFramework(String frameworkId) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = await getEnabledFrameworks();

    if (enabled.contains(frameworkId)) {
      enabled.remove(frameworkId);
      await prefs.setStringList(_enabledFrameworksKey, enabled);
    }
  }

  /// Check if a specific framework is enabled
  Future<bool> isFrameworkEnabled(String frameworkId) async {
    final enabled = await getEnabledFrameworks();
    return enabled.contains(frameworkId);
  }

  /// Check if user has completed initial onboarding
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCompletedOnboardingKey) ?? false;
  }

  /// Mark onboarding as complete
  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedOnboardingKey, true);
  }

  /// Clear all preferences (for testing/reset)
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
