import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/item.dart';
import '../../services/items_service.dart';
import '../../services/supabase_service.dart';
import '../../frameworks/framework_registry.dart';
import 'task_detail_screen.dart';
import 'package:uuid/uuid.dart';

/// Simple task list - the default view with no frameworks enabled
///
/// Shows all root tasks in a clean list.
/// Users can add tasks, drill into subtasks, complete items.
class SimpleTaskList extends StatefulWidget {
  const SimpleTaskList({super.key});

  @override
  State<SimpleTaskList> createState() => _SimpleTaskListState();
}

class _SimpleTaskListState extends State<SimpleTaskList> {
  final _itemsService = ItemsService();
  final _taskController = TextEditingController();
  final _uuid = const Uuid();
  List<Item> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _itemsService.getRootItems();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading tasks: $e');
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
        parentId: null, // Root task
        title: _taskController.text.trim(),
        position: _tasks.length,
        createdAt: DateTime.now(),
      );

      final created = await _itemsService.createItem(newTask);

      setState(() {
        _tasks.add(created);
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
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = updated;
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
        _tasks.removeWhere((t) => t.id == task.id);
      });
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  void _openTaskDetail(Item task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    ).then((_) => _loadTasks()); // Refresh on return
  }

  void _showRootFrameworkPicker() {
    // Create a virtual root item to represent the collection
    final virtualRoot = Item(
      id: 'root',
      userId: SupabaseService.userId,
      parentId: null,
      title: 'My Tasks',
      createdAt: DateTime.now(),
    );

    FrameworkPicker.show(
      context,
      virtualRoot,
      _tasks,
      (framework) {
        _showFrameworkSetupForRoot(framework);
      },
    );
  }

  void _showFrameworkSetupForRoot(framework) {
    final virtualRoot = Item(
      id: 'root',
      userId: SupabaseService.userId,
      parentId: null,
      title: 'My Tasks',
      createdAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => framework.buildSetupFlow(
          context,
          virtualRoot,
          _tasks,
          () {
            Navigator.pop(context);
            _loadTasks();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          // Apply framework to root tasks
          if (_tasks.length >= 5)
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Organize with Framework',
              onPressed: _showRootFrameworkPicker,
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Empty state or task list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? _buildEmptyState()
                    : _buildTaskList(),
          ),

          // Add task input
          _buildAddTaskInput(),
        ],
      ),
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
              'No tasks yet',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 24,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first task below to get started',
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
                    'Every task can have subtasks. Break big goals into smaller, actionable steps.',
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

  Widget _buildTaskList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];

        return Dismissible(
          key: Key(task.id),
          direction: DismissDirection.horizontal,
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
        onTap: () => _openTaskDetail(task),
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
                framework.shortName,
                style: TextStyle(
                  fontSize: 12,
                  color: framework.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }).toList(),
      ),
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
                  hintText: 'Add a task...',
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
