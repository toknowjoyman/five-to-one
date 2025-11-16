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

  // Your Canny board token (get from Settings > General > Board Tokens)
  // Set via environment variable or use default
  static const String boardToken = String.fromEnvironment(
    'CANNY_BOARD_TOKEN',
    defaultValue: 'YOUR_CANNY_BOARD_TOKEN',
  );

  // App ID from Canny (Settings > General > App ID)
  static const String appId = String.fromEnvironment(
    'CANNY_APP_ID',
    defaultValue: 'YOUR_CANNY_APP_ID',
  );

  // Base URL for Canny
  static String get cannyUrl => 'https://$subdomain.canny.io';

  // Feedback board URL
  static String get feedbackUrl => '$cannyUrl/feedback';

  // Widget URL with board token
  static String get widgetUrl => '$cannyUrl/feedback?boardToken=$boardToken';

  // Check if Canny is configured
  static bool get isConfigured =>
      subdomain != 'YOUR_CANNY_SUBDOMAIN' &&
      boardToken != 'YOUR_CANNY_BOARD_TOKEN';
}
