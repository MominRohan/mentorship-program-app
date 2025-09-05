import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/routes.dart';
import 'mentor_list_screen.dart';
import 'chat_list_screen.dart';
import 'admin_session_screen.dart';
import 'admin_panel_screen.dart';
import 'profile_screen.dart';
import 'about_screen.dart';
import 'privacy_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAdmin = user?.role == 'admin';

    // Define tabs based on user role
    final List<TabItem> tabs = [
      TabItem(
        icon: Icons.school,
        label: 'Mentors',
        screen: MentorListScreen(),
      ),
      TabItem(
        icon: Icons.chat_bubble_outline,
        label: 'Chats',
        screen: ChatListScreen(),
      ),
      if (isAdmin)
        TabItem(
          icon: Icons.admin_panel_settings,
          label: 'Admin',
          screen: AdminPanelScreen(),
        ),
      TabItem(
        icon: Icons.person,
        label: 'Profile',
        screen: ProfileScreen(),
      ),
      TabItem(
        icon: Icons.more_horiz,
        label: 'More',
        screen: MoreScreen(),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs.map((tab) => tab.screen).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).colorScheme.onSurface,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        backgroundColor: Theme.of(context).colorScheme.surface,
        items: tabs.map((tab) => BottomNavigationBarItem(
          icon: Icon(tab.icon),
          label: tab.label,
        )).toList(),
      ),
    );
  }
}

class TabItem {
  final IconData icon;
  final String label;
  final Widget screen;

  TabItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // App Info Section
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "O'Neal's Mentoring App",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Connect • Learn • Grow',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Menu Options
          _buildMenuSection(context, 'Information', [
            _buildMenuItem(context,
              icon: Icons.info,
              title: 'About',
              subtitle: 'Learn more about this app',
              onTap: () => Navigator.pushNamed(context, AppRoutes.about),
            ),
            _buildMenuItem(context,
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () => Navigator.pushNamed(context, AppRoutes.privacy),
            ),
          ]),

          const SizedBox(height: 16),

          _buildMenuSection(context, 'Support', [
            _buildMenuItem(context,
              icon: Icons.help_outline,
              title: 'Help & FAQ',
              subtitle: 'Get answers to common questions',
              onTap: () => _showComingSoon(context, 'Help & FAQ'),
            ),
            _buildMenuItem(context,
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              subtitle: 'Share your thoughts with us',
              onTap: () => _showComingSoon(context, 'Feedback'),
            ),
            _buildMenuItem(context,
              icon: Icons.star_rate_outlined,
              title: 'Rate App',
              subtitle: 'Rate us on the app store',
              onTap: () => _showComingSoon(context, 'Rate App'),
            ),
          ]),

          const SizedBox(height: 16),

          _buildMenuSection(context, 'App', [
            _buildMenuItem(context,
              icon: Icons.help,
              title: 'Help & Support',
              subtitle: 'Get help and support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support coming soon!')),
                );
              },
            ),
            _buildMenuItem(context,
              icon: Icons.update,
              title: 'Check for Updates',
              subtitle: 'Version 1.0.0',
              onTap: () => _showComingSoon(context, 'Updates'),
            ),
            _buildMenuItem(context,
              icon: Icons.share,
              title: 'Share App',
              subtitle: 'Tell friends about this app',
              onTap: () => _showComingSoon(context, 'Share'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ),
        Card(
          elevation: 2,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    // Let theme_provider control icon colors via IconTheme/ListTileTheme
    return ListTile(
      leading: Icon(icon, size: 28),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
