import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/item.dart';
import '../theme/app_theme.dart';

/// Pentagon wheel widget for displaying 5 prioritized items
///
/// Shows items arranged in a pentagon pattern with a center label.
class PentagonWheel extends StatelessWidget {
  final List<Item> goals;
  final Function(Item)? onGoalTap;
  final String? centerLabel;

  const PentagonWheel({
    super.key,
    required this.goals,
    this.onGoalTap,
    this.centerLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure we have exactly 5 or fewer goals
    final displayGoals = goals.take(5).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 500.0);
        final centerX = size / 2;
        final centerY = size / 2;
        final radius = size * 0.32;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              // Center label
              Positioned(
                left: centerX - 60,
                top: centerY - 60,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accentOrange.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      centerLabel ?? '5/25',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: AppTheme.accentOrange,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                ),
              ),

              // Position goals in pentagon layout
              ...List.generate(displayGoals.length, (index) {
                // Calculate angle for this goal (pentagon layout)
                final angle = (index * 2 * math.pi / 5) - (math.pi / 2);
                final x = centerX + radius * math.cos(angle) - 70;
                final y = centerY + radius * math.sin(angle) - 70;

                return Positioned(
                  left: x,
                  top: y,
                  child: GoalCard(
                    goal: displayGoals[index],
                    index: index,
                    onTap: onGoalTap != null
                        ? () => onGoalTap!(displayGoals[index])
                        : null,
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

/// Individual goal card in the pentagon wheel
class GoalCard extends StatelessWidget {
  final Item goal;
  final int index;
  final VoidCallback? onTap;

  const GoalCard({
    super.key,
    required this.goal,
    required this.index,
    this.onTap,
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

    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: goal.isCompleted
              ? AppTheme.cardBackground.withOpacity(0.5)
              : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: goal.isCompleted
                ? AppTheme.successGreen.withOpacity(0.6)
                : color.withOpacity(0.6),
            width: 2,
          ),
          boxShadow: goal.isCompleted
              ? []
              : [
                  BoxShadow(
                    color: color.withOpacity(0.3),
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
                  color: goal.isCompleted ? AppTheme.successGreen : color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: goal.isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : Text(
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
                    goal.title,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: goal.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: goal.isCompleted
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                        ),
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
