import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GoalsInputScreen extends StatefulWidget {
  final Function(List<String>) onComplete;

  const GoalsInputScreen({super.key, required this.onComplete});

  @override
  State<GoalsInputScreen> createState() => _GoalsInputScreenState();
}

class _GoalsInputScreenState extends State<GoalsInputScreen> {
  final List<TextEditingController> _controllers = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Start with 5 empty fields
    for (int i = 0; i < 5; i++) {
      _controllers.add(TextEditingController());
    }
  }

  void _addGoal() {
    if (_controllers.length < 25) {
      setState(() {
        _controllers.add(TextEditingController());
      });
      // Scroll to bottom after adding
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _removeGoal(int index) {
    if (_controllers.length > 1) {
      setState(() {
        _controllers[index].dispose();
        _controllers.removeAt(index);
      });
    }
  }

  List<String> _getFilledGoals() {
    return _controllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
  }

  bool get _canContinue => _getFilledGoals().length >= 5;

  @override
  Widget build(BuildContext context) {
    final filledCount = _getFilledGoals().length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your 25 Goals'),
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
                    'What are your 25 goals?',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Don't overthink it.\nYou'll prioritize next.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Goals list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _controllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        // Number
                        SizedBox(
                          width: 32,
                          child: Text(
                            '${index + 1}.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Input field
                        Expanded(
                          child: TextField(
                            controller: _controllers[index],
                            decoration: InputDecoration(
                              hintText: 'Enter a goal...',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                            textCapitalization: TextCapitalization.sentences,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),

                        // Delete button
                        if (_controllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.close),
                            color: AppTheme.textSecondary,
                            onPressed: () => _removeGoal(index),
                          ),
                      ],
                    ),
                  );
                },
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
                  // Add goal button
                  if (_controllers.length < 25)
                    TextButton.icon(
                      onPressed: _addGoal,
                      icon: const Icon(Icons.add),
                      label: const Text('Add goal'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accentOrange,
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Progress counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$filledCount/${_controllers.length} goals',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: filledCount >= 5
                              ? AppTheme.successGreen
                              : AppTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (filledCount >= 5 && filledCount < 25)
                        Text(
                          'Minimum 5, max 25',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canContinue
                          ? () => widget.onComplete(_getFilledGoals())
                          : null,
                      child: const Text('Continue'),
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

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }
}
