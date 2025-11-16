import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ProductivitySettingsScreen extends StatelessWidget {
  const ProductivitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            children: [
              _SectionHeader('Gamification'),
              SwitchListTile(
                title: const Text('Enable Streaks'),
                subtitle: const Text('Track consecutive days of productivity'),
                value: themeProvider.enableStreaks,
                onChanged: (value) => themeProvider.setEnableStreaks(value),
              ),
              SwitchListTile(
                title: const Text('Enable Gamification'),
                subtitle: const Text('Earn points and achievements'),
                value: themeProvider.enableGamification,
                onChanged: (value) => themeProvider.setEnableGamification(value),
              ),
              const Divider(),

              _SectionHeader('Statistics'),
              SwitchListTile(
                title: const Text('Show Productivity Stats'),
                subtitle: const Text('Display charts and analytics'),
                value: themeProvider.showProductivityStats,
                onChanged: (value) => themeProvider.setShowProductivityStats(value),
              ),
              const Divider(),

              _SectionHeader('Daily Goals'),
              ListTile(
                title: const Text('Daily Task Goal'),
                subtitle: Text('Complete ${themeProvider.dailyGoalTasks} tasks per day'),
                trailing: SizedBox(
                  width: 100,
                  child: Slider(
                    value: themeProvider.dailyGoalTasks.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: themeProvider.dailyGoalTasks.toString(),
                    onChanged: (value) {
                      themeProvider.setDailyGoalTasks(value.round());
                    },
                  ),
                ),
              ),
              const Divider(),

              _SectionHeader('Notifications'),
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive app notifications'),
                value: themeProvider.enableNotifications,
                onChanged: (value) => themeProvider.setEnableNotifications(value),
              ),
              if (themeProvider.enableNotifications) ...[
                SwitchListTile(
                  title: const Text('Task Reminders'),
                  subtitle: const Text('Get reminded about tasks'),
                  value: themeProvider.enableReminders,
                  onChanged: (value) => themeProvider.setEnableReminders(value),
                ),
                if (themeProvider.enableReminders)
                  ListTile(
                    title: const Text('Default Reminder Time'),
                    subtitle: Text('${themeProvider.reminderMinutesBefore} minutes before'),
                    trailing: DropdownButton<int>(
                      value: themeProvider.reminderMinutesBefore,
                      items: const [
                        DropdownMenuItem(value: 5, child: Text('5 min')),
                        DropdownMenuItem(value: 10, child: Text('10 min')),
                        DropdownMenuItem(value: 15, child: Text('15 min')),
                        DropdownMenuItem(value: 30, child: Text('30 min')),
                        DropdownMenuItem(value: 60, child: Text('1 hour')),
                        DropdownMenuItem(value: 120, child: Text('2 hours')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          themeProvider.setReminderMinutesBefore(value);
                        }
                      },
                    ),
                  ),
              ],
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
