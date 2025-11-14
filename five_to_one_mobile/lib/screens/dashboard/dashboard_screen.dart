import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/app_theme.dart';
import '../../utils/doors_quotes.dart';

class DashboardScreen extends StatefulWidget {
  final List<String> topFiveGoals;

  const DashboardScreen({super.key, required this.topFiveGoals});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _currentQuote = DoorsQuotes.getMotivational();

  void _refreshQuote() {
    setState(() {
      _currentQuote = DoorsQuotes.getMotivational();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Five to One'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Settings screen
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshQuote();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // The Wheel - Circular layout of 5 goals
                    Expanded(
                      child: GoalWheel(
                        goals: widget.topFiveGoals,
                        onGoalTap: (index) {
                          // TODO: Navigate to goal detail
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tapped: ${widget.topFiveGoals[index]}'),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Motivational quote
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _currentQuote,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats (placeholder)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: AppTheme.accentOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '3 tasks done today',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Bottom buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Show avoid list
                            },
                            icon: const Icon(Icons.lock),
                            label: const Text('Avoid List'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.avoidGray,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom widget for circular goal layout
class GoalWheel extends StatelessWidget {
  final List<String> goals;
  final Function(int) onGoalTap;

  const GoalWheel({
    super.key,
    required this.goals,
    required this.onGoalTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final radius = size * 0.35;
        final centerX = size / 2;
        final centerY = size / 2;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              // Center circle decoration
              Positioned(
                left: centerX - 60,
                top: centerY - 60,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '5/25',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppTheme.accentOrange,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),

              // Position 5 goals in a circle
              ...List.generate(goals.length, (index) {
                // Calculate angle for this goal (pentagon layout)
                final angle = (index * 2 * math.pi / 5) - (math.pi / 2);
                final x = centerX + radius * math.cos(angle) - 70;
                final y = centerY + radius * math.sin(angle) - 70;

                return Positioned(
                  left: x,
                  top: y,
                  child: GoalCard(
                    goal: goals[index],
                    index: index,
                    onTap: () => onGoalTap(index),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class GoalCard extends StatelessWidget {
  final String goal;
  final int index;
  final VoidCallback onTap;

  const GoalCard({
    super.key,
    required this.goal,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppTheme.accentOrange,
      AppTheme.primaryPurple,
      AppTheme.accentGold,
      AppTheme.primaryViolet,
      AppTheme.importantBlue,
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors[index % colors.length].withOpacity(0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[index % colors.length].withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Number badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Goal text
              Expanded(
                child: Center(
                  child: Text(
                    goal,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
