/*
Developer: Momin Rohan
Create Group Chat Screen
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_room.dart';
import '../models/mentor.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/mentor_provider.dart';

class CreateGroupChatScreen extends ConsumerStatefulWidget {
  @override
  _CreateGroupChatScreenState createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends ConsumerState<CreateGroupChatScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();
  final Set<int> _selectedParticipants = {};
  bool _isCreating = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mentorState = ref.watch(mentorProvider);
    final currentUser = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('New Group Chat'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _selectedParticipants.isNotEmpty && !_isCreating
                ? _createGroupChat
                : null,
            child: Text(
              'Create',
              style: TextStyle(
                color: _selectedParticipants.isNotEmpty && !_isCreating
                    ? Colors.white
                    : Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Group info section
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Group avatar placeholder
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  child: Icon(Icons.group, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                SizedBox(height: 16),
                
                // Group name input
                TextField(
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    labelText: 'Group Name',
                    hintText: 'Enter group name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group),
                  ),
                  maxLength: 50,
                ),
                SizedBox(height: 16),
                
                // Group description input
                TextField(
                  controller: _groupDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Group Description (Optional)',
                    hintText: 'What is this group about?',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                  maxLength: 200,
                ),
              ],
            ),
          ),
          
          Divider(),
          
          // Participants section
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.people, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  'Add Participants (${_selectedParticipants.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Selected participants chips
          if (_selectedParticipants.isNotEmpty)
            Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: mentorState.when(
                data: (users, mentors) {
                  final selectedMentors = mentors
                      .where((mentor) => _selectedParticipants.contains(mentor.id!))
                      .toList();
                  
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedMentors.length,
                    itemBuilder: (context, index) {
                      final mentor = selectedMentors[index];
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        child: Chip(
                          avatar: CircleAvatar(
                            backgroundImage: mentor.avatarUrl != null
                                ? NetworkImage(mentor.avatarUrl!)
                                : null,
                            child: mentor.avatarUrl == null
                                ? Text(mentor.name.isNotEmpty ? mentor.name[0] : '?')
                                : null,
                          ),
                          label: Text(mentor.name),
                          deleteIcon: Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedParticipants.remove(mentor.id);
                            });
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => SizedBox(),
                error: (error) => SizedBox(),
              ),
            ),
          
          // Available participants list
          Expanded(
            child: mentorState.when(
              data: (users, mentors) {
                // Filter out current user and already selected participants
                final availableMentors = mentors
                    .where((mentor) => 
                        mentor.id != currentUser?.id && 
                        !_selectedParticipants.contains(mentor.id!))
                    .toList();
                
                if (availableMentors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        SizedBox(height: 16),
                        Text(
                          'No more participants available',
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: availableMentors.length,
                  itemBuilder: (context, index) {
                    final mentor = availableMentors[index];
                    final isSelected = _selectedParticipants.contains(mentor.id!);
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: mentor.avatarUrl != null
                            ? NetworkImage(mentor.avatarUrl!)
                            : null,
                        child: mentor.avatarUrl == null
                            ? Text(mentor.name.isNotEmpty ? mentor.name[0] : '?')
                            : null,
                      ),
                      title: Text(mentor.name),
                      subtitle: Text(mentor.expertise),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedParticipants.add(mentor.id!);
                            } else {
                              _selectedParticipants.remove(mentor.id!);
                            }
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedParticipants.remove(mentor.id!);
                          } else {
                            _selectedParticipants.add(mentor.id!);
                          }
                        });
                      },
                    );
                  },
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Error loading participants'),
                    ElevatedButton(
                      onPressed: () => ref.refresh(mentorProvider),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createGroupChat() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    if (_selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one participant')),
      );
      return;
    }

    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) return;

    setState(() => _isCreating = true);

    try {
      final chatRoomId = 'group_${DateTime.now().millisecondsSinceEpoch}';
      final participantIds = [currentUser.stringId, ..._selectedParticipants.map((id) => id.toString())];
      
      final chatRoom = ChatRoom(
        id: chatRoomId,
        name: groupName,
        description: _groupDescriptionController.text.trim(),
        type: ChatType.group,
        participantIds: participantIds,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(chatRoomsProvider.notifier).createChatRoom(chatRoom);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group chat created successfully!')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group chat')),
      );
    } finally {
      setState(() => _isCreating = false);
    }
  }
}
