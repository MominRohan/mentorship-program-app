/*
Developer: Momin Rohan
Chat List Screen - Shows all chat rooms
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_room.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import 'chat_screen.dart';
import 'create_group_chat_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomsAsync = ref.watch(chatRoomsProvider);
    final totalUnreadCount = ref.watch(totalUnreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        actions: [
          if (totalUnreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    totalUnreadCount > 99 ? '99+' : totalUnreadCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'new_group':
                  _navigateToCreateGroup();
                  break;
                case 'search':
                  _showSearchDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'new_group',
                child: Row(
                  children: [
                    Icon(Icons.group_add, color: Theme.of(context).primaryColor),
                    SizedBox(width: 8),
                    Text('New Group'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'search',
                child: Row(
                  children: [
                    Icon(Icons.search, color: Theme.of(context).primaryColor),
                    SizedBox(width: 8),
                    Text('Search Messages'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (_searchQuery.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search chats...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          
          // Chat list
          Expanded(
            child: chatRoomsAsync.when(
              data: (chatRooms) {
                final filteredRooms = _filterChatRooms(chatRooms);
                
                if (filteredRooms.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(chatRoomsProvider);
                  },
                  child: ListView.builder(
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      final chatRoom = filteredRooms[index];
                      return _buildChatRoomTile(chatRoom);
                    },
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Error loading chats'),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.refresh(chatRoomsProvider),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateGroup,
        backgroundColor: Color(0xFFBA8900), // primaryColor
        child: Icon(Icons.chat, color: Colors.white),
        tooltip: 'New Chat',
      ),
    );
  }

  List<ChatRoom> _filterChatRooms(List<ChatRoom> chatRooms) {
    if (_searchQuery.isEmpty) return chatRooms;
    
    return chatRooms.where((room) {
      return room.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             (room.lastMessage?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  Widget _buildChatRoomTile(ChatRoom chatRoom) {
    final unreadCount = ref.watch(chatRoomUnreadCountProvider(chatRoom.id));
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: chatRoom.type == ChatType.group ? Colors.green : Theme.of(context).primaryColor,
          backgroundImage: chatRoom.imageUrl != null ? NetworkImage(chatRoom.imageUrl!) : null,
          child: chatRoom.imageUrl == null
              ? Icon(
                  chatRoom.type == ChatType.group ? Icons.group : Icons.person,
                  color: Colors.white,
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chatRoom.name,
                style: TextStyle(
                  fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (chatRoom.lastMessageTime != null)
              Text(
                _formatTime(chatRoom.lastMessageTime!),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                chatRoom.lastMessage ?? 'No messages yet',
                style: TextStyle(
                  color: unreadCount > 0 ? Colors.black87 : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (unreadCount > 0)
              Container(
                margin: EdgeInsets.only(left: 8),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _navigateToChat(chatRoom),
        onLongPress: () => _showChatOptions(chatRoom),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 16),
          Text(
            'No chats yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start a conversation with a mentor or mentee',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreateGroup,
            icon: Icon(Icons.add),
            label: Text('Start New Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFBA8900), // primaryColor
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToChat(ChatRoom chatRoom) {
    // Mark messages as read when entering chat
    final currentUser = ref.read(authProvider).user;
    if (currentUser != null) {
      ref.read(chatServiceProvider).markMessagesAsRead(chatRoom.id, currentUser.stringId);
      ref.read(unreadCountProvider.notifier).markAsRead(chatRoom.id);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatRoom: chatRoom),
      ),
    );
  }

  void _navigateToCreateGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGroupChatScreen(),
      ),
    );
  }

  void _showChatOptions(ChatRoom chatRoom) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.add, color: Theme.of(context).primaryColor),
              title: Text('Chat Info'),
              onTap: () {
                Navigator.pop(context);
                _showChatInfo(chatRoom);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications_off, color: Colors.orange),
              title: Text('Mute Chat'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement mute functionality
              },
            ),
            if (chatRoom.type == ChatType.group)
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text('Leave Group'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmLeaveGroup(chatRoom);
                },
              ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Chat'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteChat(chatRoom);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChatInfo(ChatRoom chatRoom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chat Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${chatRoom.name}'),
            SizedBox(height: 8),
            Text('Type: ${chatRoom.type == ChatType.group ? 'Group' : 'One-on-One'}'),
            SizedBox(height: 8),
            Text('Participants: ${chatRoom.participantIds.length}'),
            SizedBox(height: 8),
            Text('Created: ${_formatDate(chatRoom.createdAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmLeaveGroup(ChatRoom chatRoom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave Group'),
        content: Text('Are you sure you want to leave "${chatRoom.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement leave group functionality
            },
            child: Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteChat(ChatRoom chatRoom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Chat'),
        content: Text('Are you sure you want to delete this chat? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(chatRoomsProvider.notifier).deleteChatRoom(chatRoom.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chat deleted')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete chat')),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Messages'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Enter search term...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (query) {
            Navigator.pop(context);
            if (query.isNotEmpty) {
              // TODO: Navigate to search results screen
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
