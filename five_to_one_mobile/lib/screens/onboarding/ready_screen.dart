import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ReadyScreen extends StatelessWidget {
  final VoidCallback onStart;

  const ReadyScreen({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkBackground,
              AppTheme.primaryPurple.withOpacity(0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),

                // Skull icon or imagery (placeholder)
                Icon(
                  Icons.local_fire_department,
                  size: 100,
                  color: AppTheme.accentOrange,
                ),

                const SizedBox(height: 32),

                // Main quote
                Text(
                  '"No one here gets\nout alive"',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Message
                Text(
                  "Let's make your\ntime count.",
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: AppTheme.accentGold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Start button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: Text(
                      'Start My 25',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
}
