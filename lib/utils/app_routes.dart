/*
Developer: Momin Rohan
*/

import 'package:flutter/material.dart';
import '../models/chat_room.dart';
import '../screens/chat_screen.dart';

class AppRoutes {
  static void navigateToChat(BuildContext context, ChatRoom chatRoom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatRoom: chatRoom),
      ),
    );
  }
}
