/*
Developer: SERGE MUNEZA
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/session_provider.dart';
import '../models/session.dart';

class ApproveSessionScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ApproveSessionScreen> createState() => _ApproveSessionScreenState();
}

class _ApproveSessionScreenState extends ConsumerState<ApproveSessionScreen> {
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      final mentor = ref.read(authProvider).user!;
      ref.read(sessionProvider.notifier).fetchMentorSessions(mentor.email).then((_) {
        setState(() => _isLoading = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Mentorship Requests")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : sessionState.sessions.isEmpty
              ? Center(child: Text("No pending session requests."))
              : ListView.builder(
                  itemCount: sessionState.sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessionState.sessions[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text("Request from: ${session.userEmail}"),
                        subtitle: Text(session.questions),
                        trailing: session.isApproved == 1
                            ? Text("✅ Approved", style: TextStyle(color: Colors.green))
                            : session.isApproved == -1
                                ? Text("❌ Rejected", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          setState(() => _isLoading = true);
                                          await ref.read(sessionProvider.notifier).approveSession(session.id!, session.mentorEmail);
                                          setState(() => _isLoading = false);
                                        },
                                        child: Text("Approve"),
                                      ),
                                      SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () async {
                                          setState(() => _isLoading = true);
                                          await ref.read(sessionProvider.notifier).rejectSession(session.id!, session.mentorEmail);
                                          setState(() => _isLoading = false);
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        child: Text("Reject"),
                                      ),
                                    ],
                                  ),
                      ),
                    );
                  },
                ),
    );
  }
}
