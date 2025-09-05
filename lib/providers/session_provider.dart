/*
Developer: SERGE MUNEZA
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session.dart';
import '../services/db_helper.dart';

class SessionState {
  final List<MentorshipSession> sessions;

  SessionState({this.sessions = const []});

  SessionState copyWith({List<MentorshipSession>? sessions}) {
    return SessionState(
      sessions: sessions ?? this.sessions,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(SessionState());

  // ✅ Request a Mentorship Session
  Future<void> requestSession(String userEmail, String mentorEmail, String questions) async {
    MentorshipSession newSession = MentorshipSession(
      userEmail: userEmail,
      mentorEmail: mentorEmail,
      questions: questions,
    );

    await DBHelper.requestSession(newSession);
    await fetchUserSessions(userEmail); // ✅ Refresh user session history
  }

  // ✅ Fetch Sessions for a Mentor
  Future<void> fetchMentorSessions(String mentorEmail) async {
    final sessions = await DBHelper.getMentorSessions(mentorEmail);
    state = state.copyWith(sessions: sessions);
  }

  // ✅ Fetch Sessions for a User
  Future<void> fetchUserSessions(String userEmail) async {
    final sessions = await DBHelper.getUserSessions(userEmail);
    state = state.copyWith(sessions: sessions);
  }

  // ✅ Fetch All Sessions (For Admin)
  Future<void> fetchAllSessions() async {
    final sessions = await DBHelper.getAllSessions();
    state = state.copyWith(sessions: sessions);
  }

  // Approve a session & refresh list
  Future<void> approveSession(int sessionId, String mentorEmail) async {
    await DBHelper.approveSession(sessionId);
    await fetchMentorSessions(mentorEmail); // Refresh after approval
  }

  // Reject a session & refresh list
  Future<void> rejectSession(int sessionId, String mentorEmail) async {
    await DBHelper.rejectSession(sessionId);
    await fetchMentorSessions(mentorEmail); // Refresh after rejection
  }
}

// Provider definition
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier();
});
