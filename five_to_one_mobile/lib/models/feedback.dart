/// Feedback model for user feedback and bug reports
class Feedback {
  final String id;
  final String? userId;
  final String? email;
  final FeedbackCategory category;
  final String title;
  final String description;
  final String? screenshotUrl;
  final Map<String, dynamic>? deviceInfo;
  final String? appVersion;
  final FeedbackStatus status;
  final FeedbackPriority priority;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Feedback({
    required this.id,
    this.userId,
    this.email,
    required this.category,
    required this.title,
    required this.description,
    this.screenshotUrl,
    this.deviceInfo,
    this.appVersion,
    this.status = FeedbackStatus.newFeedback,
    this.priority = FeedbackPriority.medium,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create Feedback from JSON (from Supabase)
  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      email: json['email'] as String?,
      category: FeedbackCategory.fromString(json['category'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      screenshotUrl: json['screenshot_url'] as String?,
      deviceInfo: json['device_info'] as Map<String, dynamic>?,
      appVersion: json['app_version'] as String?,
      status: FeedbackStatus.fromString(json['status'] as String? ?? 'new'),
      priority: FeedbackPriority.fromString(json['priority'] as String? ?? 'medium'),
      adminNotes: json['admin_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert Feedback to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'email': email,
      'category': category.value,
      'title': title,
      'description': description,
      'screenshot_url': screenshotUrl,
      'device_info': deviceInfo,
      'app_version': appVersion,
      'status': status.value,
      'priority': priority.value,
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Feedback copyWith({
    String? id,
    String? userId,
    String? email,
    FeedbackCategory? category,
    String? title,
    String? description,
    String? screenshotUrl,
    Map<String, dynamic>? deviceInfo,
    String? appVersion,
    FeedbackStatus? status,
    FeedbackPriority? priority,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Feedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      screenshotUrl: screenshotUrl ?? this.screenshotUrl,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      appVersion: appVersion ?? this.appVersion,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Feedback category enum
enum FeedbackCategory {
  bug('bug', 'Bug Report', 'Report a bug or issue'),
  feature('feature', 'Feature Request', 'Suggest a new feature'),
  improvement('improvement', 'Improvement', 'Suggest an improvement'),
  other('other', 'Other', 'Other feedback');

  final String value;
  final String displayName;
  final String description;

  const FeedbackCategory(this.value, this.displayName, this.description);

  static FeedbackCategory fromString(String value) {
    return FeedbackCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FeedbackCategory.other,
    );
  }
}

/// Feedback status enum
enum FeedbackStatus {
  newFeedback('new', 'New'),
  inProgress('in_progress', 'In Progress'),
  completed('completed', 'Completed'),
  archived('archived', 'Archived');

  final String value;
  final String displayName;

  const FeedbackStatus(this.value, this.displayName);

  static FeedbackStatus fromString(String value) {
    return FeedbackStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FeedbackStatus.newFeedback,
    );
  }
}

/// Feedback priority enum
enum FeedbackPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  critical('critical', 'Critical');

  final String value;
  final String displayName;

  const FeedbackPriority(this.value, this.displayName);

  static FeedbackPriority fromString(String value) {
    return FeedbackPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FeedbackPriority.medium,
    );
  }
}
