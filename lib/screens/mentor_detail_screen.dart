/*
Developer: Momin Rohan
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mentor.dart';
import '../models/chat_room.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/app_routes.dart';

class MentorDetailScreen extends ConsumerWidget {
  final Mentor mentor;

  MentorDetailScreen({required this.mentor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(mentor.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Center(
              child: Text(
                "👋 Welcome to the Mentor Details Screen",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(thickness: 1, height: 20),

            _buildDetailSection("👤 Name", mentor.name),
            _buildDetailSection("📖 Bio", mentor.bio),
            _buildDetailSection("💼 Occupation", mentor.occupation),
            _buildDetailSection("🎓 Expertise", mentor.expertise),




            SizedBox(height: 20),
            
            // Action buttons row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startChat(context, ref),
                    icon: Icon(Icons.chat, color: Colors.white),
                    label: Text(
                      "Start Chat",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/request_session', arguments: mentor);
                    },
                    icon: Icon(Icons.video_call, color: Colors.white),
                    label: Text(
                      "Request Session",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); 
                },
                child: Text("Back to Mentors"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(content, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> _startChat(BuildContext context, WidgetRef ref) async {
    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to start a chat')),
      );
      return;
    }

    try {
      // Check if one-on-one chat already exists
      final chatService = ref.read(chatServiceProvider);
      ChatRoom? existingChat = await chatService.findOneOnOneChat(currentUser.stringId, mentor.id.toString());
      
      if (existingChat != null) {
        // Navigate to existing chat
        AppRoutes.navigateToChat(context, existingChat);
      } else {
        // Create new one-on-one chat
        final newChat = await chatService.createOneOnOneChat(
          currentUser.stringId,
          mentor.id.toString(),
          currentUser.name,
          mentor.name,
        );
        
        // Refresh chat rooms list
        ref.refresh(chatRoomsProvider);
        
        // Navigate to new chat
        AppRoutes.navigateToChat(context, newChat);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat: $e')),
      );
    }
  }
}
