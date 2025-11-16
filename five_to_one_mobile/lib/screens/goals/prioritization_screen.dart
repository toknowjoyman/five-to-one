import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PrioritizationScreen extends StatefulWidget {
  final List<String> goals;
  final Function(List<String>) onComplete;

  const PrioritizationScreen({
    super.key,
    required this.goals,
    required this.onComplete,
  });

  @override
  State<PrioritizationScreen> createState() => _PrioritizationScreenState();
}

class _PrioritizationScreenState extends State<PrioritizationScreen> {
  late List<String> _rankedGoals;

  @override
  void initState() {
    super.initState();
    _rankedGoals = List.from(widget.goals);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _rankedGoals.removeAt(oldIndex);
      _rankedGoals.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prioritize'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'Drag to rank your priorities',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pick your top 5',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.accentOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Reorderable list
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _rankedGoals.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final isTopFive = index < 5;
                  final goal = _rankedGoals[index];

                  return Container(
                    key: ValueKey(goal),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isTopFive
                          ? AppTheme.primaryPurple.withOpacity(0.3)
                          : AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isTopFive
                            ? AppTheme.accentOrange.withOpacity(0.5)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag handle
                          Icon(
                            Icons.drag_handle,
                            color: isTopFive
                                ? AppTheme.accentOrange
                                : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          // Number
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isTopFive
                                  ? AppTheme.accentOrange
                                  : AppTheme.avoidGray,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        goal,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              isTopFive ? FontWeight.bold : FontWeight.normal,
                          color: isTopFive
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Divider hint
            if (_rankedGoals.length > 5)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  color: AppTheme.urgentRed.withOpacity(0.5),
                  thickness: 2,
                ),
              ),

            // Bottom section
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                children: [
                  if (_rankedGoals.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Everything below #5 becomes your "Avoid List"',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Lock it in button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => widget.onComplete(_rankedGoals),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                      ),
                      child: const Text('Lock it in →'),
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
