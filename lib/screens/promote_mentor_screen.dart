/*
Developer: SERGE MUNEZA
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mentor_provider.dart';
import '../models/user.dart';

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
      appBar: AppBar(title: Text("Promote Users to Mentor")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : mentorState.users.isEmpty
              ? Center(child: Text("No users available."))
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
                                child: Text("Promote"),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
