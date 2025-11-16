import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/item.dart';
import '../../services/items_service.dart';
import '../../services/supabase_service.dart';
import '../../frameworks/framework_registry.dart';
import '../../frameworks/task_framework.dart';
import '../../widgets/framework_picker.dart';
import 'package:uuid/uuid.dart';

/// Task detail screen with framework support
///
/// Shows a task's children/subtasks and allows applying frameworks
/// to organize them. This screen replaces the old GoalDetailScreen.
class TaskDetailScreen extends StatefulWidget {
  final Item task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _itemsService = ItemsService();
  final _taskController = TextEditingController();
  final _uuid = const Uuid();
  List<Item> _children = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final children = await _itemsService.getChildren(widget.task.id);
      setState(() {
        _children = children;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading children: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addTask() async {
    if (_taskController.text.trim().isEmpty) return;

    try {
      final newTask = Item(
        id: _uuid.v4(),
        userId: SupabaseService.userId,
        parentId: widget.task.id,
        title: _taskController.text.trim(),
        position: _children.length,
        createdAt: DateTime.now(),
      );

      final created = await _itemsService.createItem(newTask);

      setState(() {
        _children.add(created);
        _taskController.clear();
      });
    } catch (e) {
      print('Error creating task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating task: $e')),
      );
    }
  }

  Future<void> _toggleComplete(Item task) async {
    try {
      final updated = task.isCompleted
          ? await _itemsService.uncompleteItem(task.id)
          : await _itemsService.completeItem(task.id);

      setState(() {
        final index = _children.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _children[index] = updated;
        }
      });
    } catch (e) {
      print('Error toggling task: $e');
    }
  }

  Future<void> _deleteTask(Item task) async {
    try {
      await _itemsService.deleteItem(task.id);
      setState(() {
        _children.removeWhere((t) => t.id == task.id);
      });
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Future<void> _showEditTaskDialog(Item task) async {
    final controller = TextEditingController(text: task.title);
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              hintText: 'Enter task title',
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (result != null && result.isNotEmpty && result != task.title) {
        await _updateTask(task, result);
      }
    } finally {
      // Dispose controller after the frame completes to avoid disposal during animation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.dispose();
      });
    }
  }

  Future<void> _updateTask(Item task, String newTitle) async {
    try {
      final updated = task.copyWith(title: newTitle);
      await _itemsService.updateItem(updated);

      setState(() {
        final index = _children.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _children[index] = updated;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task: $e'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      final task = _children.removeAt(oldIndex);
      _children.insert(newIndex, task);
    });

    // Update positions in database
    final positionUpdates = <String, int>{};
    for (int i = 0; i < _children.length; i++) {
      positionUpdates[_children[i].id] = i;
    }

    try {
      await _itemsService.updatePositions(positionUpdates);
    } catch (e) {
      print('Error updating positions: $e');
      // Reload to restore correct order
      _loadChildren();
    }
  }

  Future<void> _confirmDeleteCurrentTask() async {
    final childrenCount = _children.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text(
          childrenCount > 0
              ? 'This will permanently delete "${widget.task.title}" and all $childrenCount subtasks. This action cannot be undone.'
              : 'This will permanently delete "${widget.task.title}". This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.urgentRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteCurrentTask();
    }
  }

  Future<void> _deleteCurrentTask() async {
    try {
      await _itemsService.deleteItem(widget.task.id);

      if (mounted) {
        // Navigate back after deletion
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting task: $e'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  Future<void> _showEditTitleDialog() async {
    final controller = TextEditingController(text: widget.task.title);
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              hintText: 'Enter task title',
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (result != null && result.isNotEmpty && result != widget.task.title) {
        await _updateTaskTitle(result);
      }
    } finally {
      // Dispose controller after the frame completes to avoid disposal during animation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.dispose();
      });
    }
  }

  Future<void> _updateTaskTitle(String newTitle) async {
    try {
      final updated = widget.task.copyWith(title: newTitle);
      await _itemsService.updateItem(updated);

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task: $e'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  void _navigateToSubtasks(Item task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    ).then((_) => _loadChildren()); // Refresh on return
  }

  void _showFrameworkPicker() {
    FrameworkPicker.show(
      context,
      widget.task,
      _children,
      (framework) {
        _applyFramework(framework);
      },
    );
  }

  Future<void> _applyFramework(TaskFramework framework) async {
    try {
      // Add framework to task
      await _itemsService.addFramework(widget.task.id, framework.id);

      // Show setup flow
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => framework.buildSetupFlow(
              context,
              widget.task,
              _children,
              () {
                // On complete, go back and reload
                Navigator.pop(context);
                _loadChildren();
                setState(() {});
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying framework: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
        actions: [
          // Framework button
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Apply Framework',
            onPressed: _showFrameworkPicker,
          ),
          // More options menu
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditTitleDialog();
              } else if (value == 'delete') {
                _confirmDeleteCurrentTask();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 12),
                    Text('Edit Title'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppTheme.urgentRed),
                    SizedBox(width: 12),
                    Text('Delete Task', style: TextStyle(color: AppTheme.urgentRed)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Framework badges (if any frameworks applied)
                if (widget.task.frameworkIds.isNotEmpty)
                  _buildFrameworkBadges(),

                // Content area
                Expanded(
                  child: _buildContent(),
                ),

                // Add task input
                _buildAddTaskInput(),
              ],
            ),
    );
  }

  Widget _buildFrameworkBadges() {
    final frameworks = FrameworkRegistry.getByIds(widget.task.frameworkIds);

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.cardBackground.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Frameworks:',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Row(
                children: [
                  // Change framework button
                  TextButton.icon(
                    onPressed: _showFrameworkPicker,
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('Change'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Remove framework button
                  TextButton.icon(
                    onPressed: () => _confirmRemoveFramework(frameworks.first),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Remove'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.urgentRed,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: frameworks.map((framework) {
              return Chip(
                avatar: Icon(
                  framework.icon,
                  size: 16,
                  color: framework.color,
                ),
                label: Text(framework.shortName),
                backgroundColor: framework.color.withOpacity(0.1),
                side: BorderSide(color: framework.color),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemoveFramework(TaskFramework framework) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Framework?'),
        content: Text(
          'This will remove ${framework.name} from this task. '
          'Framework-specific data will be cleared from all subtasks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.urgentRed),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _removeFramework(framework);
    }
  }

  Future<void> _removeFramework(TaskFramework framework) async {
    try {
      // Remove framework metadata from children
      await framework.removeFromTask(widget.task, _children);

      // Remove framework from task
      await _itemsService.removeFramework(widget.task.id, framework.id);

      // Reload
      await _loadChildren();
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${framework.name} removed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing framework: $e')),
        );
      }
    }
  }

  Widget _buildContent() {
    // If task has frameworks, show framework views
    if (widget.task.frameworkIds.isNotEmpty) {
      final framework = FrameworkRegistry.get(widget.task.frameworkIds.first);
      if (framework != null) {
        return framework.buildSubtaskView(context, widget.task);
      }
    }

    // Default: simple list view
    return _buildSimpleListView();
  }

  Widget _buildSimpleListView() {
    if (_children.isEmpty) {
      return _buildEmptyState();
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _children.length,
      onReorder: _handleReorder,
      itemBuilder: (context, index) {
        final task = _children[index];

        return Dismissible(
          key: Key(task.id),
          direction: DismissDirection.horizontal,
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Complete action - no confirmation needed
              return true;
            } else {
              // Delete action - show confirmation
              return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Task?'),
                  content: Text('This will permanently delete "${task.title}" and all its subtasks.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: AppTheme.urgentRed),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            }
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              _toggleComplete(task);
            } else {
              _deleteTask(task);
            }
          },
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: AppTheme.successGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 32,
            ),
          ),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppTheme.urgentRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 32,
            ),
          ),
          child: _buildTaskCard(task),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No subtasks yet',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 24,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add a subtask below to break down this task',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryPurple.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: AppTheme.accentOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tip',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentOrange,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Once you have 5+ subtasks, try applying a framework to organize them!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Item task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? AppTheme.cardBackground.withOpacity(0.5)
            : AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isCompleted
              ? AppTheme.successGreen.withOpacity(0.3)
              : AppTheme.primaryPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: () => _toggleComplete(task),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: task.isCompleted ? AppTheme.successGreen : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: task.isCompleted
                    ? AppTheme.successGreen
                    : AppTheme.textSecondary,
                width: 2,
              ),
            ),
            child: task.isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: task.isCompleted
                    ? AppTheme.textSecondary
                    : AppTheme.textPrimary,
              ),
        ),
        subtitle: task.frameworkIds.isNotEmpty ? _buildFrameworkBadge(task) : null,
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondary,
        ),
        onTap: () => _navigateToSubtasks(task),
        onLongPress: () => _showEditTaskDialog(task),
      ),
    );
  }

  Widget _buildFrameworkBadge(Item task) {
    final frameworks = FrameworkRegistry.getByIds(task.frameworkIds);
    if (frameworks.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: frameworks.map((framework) {
          return _buildFrameworkDetailBadge(framework, task);
        }).toList(),
      ),
    );
  }

  Widget _buildFrameworkDetailBadge(framework, Item task) {
    String detailText = framework.shortName;

    // Buffett-Munger 5/25 - show priority or avoided status
    if (framework.id == 'buffett_munger') {
      if (task.isAvoided) {
        detailText = 'Avoided';
      } else if (task.priority != null && task.priority! > 0) {
        detailText = 'Priority ${task.priority}';
      }
    }

    // Eisenhower Matrix - show urgency/importance status
    if (framework.id == 'eisenhower') {
      if (task.isUrgent && task.isImportant) {
        detailText = 'Urgent & Important';
      } else if (task.isUrgent) {
        detailText = 'Urgent';
      } else if (task.isImportant) {
        detailText = 'Important';
      } else {
        detailText = 'Neither';
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          framework.icon,
          size: 14,
          color: framework.color,
        ),
        const SizedBox(width: 4),
        Text(
          detailText,
          style: TextStyle(
            fontSize: 12,
            color: framework.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAddTaskInput() {
    return Container(
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
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  hintText: 'Add a subtask...',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _addTask(),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _addTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}
