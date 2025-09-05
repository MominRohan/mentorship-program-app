/*
Developer: SERGE MUNEZA
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_provider.dart';

class AdminSessionScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AdminSessionScreen> createState() => _AdminSessionScreenState();
}

class _AdminSessionScreenState extends ConsumerState<AdminSessionScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  // Fetch all sessions for admin
  Future<void> _loadSessions() async {
    await ref.read(sessionProvider.notifier).fetchAllSessions();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(title: Text("All Mentorship Sessions")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : sessionState.sessions.isEmpty
              ? Center(child: Text("No mentorship sessions found."))
              : RefreshIndicator(
                  onRefresh: _loadSessions, 
                  child: ListView.separated(
                    padding: EdgeInsets.all(12),
                    itemCount: sessionState.sessions.length,
                    separatorBuilder: (context, index) => Divider(), 
                    itemBuilder: (context, index) {
                      final session = sessionState.sessions[index];

                      String statusText;
                      Color statusColor;

                      switch (session.isApproved) {
                        case 1:
                          statusText = "✅ Approved";
                          statusColor = Colors.green;
                          break;
                        case -1:
                          statusText = "❌ Rejected";
                          statusColor = Colors.red;
                          break;
                        default:
                          statusText = "⏳ Pending";
                          statusColor = Colors.orange;
                          break;
                      }

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          title: Text("User: ${session.userEmail}", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Text("Mentor: ${session.mentorEmail}"),
                              Text("Questions: ${session.questions}"),
                            ],
                          ),
                          trailing: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
