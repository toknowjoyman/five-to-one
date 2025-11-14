class Goal {
  final String id;
  final String userId;
  final String? lifeAreaId; // For future life areas feature
  final String title;
  final int? priority; // 1-5 for top priorities, null for avoid list
  final bool isAvoided;
  final DateTime createdAt;
  final DateTime? completedAt;

  Goal({
    required this.id,
    required this.userId,
    this.lifeAreaId,
    required this.title,
    this.priority,
    this.isAvoided = false,
    required this.createdAt,
    this.completedAt,
  });

  bool get isTopPriority => priority != null && priority! <= 5;
  bool get isCompleted => completedAt != null;

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      userId: json['user_id'],
      lifeAreaId: json['life_area_id'],
      title: json['title'],
      priority: json['priority'],
      isAvoided: json['is_avoided'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'life_area_id': lifeAreaId,
      'title': title,
      'priority': priority,
      'is_avoided': isAvoided,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  Goal copyWith({
    String? id,
    String? userId,
    String? lifeAreaId,
    String? title,
    int? priority,
    bool? isAvoided,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lifeAreaId: lifeAreaId ?? this.lifeAreaId,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      isAvoided: isAvoided ?? this.isAvoided,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
