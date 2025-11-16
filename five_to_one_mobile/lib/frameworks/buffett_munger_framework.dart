import 'package:flutter/material.dart';
import 'task_framework.dart';
import '../models/item.dart';
import '../services/items_service.dart';
import '../widgets/pentagon_wheel.dart';
import '../theme/app_theme.dart';
import '../screens/dashboard/task_detail_screen.dart';

/// Buffett-Munger 5/25 Framework
///
/// Warren Buffett's prioritization method: Pick your top 5 priorities
/// and avoid the other 20 until the top 5 are done.
class BuffettMungerFramework extends TaskFramework {
  final _itemsService = ItemsService();

  @override
  String get id => 'buffett-munger';

  @override
  String get name => 'Buffett-Munger 5/25';

  @override
  String get shortName => 'BM 5/25';

  @override
  String get description => 'Focus on your top 5, avoid the rest';

  @override
  IconData get icon => Icons.filter_5;

  @override
  Color get color => AppTheme.primaryPurple;

  @override
  bool canApplyToTask(Item task, List<Item> children) {
    // Need at least 5 children to prioritize
    return children.where((c) => !c.isCompleted).length >= 5;
  }

  @override
  String? getRequirementMessage(Item task, List<Item> children) {
    final incompleteCount = children.where((c) => !c.isCompleted).length;
    if (incompleteCount < 5) {
      return 'Requires at least 5 subtasks (you have $incompleteCount)';
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
    // TODO: Build prioritization flow
    // For now, return a simple placeholder
    return _BuffettMungerSetupFlow(
      task: task,
      children: children,
      onComplete: onComplete,
    );
  }

  @override
  Widget buildSubtaskView(BuildContext context, Item task) {
    return _BuffettMungerView(task: task);
  }

  @override
  Widget buildQuickInfo(BuildContext context, Item task) {
    // TODO: Load children and calculate completion
    return FutureBuilder<List<Item>>(
      future: _itemsService.getChildren(task.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final children = snapshot.data!;
        final topFive = children.where((c) => c.priority != null && c.priority! <= 5).toList();
        final completed = topFive.where((c) => c.isCompleted).length;

        return Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              '$shortName · $completed/${topFive.length} done',
              style: TextStyle(
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
    // This is called after setup is complete
  }

  @override
  Future<void> removeFromTask(Item task, List<Item> children) async {
    // Clear priority and isAvoided from all children
    final updates = children.map((child) {
      return child.copyWith(
        priority: null,
        isAvoided: false,
      );
    }).toList();

    await _itemsService.updateItems(updates);
  }

  @override
  List<Item> filterForPriority(List<Item> items) {
    // Return top 5 priorities
    return items
        .where((item) => item.priority != null && item.priority! <= 5)
        .toList()
      ..sort((a, b) => a.priority!.compareTo(b.priority!));
  }

  @override
  Map<String, dynamic>? getInsights(Item task, List<Item> children) {
    final topFive = children.where((c) => c.priority != null && c.priority! <= 5).toList();
    final completed = topFive.where((c) => c.isCompleted).length;
    final avoidList = children.where((c) => c.isAvoided).toList();

    return {
      'total_priorities': topFive.length,
      'completed_priorities': completed,
      'completion_rate': topFive.isEmpty ? 0.0 : completed / topFive.length,
      'avoid_list_count': avoidList.length,
    };
  }
}

/// Setup flow for Buffett-Munger framework
class _BuffettMungerSetupFlow extends StatefulWidget {
  final Item task;
  final List<Item> children;
  final VoidCallback onComplete;

  const _BuffettMungerSetupFlow({
    required this.task,
    required this.children,
    required this.onComplete,
  });

  @override
  State<_BuffettMungerSetupFlow> createState() => _BuffettMungerSetupFlowState();
}

class _BuffettMungerSetupFlowState extends State<_BuffettMungerSetupFlow> {
  late List<Item> _rankedChildren;
  final _itemsService = ItemsService();
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    // Start with current order
    _rankedChildren = [...widget.children.where((c) => !c.isCompleted)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prioritize Your Top 5'),
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
                  'Drag to rank your priorities',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your top 5 will be your focus. The rest will be avoided until these are complete.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),

          // Reorderable list
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _rankedChildren.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _rankedChildren.removeAt(oldIndex);
                  _rankedChildren.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final child = _rankedChildren[index];
                final isTopFive = index < 5;

                return Container(
                  key: Key(child.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isTopFive
                        ? AppTheme.primaryPurple.withOpacity(0.1)
                        : AppTheme.cardBackground.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTopFive
                          ? AppTheme.primaryPurple
                          : AppTheme.textSecondary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Rank number
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isTopFive
                              ? AppTheme.primaryPurple
                              : AppTheme.textSecondary.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Title
                      Expanded(
                        child: Text(
                          child.title,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),

                      // Drag handle
                      const Icon(
                        Icons.drag_handle,
                        color: AppTheme.textSecondary,
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
                onPressed: _isApplying ? null : _applyPrioritization,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
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
                        'Lock In Top 5',
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

  Future<void> _applyPrioritization() async {
    setState(() => _isApplying = true);

    try {
      // Update priorities
      final updates = _rankedChildren.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        return child.copyWith(
          priority: index < 5 ? index + 1 : null,
          isAvoided: index >= 5,
          position: index,
        );
      }).toList();

      await _itemsService.updateItems(updates);

      if (mounted) {
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying prioritization: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }
}

/// Main view for Buffett-Munger framework
class _BuffettMungerView extends StatefulWidget {
  final Item task;

  const _BuffettMungerView({required this.task});

  @override
  State<_BuffettMungerView> createState() => _BuffettMungerViewState();
}

class _BuffettMungerViewState extends State<_BuffettMungerView> {
  final _itemsService = ItemsService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Item>>(
      future: _itemsService.getChildren(widget.task.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final children = snapshot.data!;
        final topFive = children
            .where((c) => c.priority != null && c.priority! <= 5)
            .toList()
          ..sort((a, b) => a.priority!.compareTo(b.priority!));
        final avoidList = children.where((c) => c.isAvoided).toList();

        return Column(
          children: [
            // Pentagon wheel for top 5
            if (topFive.isNotEmpty) ...[
              const SizedBox(height: 24),
              PentagonWheel(
                goals: topFive,
                onGoalTap: (goal) => _navigateToSubtasks(context, goal),
              ),
              const SizedBox(height: 24),
            ],

            // Avoid list button
            if (avoidList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () => _showAvoidList(context, avoidList),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cardBackground,
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppTheme.textSecondary.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline),
                      const SizedBox(width: 8),
                      Text('Avoid List (${avoidList.length})'),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _navigateToSubtasks(BuildContext context, Item task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );
  }

  void _showAvoidList(BuildContext context, List<Item> avoidList) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Avoid List',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'These tasks are deprioritized until your top 5 are complete.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: avoidList.length,
                itemBuilder: (context, index) {
                  final item = avoidList[index];
                  return ListTile(
                    leading: const Icon(Icons.block, color: AppTheme.textSecondary),
                    title: Text(
                      item.title,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppTheme.textSecondary,
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close the bottom sheet
                      _navigateToSubtasks(context, item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
