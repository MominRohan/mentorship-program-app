/*
Developer: Momin Rohan
 */

import 'package:flutter/material.dart';
import '../models/mentor.dart';
import 'welcome_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'mentor_list_screen.dart';
import 'promote_mentor_screen.dart';
import 'session_history_screen.dart';
import 'admin_session_screen.dart';
import 'approve_session_screen.dart';
import 'mentor_detail_screen.dart';
import 'request_session_screen.dart';

class AppRoutes {
  // Route names
  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String mentors = '/mentors';
  static const String promote = '/promote';
  static const String sessionHistory = '/session_history';
  static const String adminSessions = '/admin_sessions';
  static const String approveSessions = '/approve_sessions';
  static const String mentorDetail = '/mentor_detail';
  static const String requestSession = '/request_session';

  // Route map
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      welcome: (context) => WelcomeScreen(),
      login: (context) => LoginScreen(),
      signup: (context) => SignupScreen(),
      mentors: (context) => MentorListScreen(),
      promote: (context) => PromoteMentorScreen(),
      sessionHistory: (context) => SessionHistoryScreen(),
      adminSessions: (context) => AdminSessionScreen(),
      approveSessions: (context) => ApproveSessionScreen(),
    };
  }

  // Generate route method for dynamic routes (with parameters)
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mentorDetail:
        // Expecting mentor object as argument
        final mentor = settings.arguments;
        if (mentor != null && mentor is Mentor) {
          return MaterialPageRoute(
            builder: (context) => MentorDetailScreen(mentor: mentor),
            settings: settings,
          );
        }
        return _errorRoute();
      
      case requestSession:
        // Expecting mentor object as argument
        final mentor = settings.arguments;
        if (mentor != null && mentor is Mentor) {
          return MaterialPageRoute(
            builder: (context) => RequestSessionScreen(mentor: mentor),
            settings: settings,
          );
        }
        return _errorRoute();
      
      default:
        return null; // Let the regular routes handle it
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

  // Navigation helper methods
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, login);
  }

  static void navigateToSignup(BuildContext context) {
    Navigator.pushNamed(context, signup);
  }

  static void navigateToMentors(BuildContext context) {
    Navigator.pushReplacementNamed(context, mentors);
  }

  static void navigateToMentorDetail(BuildContext context, dynamic mentor) {
    Navigator.pushNamed(context, mentorDetail, arguments: mentor);
  }

  static void navigateToPromote(BuildContext context) {
    Navigator.pushNamed(context, promote);
  }

  static void navigateToSessionHistory(BuildContext context) {
    Navigator.pushNamed(context, sessionHistory);
  }

  static void navigateToAdminSessions(BuildContext context) {
    Navigator.pushNamed(context, adminSessions);
  }

  static void navigateToApproveSessions(BuildContext context) {
    Navigator.pushNamed(context, approveSessions);
  }

  static void navigateToWelcome(BuildContext context) {
    Navigator.pushReplacementNamed(context, welcome);
  }

  static void navigateToRequestSession(BuildContext context, Mentor mentor) {
    Navigator.pushNamed(context, requestSession, arguments: mentor);
  }
}
