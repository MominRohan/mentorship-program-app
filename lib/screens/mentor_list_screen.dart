/*
Developer: Momin Rohan
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mentor.dart';
import '../models/chat_room.dart';
import '../providers/mentor_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/app_routes.dart';
import 'session_history_screen.dart';
import 'admin_session_screen.dart';
import 'mentor_detail_screen.dart';
import 'promote_mentor_screen.dart';
import 'approve_session_screen.dart';
import 'chat_list_screen.dart';



class MentorListScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MentorListScreen> createState() => _MentorListScreenState();
}

class _MentorListScreenState extends ConsumerState<MentorListScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  Future<void> _loadMentors() async {
    await ref.read(mentorProvider.notifier).fetchMentors();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mentorState = ref.watch(mentorProvider);
    final authState = ref.watch(authProvider);
    final String userRole = authState.user?.role ?? "user";

    return Scaffold(
      appBar: AppBar(
        title: Text("🎓 Mentor List"),
        automaticallyImplyLeading: false,
      ),

      body: Column(
        children: [

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            color: Colors.brown,
            child: Text(
              _getWelcomeMessage(userRole),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),

              textAlign: TextAlign.center,
            ),
          ),

          if (userRole == "admin") 
            Padding(
              padding: EdgeInsets.all(8),
              child: ElevatedButton.icon(
                icon: Icon(Icons.person_add, size: 18),
                label: Text("Promote User to Mentor"),
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PromoteMentorScreen()),
                  ).then((_) => _loadMentors());
                },
              ),
            ),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : mentorState.mentors.isEmpty
                    ? _buildNoMentorsMessage()
                    : ListView.builder(
                        itemCount: mentorState.mentors.length,
                        itemBuilder: (context, index) {
                          final mentor = mentorState.mentors[index];
                          return _buildMentorCard(mentor, userRole);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String tooltip, Widget? screen, {bool logout = false}) {
    return IconButton(
      icon: Icon(icon, size: 28),
      tooltip: tooltip,
      onPressed: () {
        if (logout) {
          ref.read(authProvider.notifier).logout();
          Navigator.pushReplacementNamed(context, "/login");
        } else if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        }
      },
    );
  }


  String _getWelcomeMessage(String role) {
    if (role == "admin") return "👋 Welcome Admin! You can promote users to mentors and manage sessions.";
    if (role == "mentor") return "🔹 Welcome Mentor! Check mentorship requests and approve sessions.";
    return "🌟 Welcome! Browse mentors and request mentorship sessions.";
  }

  Widget _buildNoMentorsMessage() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_off, size: 60, color: Theme.of(context).colorScheme.onSurfaceVariant),
          SizedBox(height: 10),
          Text("No mentors available.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _startChatWithMentor(Mentor mentor) async {
    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to start a chat')),
      );
      return;
    }

    try {
      final chatService = ref.read(chatServiceProvider);
      ChatRoom? existingChat = await chatService.findOneOnOneChat(currentUser.stringId, mentor.id.toString());
      
      if (existingChat != null) {
        AppRoutes.navigateToChat(context, existingChat);
      } else {
        final newChat = await chatService.createOneOnOneChat(
          currentUser.stringId,
          mentor.id.toString(),
          currentUser.name,
          mentor.name,
        );
        ref.refresh(chatRoomsProvider);
        AppRoutes.navigateToChat(context, newChat);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat')),
      );
    }
  }

  Widget _buildMentorCard(Mentor mentor, String userRole) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(mentor.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(mentor.expertise, style: TextStyle(fontSize: 16, color: Colors.black54)),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MentorDetailScreen(mentor: mentor)));
        },
        trailing: userRole == "user"
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.chat, color: Colors.green),
                    tooltip: "Start Chat",
                    onPressed: () => _startChatWithMentor(mentor),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.schedule, size: 16),
                    label: Text("Request"),
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10)),
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ApproveSessionScreen(),
                          ),
                        ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
