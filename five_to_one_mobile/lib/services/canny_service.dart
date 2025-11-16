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
        'Canny is not configured. Please set CANNY_SUBDOMAIN',
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

  /// Build Canny URL
  /// Simply opens the public feedback board
  static String _buildCannyUrl() {
    return CannyConfig.feedbackUrl;
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
