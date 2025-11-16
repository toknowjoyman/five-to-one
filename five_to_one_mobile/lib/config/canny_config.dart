/// Canny Configuration
/// Get these values from your Canny dashboard
/// https://canny.io/admin

class CannyConfig {
  // Your Canny subdomain (e.g., 'yourcompany' for yourcompany.canny.io)
  // Set via environment variable or use default
  static const String subdomain = String.fromEnvironment(
    'CANNY_SUBDOMAIN',
    defaultValue: 'YOUR_CANNY_SUBDOMAIN',
  );

  // Your board URL name (e.g., 'feedback' from yourcompany.canny.io/feedback)
  // This is the board's URL slug, not a token
  // Set via environment variable or use default
  static const String boardName = String.fromEnvironment(
    'CANNY_BOARD_NAME',
    defaultValue: 'feedback',
  );

  // App ID from Canny (optional, for advanced features)
  // Settings > General > App ID
  static const String appId = String.fromEnvironment(
    'CANNY_APP_ID',
    defaultValue: '',
  );

  // Base URL for Canny
  static String get cannyUrl => 'https://$subdomain.canny.io';

  // Feedback board URL
  static String get feedbackUrl => '$cannyUrl/$boardName';

  // Check if Canny is configured (only subdomain is required)
  static bool get isConfigured => subdomain != 'YOUR_CANNY_SUBDOMAIN';
}
