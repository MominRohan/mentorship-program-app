import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
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
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
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
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
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
                      color: Colors.blue[600],
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
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Menu Options
          _buildMenuSection('Information', [
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'About App',
              subtitle: 'Learn more about our mission',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How we protect your data',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
              ),
            ),
          ]),

          const SizedBox(height: 16),

          _buildMenuSection('Support', [
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help & FAQ',
              subtitle: 'Get answers to common questions',
              onTap: () => _showComingSoon(context, 'Help & FAQ'),
            ),
            _buildMenuItem(
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              subtitle: 'Share your thoughts with us',
              onTap: () => _showComingSoon(context, 'Feedback'),
            ),
            _buildMenuItem(
              icon: Icons.star_rate_outlined,
              title: 'Rate App',
              subtitle: 'Rate us on the app store',
              onTap: () => _showComingSoon(context, 'Rate App'),
            ),
          ]),

          const SizedBox(height: 16),

          _buildMenuSection('App', [
            _buildMenuItem(
              icon: Icons.update,
              title: 'Check for Updates',
              subtitle: 'Version 1.0.0',
              onTap: () => _showComingSoon(context, 'Updates'),
            ),
            _buildMenuItem(
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

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[600], size: 28),
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
