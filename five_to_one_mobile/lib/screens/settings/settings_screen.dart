import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/canny_service.dart';
import '../../config/canny_config.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
          ),

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
              onTap: _handleUpgradeAccount,
            ),

          const Divider(),

          // App Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'App',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
          ),

          // Feedback via Canny
          if (CannyConfig.isConfigured)
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('Send Feedback'),
              subtitle: const Text('Share feedback, request features, report bugs'),
              trailing: const Icon(Icons.open_in_new, size: 16),
              onTap: () async {
                try {
                  await CannyService.openFeedback();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not open feedback: $e'),
                        backgroundColor: AppTheme.urgentRed,
                      ),
                    );
                  }
                }
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.feedback_outlined, color: Colors.grey),
              title: const Text('Feedback (Not Configured)'),
              subtitle: const Text('Contact developer to enable feedback'),
              enabled: false,
            ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Subtask - Task management with frameworks'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Subtask',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 Subtask',
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'A task management app with framework support for the Buffett-Munger 5/25 method and Eisenhower Matrix.',
                  ),
                ],
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
        ],
      ),
    );
  }
}
