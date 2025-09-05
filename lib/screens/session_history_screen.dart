/*
Developer: SERGE MUNEZA
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/session_provider.dart';

class SessionHistoryScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends ConsumerState<SessionHistoryScreen> {
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(sessionProvider.notifier).fetchUserSessions(user.email);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Session History")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : sessionState.sessions.isEmpty
              ? Center(child: Text("No past mentorship sessions."))
              : ListView.builder(
                  itemCount: sessionState.sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessionState.sessions[index];

                    String statusText;
                    Color statusColor;

                    if (session.isApproved == 1) {
                      statusText = "✅ Approved";
                      statusColor = Colors.green;
                    } else if (session.isApproved == -1) {
                      statusText = "❌ Rejected";
                      statusColor = Colors.red;
                    } else {
                      statusText = "⏳ Pending";
                      statusColor = Colors.orange;
                    }

                    return ListTile(
                      title: Text("Mentor: ${session.mentorEmail}"),
                      subtitle: Text(session.questions),
                      trailing: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
    );
  }
}
