import 'package:flutter/material.dart';
import '../models/item.dart';
import '../theme/app_theme.dart';

class TaskSearchFilter extends StatefulWidget {
  final List<Item> tasks;
  final Function(List<Item>) onFilterChanged;

  const TaskSearchFilter({
    super.key,
    required this.tasks,
    required this.onFilterChanged,
  });

  @override
  State<TaskSearchFilter> createState() => _TaskSearchFilterState();
}

class _TaskSearchFilterState extends State<TaskSearchFilter> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> _selectedTags = {};
  TaskFilter _filterType = TaskFilter.all;
  DateFilter _dateFilter = DateFilter.all;
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    List<Item> filtered = widget.tasks;

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(query) ||
            (task.notes?.toLowerCase().contains(query) ?? false) ||
            task.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    // Completion filter
    switch (_filterType) {
      case TaskFilter.active:
        filtered = filtered.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilter.completed:
        filtered = filtered.where((task) => task.isCompleted).toList();
        break;
      case TaskFilter.all:
        // No filter
        break;
    }

    // Date filter
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final weekFromNow = today.add(const Duration(days: 7));

    switch (_dateFilter) {
      case DateFilter.today:
        filtered = filtered.where((task) {
          if (task.dueDate == null) return false;
          final dueDay = DateTime(
            task.dueDate!.year,
            task.dueDate!.month,
            task.dueDate!.day,
          );
          return dueDay.isAtSameMomentAs(today);
        }).toList();
        break;
      case DateFilter.tomorrow:
        filtered = filtered.where((task) {
          if (task.dueDate == null) return false;
          final dueDay = DateTime(
            task.dueDate!.year,
            task.dueDate!.month,
            task.dueDate!.day,
          );
          return dueDay.isAtSameMomentAs(tomorrow);
        }).toList();
        break;
      case DateFilter.thisWeek:
        filtered = filtered.where((task) {
          if (task.dueDate == null) return false;
          return task.dueDate!.isBefore(weekFromNow) &&
              task.dueDate!.isAfter(today.subtract(const Duration(days: 1)));
        }).toList();
        break;
      case DateFilter.overdue:
        filtered = filtered.where((task) {
          if (task.dueDate == null) return false;
          return task.dueDate!.isBefore(today) && !task.isCompleted;
        }).toList();
        break;
      case DateFilter.all:
        // No filter
        break;
    }

    // Tag filter
    if (_selectedTags.isNotEmpty) {
      filtered = filtered.where((task) {
        return _selectedTags.every((tag) => task.tags.contains(tag));
      }).toList();
    }

    widget.onFilterChanged(filtered);
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
      _applyFilters();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedTags.clear();
      _filterType = TaskFilter.all;
      _dateFilter = DateFilter.all;
      _applyFilters();
    });
  }

  Set<String> _getAllTags() {
    final Set<String> allTags = {};
    for (final task in widget.tasks) {
      allTags.addAll(task.tags);
    }
    return allTags;
  }

  @override
  Widget build(BuildContext context) {
    final allTags = _getAllTags();
    final hasActiveFilters = _searchController.text.isNotEmpty ||
        _selectedTags.isNotEmpty ||
        _filterType != TaskFilter.all ||
        _dateFilter != DateFilter.all;

    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppTheme.cardBackground.withOpacity(0.5),
          child: Row(
            children: [
              // Search toggle button
              IconButton(
                icon: Icon(
                  _showSearchBar ? Icons.search_off : Icons.search,
                  color: _showSearchBar ? AppTheme.accentOrange : AppTheme.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _showSearchBar = !_showSearchBar;
                    if (!_showSearchBar) {
                      _searchController.clear();
                    }
                  });
                },
                tooltip: 'Search',
              ),

              // Filter chips
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Completion filter
                      ChoiceChip(
                        label: const Text('Active'),
                        selected: _filterType == TaskFilter.active,
                        onSelected: (selected) {
                          setState(() {
                            _filterType = selected ? TaskFilter.active : TaskFilter.all;
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Completed'),
                        selected: _filterType == TaskFilter.completed,
                        onSelected: (selected) {
                          setState(() {
                            _filterType = selected ? TaskFilter.completed : TaskFilter.all;
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(width: 8),

                      // Date filters
                      PopupMenuButton<DateFilter>(
                        child: Chip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_dateFilter.label),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, size: 18),
                            ],
                          ),
                          backgroundColor: _dateFilter != DateFilter.all
                              ? AppTheme.primaryPurple
                              : null,
                        ),
                        onSelected: (DateFilter filter) {
                          setState(() {
                            _dateFilter = filter;
                            _applyFilters();
                          });
                        },
                        itemBuilder: (context) => DateFilter.values.map((filter) {
                          return PopupMenuItem(
                            value: filter,
                            child: Text(filter.label),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // Clear filters
              if (hasActiveFilters)
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  color: AppTheme.urgentRed,
                  onPressed: _clearFilters,
                  tooltip: 'Clear filters',
                ),

              // Filter menu
              PopupMenuButton(
                icon: Icon(
                  Icons.filter_list,
                  color: hasActiveFilters ? AppTheme.accentOrange : AppTheme.textSecondary,
                ),
                tooltip: 'More filters',
                itemBuilder: (context) => [
                  if (allTags.isNotEmpty) ...[
                    const PopupMenuItem(
                      enabled: false,
                      child: Text('Filter by Tags', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...allTags.map((tag) {
                      return CheckedPopupMenuItem(
                        value: tag,
                        checked: _selectedTags.contains(tag),
                        child: Text(tag),
                        onTap: () => _toggleTag(tag),
                      );
                    }).toList(),
                  ] else [
                    const PopupMenuItem(
                      enabled: false,
                      child: Text('No tags available'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Search bar
        if (_showSearchBar)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.cardBackground,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks, notes, tags...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              autofocus: true,
            ),
          ),

        // Active filters display
        if (_selectedTags.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedTags.map((tag) {
                return Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _toggleTag(tag),
                  backgroundColor: AppTheme.primaryPurple.withOpacity(0.2),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

enum TaskFilter {
  all,
  active,
  completed;

  String get label {
    switch (this) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.active:
        return 'Active';
      case TaskFilter.completed:
        return 'Completed';
    }
  }
}

enum DateFilter {
  all,
  today,
  tomorrow,
  thisWeek,
  overdue;

  String get label {
    switch (this) {
      case DateFilter.all:
        return 'All Dates';
      case DateFilter.today:
        return 'Today';
      case DateFilter.tomorrow:
        return 'Tomorrow';
      case DateFilter.thisWeek:
        return 'This Week';
      case DateFilter.overdue:
        return 'Overdue';
    }
  }
}
