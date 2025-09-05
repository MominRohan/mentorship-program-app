/*
Developer: SERGE MUNEZA
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mentor_provider.dart';

class PromoteMentorScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<PromoteMentorScreen> createState() => _PromoteMentorScreenState();
}

class _PromoteMentorScreenState extends ConsumerState<PromoteMentorScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    await ref.read(mentorProvider.notifier).fetchUsers();
    await ref.read(mentorProvider.notifier).fetchMentors();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mentorState = ref.watch(mentorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Promote Users to Mentor"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : mentorState.users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No users available.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: mentorState.users.length,
                  itemBuilder: (context, index) {
                    final user = mentorState.users[index];
                    final bool isAlreadyMentor = mentorState.mentors.any((mentor) => mentor.email == user.email);

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(user.firstName + " " + user.lastName),
                        subtitle: Text(user.email),
                        trailing: isAlreadyMentor
                            ? Text("✅ Promoted", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                            : ElevatedButton(
                                onPressed: () async {
                                  await ref.read(mentorProvider.notifier).promoteUserToMentor(user.email);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("${user.email} promoted to mentor!")),
                                  );
                                  setState(() => _isLoading = true);
                                  await _loadUsers();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFBA8900), // primaryColor
                                  foregroundColor: Colors.white,
                                ),
                                child: Text("Promote"),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
