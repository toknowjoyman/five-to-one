import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/feedback.dart' as app_feedback;
import '../../services/feedback_service.dart';

/// Admin screen to view and manage all feedback
class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('MMM d, y h:mm a');
  bool _isLoading = true;
  bool _isAdmin = false;
  List<app_feedback.Feedback> _feedbackList = [];
  Map<String, dynamic>? _stats;
  String? _error;

  app_feedback.FeedbackStatus? _filterStatus;
  app_feedback.FeedbackCategory? _filterCategory;
  app_feedback.FeedbackPriority? _filterPriority;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkAdminAndLoadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminAndLoadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final isAdmin = await FeedbackService.isAdmin();
      if (!isAdmin) {
        setState(() {
          _isAdmin = false;
          _isLoading = false;
          _error = 'You do not have admin permissions';
        });
        return;
      }

      setState(() {
        _isAdmin = true;
      });

      await _loadData();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final futures = await Future.wait([
        FeedbackService.getAllFeedback(
          status: _filterStatus,
          category: _filterCategory,
          priority: _filterPriority,
        ),
        FeedbackService.getFeedbackStats(),
      ]);

      setState(() {
        _feedbackList = futures[0] as List<app_feedback.Feedback>;
        _stats = futures[1] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateFeedback(
    String feedbackId, {
    app_feedback.FeedbackStatus? status,
    app_feedback.FeedbackPriority? priority,
    String? adminNotes,
  }) async {
    try {
      await FeedbackService.updateFeedback(
        feedbackId: feedbackId,
        status: status,
        priority: priority,
        adminNotes: adminNotes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating feedback: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin && !_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Feedback'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Access Denied',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Feedback Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Feedback', icon: Icon(Icons.list)),
            Tab(text: 'Statistics', icon: Icon(Icons.bar_chart)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFeedbackList(),
                _buildStatistics(),
              ],
            ),
    );
  }

  Widget _buildFeedbackList() {
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Expanded(
                child: _buildFilterDropdown<app_feedback.FeedbackStatus>(
                  label: 'Status',
                  value: _filterStatus,
                  items: app_feedback.FeedbackStatus.values,
                  itemLabel: (status) => status.displayName,
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value;
                    });
                    _loadData();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown<app_feedback.FeedbackCategory>(
                  label: 'Category',
                  value: _filterCategory,
                  items: app_feedback.FeedbackCategory.values,
                  itemLabel: (category) => category.displayName,
                  onChanged: (value) {
                    setState(() {
                      _filterCategory = value;
                    });
                    _loadData();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown<app_feedback.FeedbackPriority>(
                  label: 'Priority',
                  value: _filterPriority,
                  items: app_feedback.FeedbackPriority.values,
                  itemLabel: (priority) => priority.displayName,
                  onChanged: (value) {
                    setState(() {
                      _filterPriority = value;
                    });
                    _loadData();
                  },
                ),
              ),
            ],
          ),
        ),

        // Feedback list
        Expanded(
          child: _feedbackList.isEmpty
              ? const Center(
                  child: Text('No feedback found'),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    itemCount: _feedbackList.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final feedback = _feedbackList[index];
                      return _AdminFeedbackCard(
                        feedback: feedback,
                        dateFormat: _dateFormat,
                        onUpdate: _updateFeedback,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      value: value,
      items: [
        const DropdownMenuItem(value: null, child: Text('All')),
        ...items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(itemLabel(item)),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildStatistics() {
    if (_stats == null) {
      return const Center(child: Text('No statistics available'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatCard(
              title: 'Total Feedback',
              value: _stats!['total_feedback']?.toString() ?? '0',
              icon: Icons.feedback,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'New',
                    value: _stats!['new_count']?.toString() ?? '0',
                    icon: Icons.fiber_new,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'In Progress',
                    value: _stats!['in_progress_count']?.toString() ?? '0',
                    icon: Icons.pending,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Completed',
                    value: _stats!['completed_count']?.toString() ?? '0',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Critical',
                    value: _stats!['critical_count']?.toString() ?? '0',
                    icon: Icons.priority_high,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'By Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _StatCard(
              title: 'Bug Reports',
              value: _stats!['bug_count']?.toString() ?? '0',
              icon: Icons.bug_report,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            _StatCard(
              title: 'Feature Requests',
              value: _stats!['feature_count']?.toString() ?? '0',
              icon: Icons.lightbulb,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            _StatCard(
              title: 'Improvements',
              value: _stats!['improvement_count']?.toString() ?? '0',
              icon: Icons.trending_up,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminFeedbackCard extends StatelessWidget {
  final app_feedback.Feedback feedback;
  final DateFormat dateFormat;
  final Function(String, {app_feedback.FeedbackStatus? status, app_feedback.FeedbackPriority? priority, String? adminNotes}) onUpdate;

  const _AdminFeedbackCard({
    required this.feedback,
    required this.dateFormat,
    required this.onUpdate,
  });

  void _showUpdateDialog(BuildContext context) {
    final notesController = TextEditingController(text: feedback.adminNotes);
    var selectedStatus = feedback.status;
    var selectedPriority = feedback.priority;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Feedback'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<app_feedback.FeedbackStatus>(
                  decoration: const InputDecoration(labelText: 'Status'),
                  value: selectedStatus,
                  items: app_feedback.FeedbackStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<app_feedback.FeedbackPriority>(
                  decoration: const InputDecoration(labelText: 'Priority'),
                  value: selectedPriority,
                  items: app_feedback.FeedbackPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedPriority = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Admin Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                onUpdate(
                  feedback.id,
                  status: selectedStatus,
                  priority: selectedPriority,
                  adminNotes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                );
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showUpdateDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(feedback.category.displayName),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(feedback.status.displayName),
                    backgroundColor: _getStatusColor().withOpacity(0.1),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(feedback.priority.displayName),
                    backgroundColor: _getPriorityColor().withOpacity(0.1),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                feedback.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(feedback.description),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(feedback.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (feedback.email != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.email, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      feedback.email!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
              if (feedback.adminNotes != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Notes: ${feedback.adminNotes}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (feedback.status) {
      case app_feedback.FeedbackStatus.newFeedback:
        return Colors.blue;
      case app_feedback.FeedbackStatus.inProgress:
        return Colors.orange;
      case app_feedback.FeedbackStatus.completed:
        return Colors.green;
      case app_feedback.FeedbackStatus.archived:
        return Colors.grey;
    }
  }

  Color _getPriorityColor() {
    switch (feedback.priority) {
      case app_feedback.FeedbackPriority.low:
        return Colors.grey;
      case app_feedback.FeedbackPriority.medium:
        return Colors.blue;
      case app_feedback.FeedbackPriority.high:
        return Colors.orange;
      case app_feedback.FeedbackPriority.critical:
        return Colors.red;
    }
  }
}
