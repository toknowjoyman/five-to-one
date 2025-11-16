import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../providers/theme_provider.dart';
import 'appearance_settings_screen.dart';
import 'accessibility_settings_screen.dart';
import 'productivity_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.urgentRed),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      // Navigation will be handled by auth state listener in main.dart
    }
  }

  Future<void> _handleUpgradeAccount() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create a permanent account to save your data across devices.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter a password',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );

    if (result == true) {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isNotEmpty && password.isNotEmpty) {
        try {
          await _authService.upgradeAnonymousAccount(
            email: email,
            password: password,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account upgraded successfully!'),
                backgroundColor: AppTheme.successGreen,
              ),
            );
            setState(() {}); // Refresh to update anonymous status
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error upgrading account: $e'),
                backgroundColor: AppTheme.urgentRed,
              ),
            );
          }
        }
      }
    }

    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isAnonymous = _authService.isAnonymous;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          _SectionHeader('Account'),

          // Account info
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(isAnonymous ? 'Anonymous User' : user?.email ?? 'Unknown'),
            subtitle: Text(
              isAnonymous
                  ? 'Using temporary account'
                  : 'Signed in',
            ),
          ),

          // Upgrade account (only for anonymous users)
          if (isAnonymous)
            ListTile(
              leading: const Icon(Icons.upgrade, color: AppTheme.accentOrange),
              title: const Text('Upgrade Account'),
              subtitle: const Text('Create permanent account to save data'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _handleUpgradeAccount,
            ),

          const Divider(),

          // Customization Section
          _SectionHeader('Customization'),

          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Appearance'),
            subtitle: const Text('Theme, colors, and background'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppearanceSettingsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.accessibility_new),
            title: const Text('Accessibility'),
            subtitle: const Text('High contrast, large text, and more'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccessibilitySettingsScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // Productivity Section
          _SectionHeader('Productivity'),

          ListTile(
            leading: const Icon(Icons.trending_up),
            title: const Text('Productivity Settings'),
            subtitle: const Text('Goals, streaks, and gamification'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductivitySettingsScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // Data & Privacy Section
          _SectionHeader('Data & Privacy'),

          SwitchListTile(
            secondary: const Icon(Icons.cloud_upload),
            title: const Text('Auto Backup'),
            subtitle: const Text('Automatically backup data to cloud'),
            value: themeProvider.autoBackup,
            onChanged: (value) => themeProvider.setAutoBackup(value),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.offline_bolt),
            title: const Text('Offline Mode'),
            subtitle: const Text('Work without internet connection'),
            value: themeProvider.offlineMode,
            onChanged: (value) => themeProvider.setOfflineMode(value),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.wifi),
            title: const Text('Sync on WiFi Only'),
            subtitle: const Text('Save mobile data'),
            value: themeProvider.syncOnWifiOnly,
            onChanged: (value) => themeProvider.setSyncOnWifiOnly(value),
          ),

          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Download your tasks and settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon')),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Import Data'),
            subtitle: const Text('Restore from backup file'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Import feature coming soon')),
              );
            },
          ),

          const Divider(),

          // App Section
          _SectionHeader('App'),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Five-to-One v2.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Five-to-One',
                applicationVersion: '2.0.0',
                applicationLegalese: '© 2024 Five-to-One',
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'A comprehensive task management app with pluggable productivity frameworks including Buffett-Munger 5/25, Eisenhower Matrix, Time Blocking, Kanban, and GTD.',
                  ),
                ],
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Tutorials'),
            subtitle: const Text('Learn how to use frameworks'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help center coming soon')),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Send Feedback'),
            subtitle: const Text('Help us improve'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback form coming soon')),
              );
            },
          ),

          const Divider(),

          // Sign out
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.urgentRed),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.urgentRed),
            ),
            onTap: _handleSignOut,
          ),

          const SizedBox(height: 32),
        ],
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
