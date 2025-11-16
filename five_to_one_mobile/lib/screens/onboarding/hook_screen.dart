import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HookScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const HookScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryViolet.withOpacity(0.3),
              AppTheme.darkBackground,
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

                // Main quote
                Text(
                  '"Five to One, baby"',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.accentOrange,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Message
                Text(
                  'Most people have 25+ things\nthey want to accomplish.',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                Text(
                  'Most people accomplish\nnone of them.',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.urgentRed,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Swipe up indicator
                Column(
                  children: [
                    Text(
                      'Swipe up to continue',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: AppTheme.textSecondary,
                      size: 32,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Or tap button
                ElevatedButton(
                  onPressed: onContinue,
                  child: const Text('Continue'),
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
