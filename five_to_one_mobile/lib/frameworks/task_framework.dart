import 'package:flutter/material.dart';
import '../models/item.dart';

/// Base interface for all task management frameworks
///
/// A framework is a system for organizing a task's children/subtasks.
/// Frameworks can be applied per-task, not globally.
/// Examples: Buffett-Munger 5/25, Eisenhower Matrix, Time Blocking, etc.
abstract class TaskFramework {
  // ============================================
  // Identity
  // ============================================

  /// Unique identifier for this framework
  String get id;

  /// Display name
  String get name;

  /// Short name for compact UI
  String get shortName;

  /// Short description
  String get description;

  /// Icon to represent this framework
  IconData get icon;

  /// Color theme for this framework
  Color get color;

  // ============================================
  // Applicability
  // ============================================

  /// Can this framework be applied to organize this task's children?
  ///
  /// For example, Buffett-Munger needs at least 5 children.
  /// Returns true if applicable, false if not.
  bool canApplyToTask(Item task, List<Item> children);

  /// Why can't this framework be applied? (shown if canApply returns false)
  String? getRequirementMessage(Item task, List<Item> children);

  // ============================================
  // Setup & Views
  // ============================================

  /// Setup/onboarding flow for this framework
  ///
  /// This is shown when a user first applies the framework to a task.
  /// Should guide them through organizing children with this framework.
  Widget buildSetupFlow(
    BuildContext context,
    Item task,
    List<Item> children,
    VoidCallback onComplete,
  );

  /// Build the subtask view for this task
  ///
  /// This renders the children according to the framework's organization.
  /// For example, Buffett-Munger shows pentagon wheel + avoid list.
  Widget buildSubtaskView(BuildContext context, Item task);

  /// Build quick info badge for task card
  ///
  /// Shows a compact summary of this task's framework status.
  /// For example: "BM 5/25 · 3/5 done" or "Eisenhower · 2 urgent"
  Widget buildQuickInfo(BuildContext context, Item task);

  // ============================================
  // Actions
  // ============================================

  /// Apply this framework's logic to a task's children
  ///
  /// Called when framework is enabled. Can modify child metadata.
  /// For example, Buffett-Munger sets priority on top 5 children.
  Future<void> applyToTask(Item task, List<Item> children);

  /// Remove this framework's metadata from task's children
  ///
  /// Called when framework is removed. Should clean up framework-specific fields.
  Future<void> removeFromTask(Item task, List<Item> children);

  // ============================================
  // Smart Features
  // ============================================

  /// Filter items for priority (used in hybrid views)
  ///
  /// Returns children that are considered "priority" by this framework.
  /// For example, Buffett-Munger returns top 5, Eisenhower returns urgent.
  List<Item> filterForPriority(List<Item> items);

  /// Get framework-specific stats/insights (optional)
  Map<String, dynamic>? getInsights(Item task, List<Item> children) => null;

  /// Settings panel for this framework (optional)
  Widget? buildSettingsPanel(BuildContext context) => null;
}
