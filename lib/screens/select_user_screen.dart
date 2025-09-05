/*
Developer: Momin Rohan
User Selection Screen for One-to-One Chats
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/mentor.dart';
import '../models/chat_room.dart';
import '../providers/mentor_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class SelectUserScreen extends ConsumerStatefulWidget {
  @override
  _SelectUserScreenState createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends ConsumerState<SelectUserScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showMentorsOnly = false;

  @override
  void initState() {
    super.initState();
    // Fetch users and mentors when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mentorProvider.notifier).fetchUsers();
      ref.read(mentorProvider.notifier).fetchMentors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mentorState = ref.watch(mentorProvider);
    final currentUser = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Start New Chat'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filter users',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter chip
          if (_showMentorsOnly)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text('Mentors Only'),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    deleteIcon: Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _showMentorsOnly = false;
                      });
                    },
                  ),
                ],
              ),
            ),

          // User list
          Expanded(
            child: mentorState.when(
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Error loading users'),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(mentorProvider.notifier).fetchUsers();
                        ref.read(mentorProvider.notifier).fetchMentors();
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (users, mentors) {
                final filteredUsers = _getFilteredUsers(users, mentors, currentUser);
                
                if (filteredUsers.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final isMentor = mentors.any((m) => m.email == user.email);
                    return _buildUserTile(user, isMentor);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<User> _getFilteredUsers(List<User> users, List<Mentor> mentors, User? currentUser) {
    List<User> allUsers = List.from(users);
    
    // Add mentors to the list if they're not already there
    for (var mentor in mentors) {
      if (!allUsers.any((u) => u.email == mentor.email)) {
        // Create a User object from Mentor data
        // Parse name into firstName and lastName
        final nameParts = mentor.name.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        
        allUsers.add(User(
          id: mentor.id,
          firstName: firstName,
          lastName: lastName,
          email: mentor.email,
          password: '', // Not needed for display
          address: '', // Mentor model doesn't have address
          bio: mentor.bio,
          occupation: mentor.occupation,
          expertise: mentor.expertise,
          role: 'mentor',
        ));
      }
    }

    // Remove current user from the list
    if (currentUser != null) {
      allUsers.removeWhere((u) => u.email == currentUser.email);
    }

    // Apply mentor filter
    if (_showMentorsOnly) {
      allUsers = allUsers.where((u) => 
        mentors.any((m) => m.email == u.email) || u.role == 'mentor'
      ).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      allUsers = allUsers.where((u) {
        final query = _searchQuery.toLowerCase();
        return u.name.toLowerCase().contains(query) ||
               u.email.toLowerCase().contains(query) ||
               u.expertise.toLowerCase().contains(query) ||
               u.occupation.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by name
    allUsers.sort((a, b) => a.name.compareTo(b.name));
    
    return allUsers;
  }

  Widget _buildUserTile(User user, bool isMentor) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isMentor 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.secondary,
          backgroundImage: user.avatarUrl != null 
              ? NetworkImage(user.avatarUrl!) 
              : null,
          child: user.avatarUrl == null
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isMentor)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Mentor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.occupation.isNotEmpty)
              Text(
                user.occupation,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            if (user.expertise.isNotEmpty)
              Text(
                user.expertise,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Icon(
          Icons.chat_bubble_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
        onTap: () => _startChatWithUser(user),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 8),
          Text(
            _showMentorsOnly 
                ? 'Try removing the mentor filter'
                : 'Try adjusting your search',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Show Mentors Only'),
              subtitle: Text('Filter to show only mentors'),
              value: _showMentorsOnly,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) {
                setState(() {
                  _showMentorsOnly = value;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startChatWithUser(User user) async {
    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to start a chat')),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Starting chat...'),
                ],
              ),
            ),
          ),
        ),
      );

      final chatService = ChatService();
      
      // Check if chat already exists
      ChatRoom? existingChat = await chatService.findOneOnOneChat(
        currentUser.stringId, 
        user.stringId
      );

      ChatRoom chatRoom;
      if (existingChat != null) {
        chatRoom = existingChat;
      } else {
        // Create new one-on-one chat
        chatRoom = await chatService.createOneOnOneChat(
          currentUser.stringId,
          user.stringId,
          currentUser.name,
          user.name,
        );
      }

      // Dismiss loading dialog
      Navigator.pop(context);

      // Navigate to chat screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(chatRoom: chatRoom),
        ),
      );

      // Refresh chat rooms list
      ref.refresh(chatRoomsProvider);

    } catch (e) {
      // Dismiss loading dialog
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start chat: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
