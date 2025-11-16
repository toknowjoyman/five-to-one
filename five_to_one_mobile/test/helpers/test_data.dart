import 'package:five_to_one/models/item.dart';

/// Helper class for creating test data
///
/// This class provides factory methods to create common test objects
/// with sensible defaults, making tests cleaner and more maintainable.
class TestData {
  static final DateTime defaultDate = DateTime.parse('2024-01-01T00:00:00Z');

  /// Create a basic item with minimal required fields
  static Item createItem({
    String? id,
    String? userId,
    String? parentId,
    String? title,
    int position = 0,
    List<String> frameworkIds = const [],
    int? priority,
    bool isAvoided = false,
    bool isUrgent = false,
    bool isImportant = false,
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
      id: id ?? 'test-id-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId ?? 'test-user',
      parentId: parentId,
      title: title ?? 'Test Item',
      position: position,
      frameworkIds: frameworkIds,
      priority: priority,
      isAvoided: isAvoided,
      isUrgent: isUrgent,
      isImportant: isImportant,
      scheduledFor: scheduledFor,
      durationMinutes: durationMinutes,
      kanbanColumn: kanbanColumn,
      columnPosition: columnPosition,
      color: color,
      icon: icon,
      completedAt: completedAt,
      createdAt: createdAt ?? defaultDate,
      children: children,
      depth: depth,
    );
  }

  /// Create a root-level goal (no parent)
  static Item createGoal({
    String? id,
    String? title,
    int position = 0,
    int? priority,
    bool isAvoided = false,
  }) {
    return createItem(
      id: id ?? 'goal-${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Test Goal',
      parentId: null,
      position: position,
      priority: priority,
      isAvoided: isAvoided,
      depth: 0,
    );
  }

  /// Create a task (child item)
  static Item createTask({
    String? id,
    String? parentId,
    String? title,
    int position = 0,
    bool isUrgent = false,
    bool isImportant = false,
    bool isCompleted = false,
  }) {
    return createItem(
      id: id ?? 'task-${DateTime.now().millisecondsSinceEpoch}',
      parentId: parentId ?? 'parent-id',
      title: title ?? 'Test Task',
      position: position,
      isUrgent: isUrgent,
      isImportant: isImportant,
      completedAt: isCompleted ? defaultDate : null,
      depth: 2,
    );
  }

  /// Create a completed item
  static Item createCompletedItem({
    String? id,
    String? title,
    DateTime? completedAt,
  }) {
    return createItem(
      id: id,
      title: title ?? 'Completed Item',
      completedAt: completedAt ?? defaultDate,
    );
  }

  /// Create a top priority item (Buffett-Munger)
  static Item createTopPriorityItem({
    String? id,
    String? title,
    required int priority,
  }) {
    assert(priority >= 1 && priority <= 5, 'Priority must be 1-5');
    return createItem(
      id: id,
      title: title ?? 'Priority $priority Item',
      priority: priority,
      frameworkIds: ['buffett-munger'],
    );
  }

  /// Create an avoided item (Buffett-Munger)
  static Item createAvoidedItem({
    String? id,
    String? title,
  }) {
    return createItem(
      id: id,
      title: title ?? 'Avoided Item',
      isAvoided: true,
      frameworkIds: ['buffett-munger'],
    );
  }

  /// Create an Eisenhower matrix item
  static Item createEisenhowerItem({
    String? id,
    String? title,
    required bool isUrgent,
    required bool isImportant,
  }) {
    return createItem(
      id: id,
      title: title ?? 'Eisenhower Item',
      isUrgent: isUrgent,
      isImportant: isImportant,
      frameworkIds: ['eisenhower'],
    );
  }

  /// Create a list of top 5 priority goals
  static List<Item> createTopFiveGoals() {
    return List.generate(
      5,
      (i) => createGoal(
        id: 'goal-${i + 1}',
        title: 'Goal ${i + 1}',
        priority: i + 1,
        position: i,
      ),
    );
  }

  /// Create a full Buffett 5/25 list (5 priorities + 20 avoided)
  static List<Item> createBuffett525List() {
    return List.generate(
      25,
      (i) => createGoal(
        id: 'goal-${i + 1}',
        title: 'Goal ${i + 1}',
        priority: i < 5 ? i + 1 : null,
        isAvoided: i >= 5,
        position: i,
      ),
    );
  }

  /// Create items for all Eisenhower quadrants
  static List<Item> createEisenhowerQuadrants() {
    return [
      // Q1: Urgent & Important (Do First)
      createEisenhowerItem(
        id: 'q1-1',
        title: 'Crisis Task',
        isUrgent: true,
        isImportant: true,
      ),
      // Q2: Not Urgent & Important (Schedule)
      createEisenhowerItem(
        id: 'q2-1',
        title: 'Strategic Planning',
        isUrgent: false,
        isImportant: true,
      ),
      // Q3: Urgent & Not Important (Delegate)
      createEisenhowerItem(
        id: 'q3-1',
        title: 'Interruption',
        isUrgent: true,
        isImportant: false,
      ),
      // Q4: Neither (Eliminate)
      createEisenhowerItem(
        id: 'q4-1',
        title: 'Distraction',
        isUrgent: false,
        isImportant: false,
      ),
    ];
  }

  /// Create a parent item with children
  static Item createItemWithChildren({
    String? id,
    String? title,
    required int childCount,
    bool childrenCompleted = false,
  }) {
    final parent = createItem(
      id: id ?? 'parent-id',
      title: title ?? 'Parent Item',
    );

    final children = List.generate(
      childCount,
      (i) => createTask(
        id: 'child-$i',
        parentId: parent.id,
        title: 'Child $i',
        position: i,
        isCompleted: childrenCompleted,
      ),
    );

    return parent.copyWith(children: children);
  }

  /// Create a scheduled item (Time Blocking)
  static Item createScheduledItem({
    String? id,
    String? title,
    DateTime? scheduledFor,
    int durationMinutes = 60,
  }) {
    return createItem(
      id: id,
      title: title ?? 'Scheduled Task',
      scheduledFor: scheduledFor ?? defaultDate,
      durationMinutes: durationMinutes,
    );
  }

  /// Create a Kanban item
  static Item createKanbanItem({
    String? id,
    String? title,
    required String column,
    int columnPosition = 0,
  }) {
    return createItem(
      id: id,
      title: title ?? 'Kanban Task',
      kanbanColumn: column,
      columnPosition: columnPosition,
    );
  }

  /// Create sample JSON for testing deserialization
  static Map<String, dynamic> createItemJson({
    String? id,
    String? userId,
    String? parentId,
    String? title,
    int position = 0,
    List<String> frameworkIds = const [],
    int? priority,
    bool isAvoided = false,
    bool isUrgent = false,
    bool isImportant = false,
    String? scheduledFor,
    int? durationMinutes,
    String? kanbanColumn,
    int? columnPosition,
    String? color,
    String? icon,
    String? completedAt,
    String? createdAt,
  }) {
    return {
      'id': id ?? 'test-id',
      'user_id': userId ?? 'test-user',
      if (parentId != null) 'parent_id': parentId,
      'title': title ?? 'Test Item',
      'position': position,
      'framework_ids': frameworkIds,
      if (priority != null) 'priority': priority,
      'is_avoided': isAvoided,
      'is_urgent': isUrgent,
      'is_important': isImportant,
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (kanbanColumn != null) 'kanban_column': kanbanColumn,
      if (columnPosition != null) 'column_position': columnPosition,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (completedAt != null) 'completed_at': completedAt,
      'created_at': createdAt ?? '2024-01-01T00:00:00Z',
    };
  }
}
