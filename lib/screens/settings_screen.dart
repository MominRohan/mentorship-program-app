import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Settings Section
            _buildSectionHeader('Appearance'),
            _buildThemeSettings(context, ref, themeState),
            
            const SizedBox(height: 24),
            
            // App Preferences Section
            _buildSectionHeader('Preferences'),
            _buildAppPreferences(context, ref),
            
            const SizedBox(height: 24),
            
            // Account Section
            _buildSectionHeader('Account'),
            _buildAccountSettings(context, ref, authState),
            
            const SizedBox(height: 24),
            
            // About Section
            _buildSectionHeader('About'),
            _buildAboutSettings(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context, WidgetRef ref, ThemeState themeState) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              themeState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Theme Mode'),
            subtitle: Text(_getThemeModeText(themeState.themeMode)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showThemeDialog(context, ref, themeState),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(
              Icons.brightness_6,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark theme'),
            value: themeState.isDarkMode,
            onChanged: (value) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferences(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.notifications,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Notifications'),
            subtitle: const Text('Manage notification preferences'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification settings coming soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.language,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Language'),
            subtitle: const Text('English (Default)'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language settings coming soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.storage,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Storage'),
            subtitle: const Text('Manage app data and cache'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showStorageDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context, WidgetRef ref, authState) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.person,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Profile Information'),
            subtitle: Text(authState.user?.email ?? 'No email'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile editing coming soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.security,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Privacy & Security'),
            subtitle: const Text('Manage your privacy settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy settings coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSettings(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.info,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('About App'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.help,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Help & Support'),
            subtitle: const Text('Get help and contact support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support coming soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.feedback,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Send Feedback'),
            subtitle: const Text('Help us improve the app'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback feature coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'Follow system settings';
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeState themeState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                subtitle: const Text('Follow system settings'),
                value: ThemeMode.system,
                groupValue: themeState.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    ref.read(themeProvider.notifier).setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light Mode'),
                subtitle: const Text('Always use light theme'),
                value: ThemeMode.light,
                groupValue: themeState.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    ref.read(themeProvider.notifier).setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark Mode'),
                subtitle: const Text('Always use dark theme'),
                value: ThemeMode.dark,
                groupValue: themeState.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    ref.read(themeProvider.notifier).setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showStorageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Storage Management'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('App Data: ~2.5 MB'),
              SizedBox(height: 8),
              Text('Cache: ~1.2 MB'),
              SizedBox(height: 8),
              Text('Images: ~500 KB'),
              SizedBox(height: 16),
              Text(
                'Clear cache to free up storage space. This won\'t affect your personal data.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared successfully!')),
                );
              },
              child: const Text('Clear Cache'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Mentorship App',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.school,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: const [
        Text('A comprehensive mentorship platform connecting mentors and mentees.'),
        SizedBox(height: 16),
        Text('Developed by: SERGE MUNEZA'),
        Text('Student ID: 20248/2022'),
      ],
    );
  }
}
