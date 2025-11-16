class Item {
  final String id;
  final String userId;
  final String? parentId; // NULL = root level (life area in V2, goal in V1)
  final String title;
  final int position;

  // Framework system - which frameworks organize this item's children
  final List<String> frameworkIds; // ['buffett-munger', 'eisenhower']

  // Optional metadata - used at different levels
  final int? priority; // 1-5 for top priorities (Buffett-Munger)
  final bool isAvoided; // True for avoid list (Buffett-Munger)
  final bool isUrgent; // For tasks (Eisenhower matrix)
  final bool isImportant; // For tasks (Eisenhower matrix)

  // Time Blocking framework
  final DateTime? scheduledFor;
  final int? durationMinutes;

  // Kanban framework
  final String? kanbanColumn; // 'todo', 'in-progress', 'done'
  final int? columnPosition;

  final String? color; // For life areas (V2)
  final String? icon; // For life areas (V2)

  final DateTime? completedAt;
  final DateTime createdAt;

  // For UI - not stored in DB
  List<Item>? children;
  int? depth; // Calculated from ancestors

  Item({
    required this.id,
    required this.userId,
    this.parentId,
    required this.title,
    this.position = 0,
    this.frameworkIds = const [],
    this.priority,
    this.isAvoided = false,
    this.isUrgent = false,
    this.isImportant = false,
    this.scheduledFor,
    this.durationMinutes,
    this.kanbanColumn,
    this.columnPosition,
    this.color,
    this.icon,
    this.completedAt,
    required this.createdAt,
    this.children,
    this.depth,
  });

  // Computed properties
  bool get isCompleted => completedAt != null;
  bool get isRoot => parentId == null;
  bool get hasChildren => children != null && children!.isNotEmpty;
  bool get isTopPriority => priority != null && priority! <= 5;

  // Infer type from depth (if provided)
  ItemType get type {
    if (depth == null) return ItemType.unknown;
    switch (depth) {
      case 0:
        return ItemType.lifeArea; // V2
      case 1:
        return ItemType.goal; // V1 if root, V2 if has parent
      default:
        return ItemType.task; // Depth 2+
    }
  }

  // Get color based on urgent/important matrix (for tasks)
  int get tagColor {
    if (isUrgent && isImportant) {
      return 0xFFE74C3C; // Red + Blue = Both
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

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      userId: json['user_id'],
      parentId: json['parent_id'],
      title: json['title'],
      position: json['position'] ?? 0,
      frameworkIds: json['framework_ids'] != null
          ? List<String>.from(json['framework_ids'])
          : [],
      priority: json['priority'],
      isAvoided: json['is_avoided'] ?? false,
      isUrgent: json['is_urgent'] ?? false,
      isImportant: json['is_important'] ?? false,
      scheduledFor: json['scheduled_for'] != null
          ? DateTime.parse(json['scheduled_for'])
          : null,
      durationMinutes: json['duration_minutes'],
      kanbanColumn: json['kanban_column'],
      columnPosition: json['column_position'],
      color: json['color'],
      icon: json['icon'],
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
      'parent_id': parentId,
      'title': title,
      'position': position,
      'framework_ids': frameworkIds,
      'priority': priority,
      'is_avoided': isAvoided,
      'is_urgent': isUrgent,
      'is_important': isImportant,
      'scheduled_for': scheduledFor?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'kanban_column': kanbanColumn,
      'column_position': columnPosition,
      'color': color,
      'icon': icon,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Item copyWith({
    String? id,
    String? userId,
    String? parentId,
    String? title,
    int? position,
    List<String>? frameworkIds,
    int? priority,
    bool? isAvoided,
    bool? isUrgent,
    bool? isImportant,
    DateTime? scheduledFor,
    int? durationMinutes,
    String? kanbanColumn,
    int? columnPosition,
    String? color,
    String? icon,
    DateTime? completedAt,
    DateTime? createdAt,
    List<Item>? children,
    int? depth,
  }) {
    return Item(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      position: position ?? this.position,
      frameworkIds: frameworkIds ?? this.frameworkIds,
      priority: priority ?? this.priority,
      isAvoided: isAvoided ?? this.isAvoided,
      isUrgent: isUrgent ?? this.isUrgent,
      isImportant: isImportant ?? this.isImportant,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      kanbanColumn: kanbanColumn ?? this.kanbanColumn,
      columnPosition: columnPosition ?? this.columnPosition,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      children: children ?? this.children,
      depth: depth ?? this.depth,
    );
  }
}

// Helper enum for UI rendering decisions
enum ItemType {
  unknown,
  lifeArea, // Depth 0 (V2)
  goal, // Depth 0 (V1) or Depth 1 (V2)
  task, // Depth 2+
}
