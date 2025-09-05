import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/mentor_provider.dart';
import '../models/user.dart';
import '../models/mentor.dart';
import '../services/db_helper.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<User> _allUsers = [];
  List<Mentor> _allMentors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final users = await DBHelper.getAllUsers();
      final mentors = await DBHelper.getAllMentors();
      
      setState(() {
        _allUsers = users;
        _allMentors = mentors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.school), text: 'Mentors'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildUsersTab(),
                _buildMentorsTab(),
                _buildSettingsTab(),
              ],
            ),
    );
  }

  Widget _buildDashboardTab() {
    final totalUsers = _allUsers.length;
    final verifiedUsers = _allUsers.where((u) => u.isVerified).length;
    final totalMentors = _allMentors.length;
    final verifiedMentors = _allMentors.where((m) => m.isVerified).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Users',
                  totalUsers.toString(),
                  Icons.people,
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Verified Users',
                  verifiedUsers.toString(),
                  Icons.verified_user,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Mentors',
                  totalMentors.toString(),
                  Icons.school,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Verified Mentors',
                  verifiedMentors.toString(),
                  Icons.verified,
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildQuickActionCard(
            'Verify Pending Users',
            'Review and verify new user registrations',
            Icons.person_add,
            Theme.of(context).primaryColor,
            () => _tabController.animateTo(1),
          ),
          const SizedBox(height: 12),
          _buildQuickActionCard(
            'Approve Mentors',
            'Review mentor applications and credentials',
            Icons.school,
            Colors.green,
            () => _tabController.animateTo(2),
          ),
          const SizedBox(height: 12),
          _buildQuickActionCard(
            'System Settings',
            'Configure app-wide settings and permissions',
            Icons.settings,
            Theme.of(context).colorScheme.onSurfaceVariant,
            () => _tabController.animateTo(3),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    final pendingUsers = _allUsers.where((u) => !u.isVerified).toList();
    final verifiedUsers = _allUsers.where((u) => u.isVerified).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.black,
            tabs: [
              Tab(text: 'Pending Verification'),
              Tab(text: 'Verified Users'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildUserList(pendingUsers, showVerifyButton: true),
                _buildUserList(verifiedUsers, showVerifyButton: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorsTab() {
    final pendingMentors = _allMentors.where((m) => !m.isVerified).toList();
    final verifiedMentors = _allMentors.where((m) => m.isVerified).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.black,
            tabs: [
              Tab(text: 'Pending Approval'),
              Tab(text: 'Verified Mentors'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMentorList(pendingMentors, showVerifyButton: true),
                _buildMentorList(verifiedMentors, showVerifyButton: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'App Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        
        _buildSettingCard(
          'User Registration',
          'Control who can register and join the platform',
          Icons.person_add,
          () => _showComingSoon('User Registration Settings'),
        ),
        const SizedBox(height: 12),
        _buildSettingCard(
          'Mentor Applications',
          'Configure mentor application process',
          Icons.school,
          () => _showComingSoon('Mentor Application Settings'),
        ),
        const SizedBox(height: 12),
        _buildSettingCard(
          'Chat Moderation',
          'Set up chat monitoring and moderation rules',
          Icons.chat,
          () => _showComingSoon('Chat Moderation'),
        ),
        const SizedBox(height: 12),
        _buildSettingCard(
          'Notification Settings',
          'Configure system-wide notifications',
          Icons.notifications,
          () => _showComingSoon('Notification Settings'),
        ),
        const SizedBox(height: 12),
        _buildSettingCard(
          'Data Management',
          'Export data, backup, and maintenance tools',
          Icons.storage,
          () => _showComingSoon('Data Management'),
        ),
        const SizedBox(height: 12),
        _buildSettingCard(
          'Security Settings',
          'Configure security policies and access controls',
          Icons.security,
          () => _showComingSoon('Security Settings'),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildUserList(List<User> users, {required bool showVerifyButton}) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              showVerifyButton ? 'No pending users' : 'No verified users',
              style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(user.role),
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email),
                Text('Role: ${user.role.toUpperCase()}'),
                if (user.occupation.isNotEmpty) Text('Occupation: ${user.occupation}'),
              ],
            ),
            trailing: showVerifyButton
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _verifyUser(user),
                        tooltip: 'Verify User',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectUser(user),
                        tooltip: 'Reject User',
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) => _handleUserAction(value, user),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'promote_mentor',
                            child: Row(
                              children: [
                                Icon(Icons.school, size: 16),
                                SizedBox(width: 8),
                                Text('Promote to Mentor'),
                              ],
                            ),
                          ),
                          if (user.role != 'admin')
                            const PopupMenuItem(
                              value: 'promote_admin',
                              child: Row(
                                children: [
                                  Icon(Icons.admin_panel_settings, size: 16),
                                  SizedBox(width: 8),
                                  Text('Promote to Admin'),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user, color: Colors.green),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) => _handleUserAction(value, user),
                        itemBuilder: (context) => [
                          if (user.role == 'user')
                            const PopupMenuItem(
                              value: 'promote_mentor',
                              child: Row(
                                children: [
                                  Icon(Icons.school, size: 16),
                                  SizedBox(width: 8),
                                  Text('Promote to Mentor'),
                                ],
                              ),
                            ),
                          if (user.role != 'admin')
                            const PopupMenuItem(
                              value: 'promote_admin',
                              child: Row(
                                children: [
                                  Icon(Icons.admin_panel_settings, size: 16),
                                  SizedBox(width: 8),
                                  Text('Promote to Admin'),
                                ],
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'remove_verification',
                            child: Row(
                              children: [
                                Icon(Icons.remove_circle, size: 16, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('Remove Verification'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete_user',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete User'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildMentorList(List<Mentor> mentors, {required bool showVerifyButton}) {
    if (mentors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              showVerifyButton ? 'No pending mentors' : 'No verified mentors',
              style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mentors.length,
      itemBuilder: (context, index) {
        final mentor = mentors[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                mentor.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(mentor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mentor.email),
                Text('Expertise: ${mentor.expertise}'),
                if (mentor.bio.isNotEmpty) Text('Bio: ${mentor.bio}'),
              ],
            ),
            trailing: showVerifyButton
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _verifyMentor(mentor),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectMentor(mentor),
                      ),
                    ],
                  )
                : Icon(Icons.verified, color: Colors.green),
          ),
        );
      },
    );
  }

  Widget _buildSettingCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red[600]!;
      case 'mentor':
        return Colors.green[600]!;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  Future<void> _verifyUser(User user) async {
    try {
      await DBHelper.updateUserVerification(user.id!, true);
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.name} has been verified')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying user: $e')),
      );
    }
  }

  Future<void> _rejectUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject User'),
        content: Text('Are you sure you want to reject ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DBHelper.deleteUser(user.id!);
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name} has been rejected and removed')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting user: $e')),
        );
      }
    }
  }

  Future<void> _verifyMentor(Mentor mentor) async {
    try {
      await DBHelper.updateMentorVerification(mentor.id!, true);
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${mentor.name} has been verified as a mentor')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying mentor: $e')),
      );
    }
  }

  Future<void> _rejectMentor(Mentor mentor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Mentor'),
        content: Text('Are you sure you want to reject ${mentor.name} as a mentor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DBHelper.deleteMentor(mentor.id!);
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${mentor.name} has been rejected and removed')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting mentor: $e')),
        );
      }
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }

  Future<void> _handleUserAction(String action, User user) async {
    switch (action) {
      case 'promote_mentor':
        await _promoteUserToMentor(user);
        break;
      case 'promote_admin':
        await _promoteUserToAdmin(user);
        break;
      case 'remove_verification':
        await _removeUserVerification(user);
        break;
      case 'delete_user':
        await _deleteUserWithConfirmation(user);
        break;
    }
  }

  Future<void> _promoteUserToMentor(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promote to Mentor'),
        content: Text('Are you sure you want to promote ${user.name} to mentor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Promote'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DBHelper.promoteUserToMentor(user.email);
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name} has been promoted to mentor')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error promoting user: $e')),
        );
      }
    }
  }

  Future<void> _promoteUserToAdmin(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promote to Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to promote ${user.name} to admin?'),
            const SizedBox(height: 8),
            const Text(
              'Admins have full control over the app including:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• User and mentor verification'),
            const Text('• Role management'),
            const Text('• App settings and controls'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Promote to Admin'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DBHelper.updateUserRole(user.id!, 'admin');
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name} has been promoted to admin')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error promoting user: $e')),
        );
      }
    }
  }

  Future<void> _removeUserVerification(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Verification'),
        content: Text('Are you sure you want to remove verification for ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DBHelper.updateUserVerification(user.id!, false);
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification removed for ${user.name}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing verification: $e')),
        );
      }
    }
  }

  Future<void> _deleteUserWithConfirmation(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete ${user.name}?'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone and will:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const Text('• Remove all user data'),
            const Text('• Delete chat history'),
            const Text('• Cancel active sessions'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DBHelper.deleteUser(user.id!);
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name} has been deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')),
        );
      }
    }
  }
}
