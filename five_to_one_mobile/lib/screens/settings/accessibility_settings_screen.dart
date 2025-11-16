import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            children: [
              _SectionHeader('Visual'),
              SwitchListTile(
                title: const Text('High Contrast Mode'),
                subtitle: const Text('Increase contrast for better visibility'),
                value: themeProvider.highContrastMode,
                onChanged: (value) => themeProvider.setHighContrastMode(value),
              ),
              SwitchListTile(
                title: const Text('Large Text'),
                subtitle: const Text('Use larger text size throughout the app'),
                value: themeProvider.largeTextMode,
                onChanged: (value) => themeProvider.setLargeTextMode(value),
              ),
              const Divider(),

              _SectionHeader('Motion'),
              SwitchListTile(
                title: const Text('Reduce Motion'),
                subtitle: const Text('Minimize animations and transitions'),
                value: themeProvider.reduceMotion,
                onChanged: (value) => themeProvider.setReduceMotion(value),
              ),
              const Divider(),

              _SectionHeader('Feedback'),
              SwitchListTile(
                title: const Text('Haptic Feedback'),
                subtitle: const Text('Vibrate on interactions'),
                value: themeProvider.enableHaptics,
                onChanged: (value) => themeProvider.setEnableHaptics(value),
              ),
              SwitchListTile(
                title: const Text('Sound Effects'),
                subtitle: const Text('Play sounds for actions'),
                value: themeProvider.enableSoundEffects,
                onChanged: (value) => themeProvider.setEnableSoundEffects(value),
              ),
              const Divider(),

              _SectionHeader('Screen Reader'),
              SwitchListTile(
                title: const Text('Screen Reader Optimized'),
                subtitle: const Text('Optimize for screen reader usage'),
                value: themeProvider.screenReaderOptimized,
                onChanged: (value) => themeProvider.setScreenReaderOptimized(value),
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'These settings help make the app more accessible for users with different needs and preferences.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
