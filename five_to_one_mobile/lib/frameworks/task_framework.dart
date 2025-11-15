import 'package:flutter/material.dart';
import '../models/item.dart';

/// Base interface for all task management frameworks
///
/// A framework is a lens through which users can organize their tasks.
/// Examples: Buffett-Munger 5/25, Eisenhower Matrix, GTD, etc.
abstract class TaskFramework {
  /// Unique identifier for this framework
  String get id;

  /// Display name
  String get name;

  /// Short description
  String get description;

  /// Icon to represent this framework
  IconData get icon;

  /// Color theme for this framework
  Color get color;

  /// Can this framework be applied to the current task set?
  ///
  /// For example, Buffett-Munger needs at least 5 root tasks.
  /// Returns true if applicable, false if not.
  bool canApply(List<Item> tasks);

  /// Why can't this framework be applied? (shown if canApply returns false)
  String? getCannotApplyReason(List<Item> tasks);

  /// Setup/onboarding flow for this framework
  ///
  /// This is shown when a user enables the framework for the first time.
  /// Should return a widget that guides them through setup.
  Widget buildSetupFlow(
    BuildContext context,
    List<Item> tasks,
    VoidCallback onComplete,
  );

  /// Dashboard view for this framework
  ///
  /// This is the main view when this framework is active.
  Widget buildDashboard(BuildContext context);

  /// Apply this framework's logic to tasks
  ///
  /// Called when framework is enabled. Can modify task metadata.
  Future<void> applyToTasks(List<Item> tasks);

  /// Remove this framework's metadata from tasks
  ///
  /// Called when framework is disabled. Should clean up any framework-specific fields.
  Future<void> removeFromTasks(List<Item> tasks);

  /// Settings panel for this framework (optional)
  Widget? buildSettingsPanel(BuildContext context) => null;

  /// Get framework-specific stats/insights (optional)
  Map<String, dynamic>? getInsights(List<Item> tasks) => null;
}
