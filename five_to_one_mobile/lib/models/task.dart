class Task {
  final String id;
  final String userId;
  final String goalId;
  final String? parentId; // Self-referential for fractal subtasks
  final String title;
  final bool isUrgent;
  final bool isImportant;
  final int position;
  final DateTime? completedAt;
  final DateTime createdAt;

  // For UI - not stored in DB
  List<Task>? children;

  Task({
    required this.id,
    required this.userId,
    required this.goalId,
    this.parentId,
    required this.title,
    this.isUrgent = false,
    this.isImportant = false,
    this.position = 0,
    this.completedAt,
    required this.createdAt,
    this.children,
  });

  bool get isCompleted => completedAt != null;
  bool get isRoot => parentId == null;
  bool get hasChildren => children != null && children!.isNotEmpty;

  // Get color based on urgent/important matrix
  int get tagColor {
    if (isUrgent && isImportant) {
      return 0xFFE74C3C; // Red + Blue = Purple-ish (both)
    } else if (isUrgent) {
      return 0xFFE74C3C; // Red
    } else if (isImportant) {
      return 0xFF3498DB; // Blue
    }
    return 0xFF95A5A6; // Gray (neither)
  }

  String get tagLabel {
    if (isUrgent && isImportant) return 'URGENT & IMPORTANT';
    if (isUrgent) return 'URGENT';
    if (isImportant) return 'IMPORTANT';
    return '';
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['user_id'],
      goalId: json['goal_id'],
      parentId: json['parent_id'],
      title: json['title'],
      isUrgent: json['is_urgent'] ?? false,
      isImportant: json['is_important'] ?? false,
      position: json['position'] ?? 0,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'goal_id': goalId,
      'parent_id': parentId,
      'title': title,
      'is_urgent': isUrgent,
      'is_important': isImportant,
      'position': position,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? userId,
    String? goalId,
    String? parentId,
    String? title,
    bool? isUrgent,
    bool? isImportant,
    int? position,
    DateTime? completedAt,
    DateTime? createdAt,
    List<Task>? children,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalId: goalId ?? this.goalId,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      isUrgent: isUrgent ?? this.isUrgent,
      isImportant: isImportant ?? this.isImportant,
      position: position ?? this.position,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      children: children ?? this.children,
    );
  }
}
