import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MethodScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const MethodScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryPurple.withOpacity(0.4),
              AppTheme.darkBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),

                // Title
                Center(
                  child: Text(
                    "Warren Buffett's secret:",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.accentGold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 48),

                // Steps
                _buildStep(context, '1', 'List 25 goals'),
                const SizedBox(height: 24),
                _buildStep(context, '2', 'Circle your top 5'),
                const SizedBox(height: 24),
                _buildStep(context, '3', 'Avoid the other 20\nat all costs',
                    emphasize: true),

                const SizedBox(height: 48),

                // Key insight
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.accentOrange.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    "They're not just deprioritized.\nThey're distractions.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                      color: AppTheme.accentOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(),

                // Continue button
                Center(
                  child: ElevatedButton(
                    onPressed: onContinue,
                    child: const Text('I understand'),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String text,
      {bool emphasize = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: emphasize ? AppTheme.urgentRed : AppTheme.primaryPurple,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                fontWeight: emphasize ? FontWeight.bold : FontWeight.normal,
                color: emphasize ? AppTheme.urgentRed : AppTheme.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
