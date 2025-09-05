import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(context, user),
            const SizedBox(height: 24),
            
            // Profile Options
            _buildProfileOptions(context, ref, user),
            
            const SizedBox(height: 24),
            
            // Logout Button
            _buildLogoutButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFBA8900), // primaryColor
              child: Text(
                user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // User Info
            Text(
              user?.name ?? 'Unknown User',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'No email',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(context, user?.role),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user?.role?.toUpperCase() ?? 'USER',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context, WidgetRef ref, user) {
    return Column(
      children: [
        _buildOptionTile(context,
          icon: Icons.history,
          title: 'Session History',
          subtitle: 'View your mentoring sessions',
          onTap: () => Navigator.pushNamed(context, AppRoutes.sessionHistory),
        ),
        if (user?.role == 'admin') ...[
          _buildOptionTile(context,
            icon: Icons.admin_panel_settings,
            title: 'Admin Panel',
            subtitle: 'Manage users and sessions',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminPanel),
          ),
          _buildOptionTile(context,
            icon: Icons.approval,
            title: 'Approve Sessions',
            subtitle: 'Review pending sessions',
            onTap: () => Navigator.pushNamed(context, AppRoutes.approveSession),
          ),
          _buildOptionTile(context,
            icon: Icons.trending_up,
            title: 'Promote Mentors',
            subtitle: 'Manage mentor promotions',
            onTap: () => Navigator.pushNamed(context, AppRoutes.promoteMentor),
          ),
        ],
        _buildOptionTile(context,
          icon: Icons.chat_bubble_outline,
          title: 'My Chats',
          subtitle: 'View all conversations',
          onTap: () => Navigator.pushNamed(context, AppRoutes.chatList),
        ),
        _buildOptionTile(context,
          icon: Icons.group_add,
          title: 'Create Group Chat',
          subtitle: 'Start a new group discussion',
          onTap: () => Navigator.pushNamed(context, AppRoutes.createGroupChat),
        ),
        _buildOptionTile(context,
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'App preferences and configuration',
          onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
        ),
      ],
    );
  }

  Widget _buildOptionTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFFBA8900), size: 28), // primaryColor
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context, ref),
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.welcome,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Color _getRoleColor(BuildContext context, String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Colors.red[600]!;
      case 'mentor':
        return Colors.green[600]!;
      default:
        return Color(0xFFBA8900); // primaryColor
    }
  }
}
