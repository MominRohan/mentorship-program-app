/*
Developer: Momin Rohan
*/

import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/mentor_list_screen.dart';
import '../screens/promote_mentor_screen.dart';
import '../screens/session_history_screen.dart';
import '../screens/admin_session_screen.dart';
import '../screens/approve_session_screen.dart';
import '../screens/mentor_detail_screen.dart';
import '../screens/request_session_screen.dart';
import '../screens/chat_list_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/create_group_chat_screen.dart';
import '../models/mentor.dart';
import '../models/chat_room.dart';

class AppRoutes {
  // Route names
  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String mentorList = '/mentor-list';
  static const String promoteMentor = '/promote-mentor';
  static const String sessionHistory = '/session-history';
  static const String adminSession = '/admin-session';
  static const String approveSession = '/approve-session';
  static const String mentorDetail = '/mentor-detail';
  static const String requestSession = '/request-session';
  static const String chatList = '/chat-list';
  static const String chat = '/chat';
  static const String createGroupChat = '/create-group-chat';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => SignupScreen());
      case mentorList:
        return MaterialPageRoute(builder: (_) => MentorListScreen());
      case promoteMentor:
        return MaterialPageRoute(builder: (_) => PromoteMentorScreen());
      case sessionHistory:
        return MaterialPageRoute(builder: (_) => SessionHistoryScreen());
      case adminSession:
        return MaterialPageRoute(builder: (_) => AdminSessionScreen());
      case approveSession:
        return MaterialPageRoute(builder: (_) => ApproveSessionScreen());
      case mentorDetail:
        final mentor = settings.arguments;
        if (mentor != null && mentor is Mentor) {
          return MaterialPageRoute(
            builder: (context) => MentorDetailScreen(mentor: mentor),
            settings: settings,
          );
        }
        return _errorRoute();
      case requestSession:
        final mentor = settings.arguments;
        if (mentor != null && mentor is Mentor) {
          return MaterialPageRoute(
            builder: (context) => RequestSessionScreen(mentor: mentor),
            settings: settings,
          );
        }
        return _errorRoute();
      
      case chat:
        // Expecting ChatRoom object as argument
        final chatRoom = settings.arguments;
        if (chatRoom != null && chatRoom is ChatRoom) {
          return MaterialPageRoute(
            builder: (context) => ChatScreen(chatRoom: chatRoom),
            settings: settings,
          );
        }
        return _errorRoute();
      
      case chatList:
        return MaterialPageRoute(builder: (_) => ChatListScreen());
      case createGroupChat:
        return MaterialPageRoute(builder: (_) => CreateGroupChatScreen());
      default:
        return _errorRoute();
    }
  }

  // Error route for invalid navigation
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Page not found!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(welcome),
                child: Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation helpers
  static void navigateToMentorDetail(BuildContext context, Mentor mentor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MentorDetailScreen(mentor: mentor)),
    );
  }

  static void navigateToRequestSession(BuildContext context, Mentor mentor) {
    Navigator.pushNamed(context, requestSession, arguments: mentor);
  }

  static void navigateToChatList(BuildContext context) {
    Navigator.pushNamed(context, chatList);
  }

  static void navigateToChat(BuildContext context, ChatRoom chatRoom) {
    Navigator.pushNamed(context, chat, arguments: chatRoom);
  }

  static void navigateToCreateGroupChat(BuildContext context) {
    Navigator.pushNamed(context, createGroupChat);
  }
}
