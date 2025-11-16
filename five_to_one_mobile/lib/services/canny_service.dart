import 'package:url_launcher/url_launcher.dart';
import '../config/canny_config.dart';
import 'auth_service.dart';

/// Service for integrating with Canny feedback platform
class CannyService {
  /// Open Canny feedback widget
  ///
  /// This will open Canny in a new browser tab/window where users can:
  /// - Submit feedback
  /// - Vote on existing feedback
  /// - See your product roadmap
  /// - Track the status of their requests
  static Future<bool> openFeedback() async {
    if (!CannyConfig.isConfigured) {
      throw Exception(
        'Canny is not configured. Please set CANNY_SUBDOMAIN and CANNY_BOARD_TOKEN',
      );
    }

    final url = _buildCannyUrl();
    final uri = Uri.parse(url);

    // Try to launch URL
    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Opens in new tab/window
      );
    } else {
      throw Exception('Could not launch Canny: $url');
    }
  }

  /// Build Canny URL with user information for SSO
  /// This allows Canny to identify the user and show their feedback history
  static String _buildCannyUrl() {
    final baseUrl = CannyConfig.widgetUrl;

    // Try to get user information for better UX
    final user = AuthService().currentUser;

    if (user != null) {
      // Add user info as query parameters for better UX
      // Canny will recognize the user if they're logged in
      final params = {
        'user_email': user.email ?? '',
        'user_id': user.id,
      };

      final queryString = params.entries
          .where((e) => e.value.isNotEmpty)
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      return '$baseUrl${baseUrl.contains('?') ? '&' : '?'}$queryString';
    }

    return baseUrl;
  }

  /// Check if Canny is properly configured
  static bool isConfigured() {
    return CannyConfig.isConfigured;
  }

  /// Get the Canny feedback URL (for sharing)
  static String getFeedbackUrl() {
    return CannyConfig.feedbackUrl;
  }
}
