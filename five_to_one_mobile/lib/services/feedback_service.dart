import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/feedback.dart' as app_feedback;
import 'supabase_service.dart';

/// Service for managing user feedback
class FeedbackService {
  static final SupabaseClient _client = SupabaseService.client;

  /// Submit new feedback
  static Future<app_feedback.Feedback> submitFeedback({
    required app_feedback.FeedbackCategory category,
    required String title,
    required String description,
    String? email,
    String? screenshotUrl,
  }) async {
    // Get current user ID if logged in
    final userId = SupabaseService.currentUser?.id;

    // Gather device info
    final deviceInfo = _getDeviceInfo();

    // Get app version (you can update this from pubspec.yaml)
    const appVersion = '0.1.0';

    final feedbackData = {
      'user_id': userId,
      'email': email,
      'category': category.value,
      'title': title,
      'description': description,
      'screenshot_url': screenshotUrl,
      'device_info': deviceInfo,
      'app_version': appVersion,
      'status': 'new',
      'priority': 'medium',
    };

    final response = await _client
        .from('feedback')
        .insert(feedbackData)
        .select()
        .single();

    return app_feedback.Feedback.fromJson(response);
  }

  /// Get all feedback for the current user
  static Future<List<app_feedback.Feedback>> getUserFeedback() async {
    final userId = SupabaseService.userId;

    final response = await _client
        .from('feedback')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => app_feedback.Feedback.fromJson(json))
        .toList();
  }

  /// Get all feedback (admin only)
  static Future<List<app_feedback.Feedback>> getAllFeedback({
    app_feedback.FeedbackStatus? status,
    app_feedback.FeedbackCategory? category,
    app_feedback.FeedbackPriority? priority,
  }) async {
    var query = _client.from('feedback').select();

    if (status != null) {
      query = query.eq('status', status.value);
    }

    if (category != null) {
      query = query.eq('category', category.value);
    }

    if (priority != null) {
      query = query.eq('priority', priority.value);
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List)
        .map((json) => app_feedback.Feedback.fromJson(json))
        .toList();
  }

  /// Update feedback (admin only)
  static Future<app_feedback.Feedback> updateFeedback({
    required String feedbackId,
    app_feedback.FeedbackStatus? status,
    app_feedback.FeedbackPriority? priority,
    String? adminNotes,
  }) async {
    final updateData = <String, dynamic>{};

    if (status != null) {
      updateData['status'] = status.value;
    }

    if (priority != null) {
      updateData['priority'] = priority.value;
    }

    if (adminNotes != null) {
      updateData['admin_notes'] = adminNotes;
    }

    final response = await _client
        .from('feedback')
        .update(updateData)
        .eq('id', feedbackId)
        .select()
        .single();

    return app_feedback.Feedback.fromJson(response);
  }

  /// Get feedback statistics (admin only)
  static Future<Map<String, dynamic>> getFeedbackStats() async {
    final response = await _client
        .from('feedback_stats')
        .select()
        .single();

    return response;
  }

  /// Delete feedback (admin only)
  static Future<void> deleteFeedback(String feedbackId) async {
    await _client.from('feedback').delete().eq('id', feedbackId);
  }

  /// Check if current user is admin
  static Future<bool> isAdmin() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return false;

      // Check user metadata for admin flag
      final metadata = user.userMetadata;
      return metadata?['is_admin'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Helper method to gather device information
  static Map<String, dynamic> _getDeviceInfo() {
    final info = <String, dynamic>{};

    if (kIsWeb) {
      info['platform'] = 'web';
      info['userAgent'] = 'browser'; // Can be enhanced with browser detection
    } else {
      try {
        info['platform'] = Platform.operatingSystem;
        info['version'] = Platform.operatingSystemVersion;
      } catch (e) {
        info['platform'] = 'unknown';
      }
    }

    return info;
  }

  /// Stream feedback updates (real-time)
  static Stream<List<app_feedback.Feedback>> streamUserFeedback() {
    final userId = SupabaseService.userId;

    return _client
        .from('feedback')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data
            .map((json) => app_feedback.Feedback.fromJson(json))
            .toList());
  }

  /// Stream all feedback (admin only)
  static Stream<List<app_feedback.Feedback>> streamAllFeedback() {
    return _client
        .from('feedback')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data
            .map((json) => app_feedback.Feedback.fromJson(json))
            .toList());
  }
}
