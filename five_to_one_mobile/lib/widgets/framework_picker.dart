import 'package:flutter/material.dart';
import '../models/item.dart';
import '../frameworks/task_framework.dart';
import '../frameworks/framework_registry.dart';
import '../theme/app_theme.dart';

/// Framework picker bottom sheet
///
/// Allows users to select which framework(s) to apply to a task's children.
/// Shows applicable frameworks and reasons why others can't be applied.
class FrameworkPicker extends StatefulWidget {
  final Item task;
  final List<Item> children;
  final Function(TaskFramework) onFrameworkSelected;

  const FrameworkPicker({
    super.key,
    required this.task,
    required this.children,
    required this.onFrameworkSelected,
  });

  /// Show the framework picker as a bottom sheet
  static Future<void> show(
    BuildContext context,
    Item task,
    List<Item> children,
    Function(TaskFramework) onFrameworkSelected,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControllerAttached: true,
      builder: (context) => FrameworkPicker(
        task: task,
        children: children,
        onFrameworkSelected: onFrameworkSelected,
      ),
    );
  }

  @override
  State<FrameworkPicker> createState() => _FrameworkPickerState();
}

class _FrameworkPickerState extends State<FrameworkPicker> {
  String? _selectedFrameworkId;

  @override
  void initState() {
    super.initState();
    // Pre-select first applicable framework
    final applicable = FrameworkRegistry.getApplicable(widget.task, widget.children);
    if (applicable.isNotEmpty) {
      _selectedFrameworkId = applicable.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allFrameworks = FrameworkRegistry.getAll();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Organize Subtasks',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a framework to organize "${widget.task.title}"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 24),

          // Framework options
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                // None option (simple list)
                _buildFrameworkOption(
                  id: null,
                  name: 'None (Simple List)',
                  description: 'Default view - no framework',
                  icon: Icons.list,
                  color: AppTheme.textSecondary,
                  canApply: true,
                  requirementMessage: null,
                ),

                const SizedBox(height: 12),

                // All registered frameworks
                ...allFrameworks.map((framework) {
                  final canApply = framework.canApplyToTask(widget.task, widget.children);
                  final requirementMessage = framework.getRequirementMessage(widget.task, widget.children);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildFrameworkOption(
                      id: framework.id,
                      name: framework.name,
                      description: framework.description,
                      icon: framework.icon,
                      color: framework.color,
                      canApply: canApply,
                      requirementMessage: requirementMessage,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Apply button
          ElevatedButton(
            onPressed: _selectedFrameworkId != null || _selectedFrameworkId == null
                ? _applyFramework
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _selectedFrameworkId == null ? 'Use Simple List' : 'Apply Framework',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFrameworkOption({
    required String? id,
    required String name,
    required String description,
    required IconData icon,
    required Color color,
    required bool canApply,
    required String? requirementMessage,
  }) {
    final isSelected = _selectedFrameworkId == id;
    final isDisabled = !canApply;

    return GestureDetector(
      onTap: canApply
          ? () {
              setState(() {
                _selectedFrameworkId = id;
              });
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppTheme.cardBackground.withOpacity(0.5)
              : isSelected
                  ? color.withOpacity(0.1)
                  : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled
                ? AppTheme.textSecondary.withOpacity(0.3)
                : isSelected
                    ? color
                    : AppTheme.primaryPurple.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDisabled
                      ? AppTheme.textSecondary.withOpacity(0.5)
                      : isSelected
                          ? color
                          : AppTheme.textSecondary,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(isDisabled ? 0.2 : 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDisabled ? AppTheme.textSecondary : color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDisabled
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  if (!canApply && requirementMessage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.urgentRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        requirementMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.urgentRed,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFramework() {
    if (_selectedFrameworkId == null) {
      // User chose "None" - just close
      Navigator.pop(context);
      return;
    }

    final framework = FrameworkRegistry.get(_selectedFrameworkId);
    if (framework != null) {
      Navigator.pop(context);
      widget.onFrameworkSelected(framework);
    }
  }
}
