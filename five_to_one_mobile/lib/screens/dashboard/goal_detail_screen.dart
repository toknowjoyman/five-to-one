import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/item.dart';
import 'package:uuid/uuid.dart';

class GoalDetailScreen extends StatefulWidget {
  final String goalTitle;
  final int goalIndex;

  const GoalDetailScreen({
    super.key,
    required this.goalTitle,
    required this.goalIndex,
  });

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final List<Item> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  final _uuid = const Uuid();

  void _addTask() {
    if (_taskController.text.trim().isEmpty) return;

    setState(() {
      _tasks.add(Item(
        id: _uuid.v4(),
        userId: 'local-user', // Placeholder for now
        parentId: 'goal-${widget.goalIndex}',
        title: _taskController.text.trim(),
        createdAt: DateTime.now(),
      ));
      _taskController.clear();
    });
  }

  void _toggleTaskComplete(int index) {
    setState(() {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(
        completedAt: task.isCompleted ? null : DateTime.now(),
      );
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _navigateToSubtasks(Item task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
          task: task,
          onTasksChanged: (updatedTask) {
            // Update the task in our list
            setState(() {
              final index = _tasks.indexWhere((t) => t.id == task.id);
              if (index != -1) {
                _tasks[index] = updatedTask;
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppTheme.accentOrange,
      AppTheme.primaryPurple,
      AppTheme.accentGold,
      AppTheme.primaryViolet,
      AppTheme.importantBlue,
    ];
    final goalColor = colors[widget.goalIndex % colors.length];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goalTitle),
        backgroundColor: goalColor.withOpacity(0.2),
      ),
      body: Column(
        children: [
          // Goal header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  goalColor.withOpacity(0.3),
                  AppTheme.darkBackground,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: goalColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${widget.goalIndex + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.goalTitle,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${_tasks.where((t) => t.isCompleted).length}/${_tasks.length} tasks completed',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.successGreen,
                  ),
                ),
              ],
            ),
          ),

          // Tasks list
          Expanded(
            child: _tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first task below',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Dismissible(
                        key: Key(task.id),
                        direction: DismissDirection.horizontal,
                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd) {
                            // Swiped right - complete
                            _toggleTaskComplete(index);
                          } else {
                            // Swiped left - delete
                            _deleteTask(index);
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
                        child: TaskCard(
                          task: task,
                          onTap: () => _navigateToSubtasks(task),
                          onToggleComplete: () => _toggleTaskComplete(index),
                        ),
                      );
                    },
                  ),
          ),

          // Add task input
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
                      backgroundColor: goalColor,
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}

class TaskCard extends StatelessWidget {
  final Item task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
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
          onTap: onToggleComplete,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? AppTheme.successGreen
                  : Colors.transparent,
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
        subtitle: task.children != null && task.children!.isNotEmpty
            ? Text(
                '${task.children!.length} subtasks',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                ),
              )
            : null,
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}

// Task detail screen for subtasks (fractal!)
class TaskDetailScreen extends StatefulWidget {
  final Item task;
  final Function(Item) onTasksChanged;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.onTasksChanged,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Item _task;
  final TextEditingController _subtaskController = TextEditingController();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _task = widget.task.copyWith(
      children: widget.task.children ?? [],
    );
  }

  void _addSubtask() {
    if (_subtaskController.text.trim().isEmpty) return;

    setState(() {
      final newSubtask = Item(
        id: _uuid.v4(),
        userId: 'local-user',
        parentId: _task.id,
        title: _subtaskController.text.trim(),
        createdAt: DateTime.now(),
      );

      _task = _task.copyWith(
        children: [...(_task.children ?? []), newSubtask],
      );
      _subtaskController.clear();
      widget.onTasksChanged(_task);
    });
  }

  void _toggleSubtaskComplete(int index) {
    setState(() {
      final subtask = _task.children![index];
      _task.children![index] = subtask.copyWith(
        completedAt: subtask.isCompleted ? null : DateTime.now(),
      );
      widget.onTasksChanged(_task);
    });
  }

  void _deleteSubtask(int index) {
    setState(() {
      _task.children!.removeAt(index);
      widget.onTasksChanged(_task);
    });
  }

  @override
  Widget build(BuildContext context) {
    final subtasks = _task.children ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_task.title),
      ),
      body: Column(
        children: [
          // Task header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground.withOpacity(0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _task.title,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${subtasks.where((t) => t.isCompleted).length}/${subtasks.length} subtasks completed',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.successGreen,
                  ),
                ),
              ],
            ),
          ),

          // Subtasks list
          Expanded(
            child: subtasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.checklist,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No subtasks yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Break this task down further',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: subtasks.length,
                    itemBuilder: (context, index) {
                      final subtask = subtasks[index];
                      return Dismissible(
                        key: Key(subtask.id),
                        direction: DismissDirection.horizontal,
                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd) {
                            _toggleSubtaskComplete(index);
                          } else {
                            _deleteSubtask(index);
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
                        child: TaskCard(
                          task: subtask,
                          onTap: () {
                            // Could go deeper if needed (infinite fractal!)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetailScreen(
                                  task: subtask,
                                  onTasksChanged: (updated) {
                                    setState(() {
                                      _task.children![index] = updated;
                                      widget.onTasksChanged(_task);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          onToggleComplete: () => _toggleSubtaskComplete(index),
                        ),
                      );
                    },
                  ),
          ),

          // Add subtask input
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      decoration: const InputDecoration(
                        hintText: 'Add a subtask...',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _addSubtask(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addSubtask,
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }
}
