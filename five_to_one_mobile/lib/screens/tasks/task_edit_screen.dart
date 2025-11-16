import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/item.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';

class TaskEditScreen extends StatefulWidget {
  final Item task;
  final Function(Item) onSave;

  const TaskEditScreen({
    super.key,
    required this.task,
    required this.onSave,
  });

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _tagController;

  List<String> _tags = [];
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  String? _reminder;
  bool _isUrgent = false;
  bool _isImportant = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _tagController = TextEditingController();

    _tags = List.from(widget.task.tags);
    _dueDate = widget.task.dueDate;
    _reminder = widget.task.reminder;
    _isUrgent = widget.task.isUrgent;
    _isImportant = widget.task.isImportant;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _dueTime = picked;
        // Combine date and time
        if (_dueDate != null) {
          _dueDate = DateTime(
            _dueDate!.year,
            _dueDate!.month,
            _dueDate!.day,
            picked.hour,
            picked.minute,
          );
        }
      });
    }
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task title cannot be empty'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
      return;
    }

    final updated = widget.task.copyWith(
      title: _titleController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      tags: _tags,
      dueDate: _dueDate,
      reminder: _reminder,
      isUrgent: _isUrgent,
      isImportant: _isImportant,
    );

    widget.onSave(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Save'),
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              hintText: 'Enter task title',
              prefixIcon: Icon(Icons.title),
            ),
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            autofocus: true,
            maxLines: 2,
          ),

          const SizedBox(height: 24),

          // Priority toggles
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Priority',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilterChip(
                          label: const Text('Urgent'),
                          selected: _isUrgent,
                          onSelected: (selected) {
                            setState(() => _isUrgent = selected);
                            themeProvider.triggerHaptic();
                          },
                          selectedColor: AppTheme.urgentRed.withOpacity(0.3),
                          avatar: Icon(
                            Icons.priority_high,
                            color: _isUrgent ? AppTheme.urgentRed : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilterChip(
                          label: const Text('Important'),
                          selected: _isImportant,
                          onSelected: (selected) {
                            setState(() => _isImportant = selected);
                            themeProvider.triggerHaptic();
                          },
                          selectedColor: AppTheme.importantBlue.withOpacity(0.3),
                          avatar: Icon(
                            Icons.star,
                            color: _isImportant ? AppTheme.importantBlue : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Due Date & Time
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Due Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _dueDate == null
                                ? 'Set Date'
                                : DateFormat('MMM dd, yyyy').format(_dueDate!),
                          ),
                          onPressed: _selectDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_dueDate != null) ...[
                        OutlinedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            _dueTime == null
                                ? 'Time'
                                : _dueTime!.format(context),
                          ),
                          onPressed: _selectTime,
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() {
                            _dueDate = null;
                            _dueTime = null;
                          }),
                        ),
                      ],
                    ],
                  ),
                  if (_dueDate != null) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      'Reminder',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('15 min'),
                          selected: _reminder == '15min',
                          onSelected: (selected) {
                            setState(() => _reminder = selected ? '15min' : null);
                          },
                        ),
                        ChoiceChip(
                          label: const Text('1 hour'),
                          selected: _reminder == '1hour',
                          onSelected: (selected) {
                            setState(() => _reminder = selected ? '1hour' : null);
                          },
                        ),
                        ChoiceChip(
                          label: const Text('1 day'),
                          selected: _reminder == '1day',
                          onSelected: (selected) {
                            setState(() => _reminder = selected ? '1day' : null);
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tags
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tags',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      labelText: 'Add Tag',
                      hintText: 'e.g., work, personal, urgent',
                      prefixIcon: const Icon(Icons.local_offer),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTag,
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _addTag(),
                  ),
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeTag(tag),
                          backgroundColor: AppTheme.primaryPurple.withOpacity(0.2),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Notes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: 'Add detailed notes, links, or references...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Save button
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Save Changes'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.successGreen,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
