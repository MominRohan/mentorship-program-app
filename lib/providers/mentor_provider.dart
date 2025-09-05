/*
Developer: SERGE MUNEZA
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mentor.dart';
import '../models/user.dart';
import '../services/db_helper.dart';

class MentorState {
  final List<User> users;
  final List<Mentor> mentors;

  MentorState({this.users = const [], this.mentors = const []});

  MentorState copyWith({List<User>? users, List<Mentor>? mentors}) {
    return MentorState(
      users: users ?? this.users,
      mentors: mentors ?? this.mentors,
    );
  }
}

class MentorNotifier extends StateNotifier<MentorState> {
  MentorNotifier() : super(MentorState());

  // Fetch all users (Only admins)
  Future<void> fetchUsers() async {
    try {
      final users = await DBHelper.getAllUsers();
      state = state.copyWith(users: users);
    } catch (e) {
      print("❌ Error fetching users: $e");
    }
  }

  // Fetch all mentors
  Future<void> fetchMentors() async {
    try {
      final mentors = await DBHelper.getAllMentors();
      state = state.copyWith(mentors: mentors);
    } catch (e) {
      print("❌ Error fetching mentors: $e");
    }
  }

  // Promote user to mentor
  Future<void> promoteUserToMentor(String email) async {
    try {
      // Check if the user is already a mentor
      User? user = state.users.firstWhere(
        (u) => u.email == email,
        orElse: () => User(email: "", firstName: "", lastName: "", password: "", address: "", bio: "", occupation: "", expertise: "", role: ""),
      );

      if (user.role == "mentor") {
        print("❌ User $email is already a mentor!");
        return;
      }

      int result = await DBHelper.promoteUserToMentor(email);
      if (result > 0) {
        print("✅ User promoted to mentor: $email");
        await fetchMentors();
        await fetchUsers();
      } else {
        print("❌ Failed to promote user: No matching email found!");
      }
    } catch (e) {
      print("❌ Error promoting user: $e");
    }
  }
}

// Provider definition
final mentorProvider = StateNotifierProvider<MentorNotifier, MentorState>((ref) {
  return MentorNotifier();
});
