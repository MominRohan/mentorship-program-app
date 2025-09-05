/*
Developer: SERGE MUNEZA
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bcrypt/bcrypt.dart';
import '../models/user.dart';
import '../services/db_helper.dart';

class AuthState {
  final User? user;
  final bool isAuthenticated;

  AuthState({this.user, this.isAuthenticated = false});

  AuthState copyWith({User? user, bool? isAuthenticated}) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  // Signup with Secure Password Storage
  Future<bool> signup(User newUser) async {
    try {
      String hashedPassword = BCrypt.hashpw(newUser.password.trim(), BCrypt.gensalt());

      User securedUser = User(
        firstName: newUser.firstName.trim(),
        lastName: newUser.lastName.trim(),
        email: newUser.email.trim(),
        password: hashedPassword,
        address: newUser.address.trim(),
        bio: newUser.bio.trim(),
        occupation: newUser.occupation.trim(),
        expertise: newUser.expertise.trim(),
        role: newUser.role,
      );

      int result = await DBHelper.insertUser(securedUser);
      if (result > 0) {
        state = state.copyWith(user: securedUser, isAuthenticated: true);
        print("✅ Signup successful for: ${securedUser.email}");
        return true;
      }

      print("❌ Signup failed: Email already exists!");
      return false;
    } catch (e) {
      print("❌ Error in signup: $e");
      return false;
    }
  }

  // ✅ Login with Secure Password Check
  Future<bool> login(String email, String password) async {
    try {
      User? storedUser = await DBHelper.getUserByEmail(email.trim());
      if (storedUser == null) {
        print("❌ Login failed: User not found!");
        return false;
      }

      if (BCrypt.checkpw(password.trim(), storedUser.password)) {
        state = state.copyWith(user: storedUser, isAuthenticated: true);
        print("✅ Login successful for: ${storedUser.email}, Role: ${storedUser.role}");
        return true;
      }

      print("❌ Login failed: Incorrect password!");
      return false;
    } catch (e) {
      print("❌ Error in login: $e");
      return false;
    }
  }

  // ✅ Logout Function
  void logout() {
    state = AuthState();
    print("✅ User logged out successfully.");
  }
}

// Provider definition
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
