import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/feedback.dart' as app_feedback;
import '../../services/feedback_service.dart';
import '../../widgets/feedback_dialog.dart';

/// Screen to view user's feedback history
class MyFeedbackScreen extends StatefulWidget {
  const MyFeedbackScreen({super.key});

  @override
  State<MyFeedbackScreen> createState() => _MyFeedbackScreenState();
}

class _MyFeedbackScreenState extends State<MyFeedbackScreen> {
  final DateFormat _dateFormat = DateFormat('MMM d, y');
  bool _isLoading = true;
  List<app_feedback.Feedback> _feedbackList = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final feedback = await FeedbackService.getUserFeedback();
      setState(() {
        _feedbackList = feedback;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Feedback'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadFeedback,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _feedbackList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.feedback_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No feedback yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Share your thoughts to help us improve!',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await FeedbackDialog.show(context);
                              _loadFeedback();
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Send Feedback'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFeedback,
                      child: ListView.builder(
                        itemCount: _feedbackList.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final feedback = _feedbackList[index];
                          return _FeedbackCard(
                            feedback: feedback,
                            dateFormat: _dateFormat,
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await FeedbackDialog.show(context);
          _loadFeedback();
        },
        icon: const Icon(Icons.feedback),
        label: const Text('New Feedback'),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final app_feedback.Feedback feedback;
  final DateFormat dateFormat;

  const _FeedbackCard({
    required this.feedback,
    required this.dateFormat,
  });

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

  IconData _getCategoryIcon() {
    switch (feedback.category) {
      case app_feedback.FeedbackCategory.bug:
        return Icons.bug_report;
      case app_feedback.FeedbackCategory.feature:
        return Icons.lightbulb;
      case app_feedback.FeedbackCategory.improvement:
        return Icons.trending_up;
      case app_feedback.FeedbackCategory.other:
        return Icons.comment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with category and status
            Row(
              children: [
                Icon(
                  _getCategoryIcon(),
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  feedback.category.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    feedback.status.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              feedback.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Description (truncated)
            Text(
              feedback.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),

            // Footer with date and priority
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(feedback.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (feedback.priority != app_feedback.FeedbackPriority.medium) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.flag, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    feedback.priority.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),

            // Admin notes (if any)
            if (feedback.adminNotes != null &&
                feedback.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin Response',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feedback.adminNotes!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
