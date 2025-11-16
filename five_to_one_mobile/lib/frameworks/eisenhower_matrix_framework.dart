import 'package:flutter/material.dart';
import 'task_framework.dart';
import '../models/item.dart';
import '../services/items_service.dart';
import '../theme/app_theme.dart';

/// Eisenhower Matrix Framework
///
/// Organize tasks by Urgent vs Important in a 2x2 matrix.
/// Quadrants:
/// 1. Urgent & Important (Do First)
/// 2. Not Urgent & Important (Schedule)
/// 3. Urgent & Not Important (Delegate)
/// 4. Neither (Eliminate)
class EisenhowerMatrixFramework extends TaskFramework {
  final _itemsService = ItemsService();

  @override
  String get id => 'eisenhower';

  @override
  String get name => 'Eisenhower Matrix';

  @override
  String get shortName => 'Eisenhower';

  @override
  String get description => 'Urgent vs Important triage';

  @override
  IconData get icon => Icons.grid_view;

  @override
  Color get color => AppTheme.importantBlue;

  @override
  bool canApplyToTask(Item task, List<Item> children) {
    // Can apply to any task with children
    return children.where((c) => !c.isCompleted).isNotEmpty;
  }

  @override
  String? getRequirementMessage(Item task, List<Item> children) {
    final incompleteCount = children.where((c) => !c.isCompleted).length;
    if (incompleteCount == 0) {
      return 'Requires at least 1 subtask';
    }
    return null;
  }

  @override
  Widget buildSetupFlow(
    BuildContext context,
    Item task,
    List<Item> children,
    VoidCallback onComplete,
  ) {
    return _EisenhowerSetupFlow(
      task: task,
      children: children,
      onComplete: onComplete,
    );
  }

  @override
  Widget buildSubtaskView(BuildContext context, Item task) {
    return _EisenhowerMatrixView(task: task);
  }

  @override
  Widget buildQuickInfo(BuildContext context, Item task) {
    return FutureBuilder<List<Item>>(
      future: _itemsService.getChildren(task.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final children = snapshot.data!;
        final urgentCount = children.where((c) => c.isUrgent && !c.isCompleted).length;

        return Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              '$shortName · $urgentCount urgent',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Future<void> applyToTask(Item task, List<Item> children) async {
    // Framework will be applied through setup flow
  }

  @override
  Future<void> removeFromTask(Item task, List<Item> children) async {
    // Clear urgent and important flags from all children
    final updates = children.map((child) {
      return child.copyWith(
        isUrgent: false,
        isImportant: false,
      );
    }).toList();

    await _itemsService.updateItems(updates);
  }

  @override
  List<Item> filterForPriority(List<Item> items) {
    // Return urgent tasks
    return items.where((item) => item.isUrgent).toList();
  }

  @override
  Map<String, dynamic>? getInsights(Item task, List<Item> children) {
    final urgent = children.where((c) => c.isUrgent).length;
    final important = children.where((c) => c.isImportant).length;
    final urgentAndImportant = children.where((c) => c.isUrgent && c.isImportant).length;

    return {
      'urgent_count': urgent,
      'important_count': important,
      'urgent_and_important_count': urgentAndImportant,
      'total_count': children.length,
    };
  }
}

/// Setup flow for Eisenhower Matrix
class _EisenhowerSetupFlow extends StatefulWidget {
  final Item task;
  final List<Item> children;
  final VoidCallback onComplete;

  const _EisenhowerSetupFlow({
    required this.task,
    required this.children,
    required this.onComplete,
  });

  @override
  State<_EisenhowerSetupFlow> createState() => _EisenhowerSetupFlowState();
}

class _EisenhowerSetupFlowState extends State<_EisenhowerSetupFlow> {
  late Map<String, bool> _urgentFlags;
  late Map<String, bool> _importantFlags;
  final _itemsService = ItemsService();
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _urgentFlags = {
      for (var child in widget.children) child.id: child.isUrgent
    };
    _importantFlags = {
      for (var child in widget.children) child.id: child.isImportant
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag Tasks'),
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(24),
            color: AppTheme.cardBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mark tasks as Urgent and/or Important',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap tags to toggle. Tasks will be organized in a 2×2 matrix.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),

          // Task list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.children.where((c) => !c.isCompleted).length,
              itemBuilder: (context, index) {
                final child = widget.children.where((c) => !c.isCompleted).toList()[index];
                final isUrgent = _urgentFlags[child.id] ?? false;
                final isImportant = _importantFlags[child.id] ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        child.title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),

                      // Tags
                      Row(
                        children: [
                          // Urgent tag
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _urgentFlags[child.id] = !isUrgent;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isUrgent
                                    ? AppTheme.urgentRed
                                    : AppTheme.urgentRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.urgentRed,
                                  width: isUrgent ? 0 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isUrgent ? Icons.check_circle : Icons.radio_button_unchecked,
                                    size: 16,
                                    color: isUrgent ? Colors.white : AppTheme.urgentRed,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Urgent',
                                    style: TextStyle(
                                      color: isUrgent ? Colors.white : AppTheme.urgentRed,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Important tag
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _importantFlags[child.id] = !isImportant;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isImportant
                                    ? AppTheme.importantBlue
                                    : AppTheme.importantBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.importantBlue,
                                  width: isImportant ? 0 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isImportant ? Icons.check_circle : Icons.radio_button_unchecked,
                                    size: 16,
                                    color: isImportant ? Colors.white : AppTheme.importantBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Important',
                                    style: TextStyle(
                                      color: isImportant ? Colors.white : AppTheme.importantBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Apply button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _isApplying ? null : _applyTags,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.importantBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isApplying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Apply Matrix',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyTags() async {
    setState(() => _isApplying = true);

    try {
      final updates = widget.children.map((child) {
        return child.copyWith(
          isUrgent: _urgentFlags[child.id] ?? false,
          isImportant: _importantFlags[child.id] ?? false,
        );
      }).toList();

      await _itemsService.updateItems(updates);

      if (mounted) {
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying tags: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }
}

/// Main view for Eisenhower Matrix
class _EisenhowerMatrixView extends StatefulWidget {
  final Item task;

  const _EisenhowerMatrixView({required this.task});

  @override
  State<_EisenhowerMatrixView> createState() => _EisenhowerMatrixViewState();
}

class _EisenhowerMatrixViewState extends State<_EisenhowerMatrixView> {
  final _itemsService = ItemsService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Item>>(
      future: _itemsService.getChildren(widget.task.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final children = snapshot.data!.where((c) => !c.isCompleted).toList();
        final urgentImportant = children.where((c) => c.isUrgent && c.isImportant).toList();
        final notUrgentImportant = children.where((c) => !c.isUrgent && c.isImportant).toList();
        final urgentNotImportant = children.where((c) => c.isUrgent && !c.isImportant).toList();
        final neither = children.where((c) => !c.isUrgent && !c.isImportant).toList();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top row
              Expanded(
                child: Row(
                  children: [
                    // Urgent & Important
                    Expanded(
                      child: _buildQuadrant(
                        title: 'Do First',
                        subtitle: 'Urgent & Important',
                        color: AppTheme.urgentRed,
                        tasks: urgentImportant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Not Urgent & Important
                    Expanded(
                      child: _buildQuadrant(
                        title: 'Schedule',
                        subtitle: 'Not Urgent & Important',
                        color: AppTheme.importantBlue,
                        tasks: notUrgentImportant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Bottom row
              Expanded(
                child: Row(
                  children: [
                    // Urgent & Not Important
                    Expanded(
                      child: _buildQuadrant(
                        title: 'Delegate',
                        subtitle: 'Urgent & Not Important',
                        color: AppTheme.accentOrange,
                        tasks: urgentNotImportant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Neither
                    Expanded(
                      child: _buildQuadrant(
                        title: 'Eliminate',
                        subtitle: 'Neither',
                        color: AppTheme.textSecondary,
                        tasks: neither,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuadrant({
    required String title,
    required String subtitle,
    required Color color,
    required List<Item> tasks,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '${tasks.length}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Task list
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Text(
                      'No tasks',
                      style: TextStyle(
                        color: AppTheme.textSecondary.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${task.title}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
