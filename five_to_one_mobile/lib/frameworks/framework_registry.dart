import 'task_framework.dart';
import 'buffett_munger_framework.dart';
import 'eisenhower_matrix_framework.dart';
import '../models/item.dart';

/// Central registry for all available task frameworks
///
/// Frameworks must be registered here before they can be used.
/// Initialize all frameworks in main.dart using initializeFrameworks().
class FrameworkRegistry {
  static final Map<String, TaskFramework> _frameworks = {};

  /// Register a framework
  static void register(TaskFramework framework) {
    _frameworks[framework.id] = framework;
  }

  /// Get a framework by ID
  ///
  /// Returns null if framework doesn't exist.
  static TaskFramework? get(String? id) {
    return id != null ? _frameworks[id] : null;
  }

  /// Get all registered frameworks
  static List<TaskFramework> getAll() {
    return _frameworks.values.toList();
  }

  /// Get frameworks applicable to this task's children
  ///
  /// Returns only frameworks where canApplyToTask returns true.
  static List<TaskFramework> getApplicable(Item task, List<Item> children) {
    return _frameworks.values
        .where((f) => f.canApplyToTask(task, children))
        .toList();
  }

  /// Check if a framework exists
  static bool exists(String id) {
    return _frameworks.containsKey(id);
  }

  /// Get frameworks by IDs
  ///
  /// Returns list of frameworks matching the provided IDs.
  /// Filters out any IDs that don't match registered frameworks.
  static List<TaskFramework> getByIds(List<String> ids) {
    return ids
        .map((id) => _frameworks[id])
        .where((f) => f != null)
        .cast<TaskFramework>()
        .toList();
  }

  /// Clear all frameworks (for testing)
  static void clear() {
    _frameworks.clear();
  }
}

/// Initialize all frameworks
///
/// Call this in main.dart before runApp().
void initializeFrameworks() {
  FrameworkRegistry.register(BuffettMungerFramework());
  FrameworkRegistry.register(EisenhowerMatrixFramework());

  // TODO: Add more frameworks as they're implemented
  // FrameworkRegistry.register(TimeBlockingFramework());
  // FrameworkRegistry.register(KanbanFramework());
}
