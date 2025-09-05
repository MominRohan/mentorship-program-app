/*
Developer: SERGE MUNEZA
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/session_provider.dart';
import '../models/mentor.dart';

class RequestSessionScreen extends ConsumerStatefulWidget {
  final Mentor mentor;

  RequestSessionScreen({required this.mentor});

  @override
  ConsumerState<RequestSessionScreen> createState() => _RequestSessionScreenState();
}

class _RequestSessionScreenState extends ConsumerState<RequestSessionScreen> {
  final TextEditingController _questionsController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Request Session")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mentor: ${widget.mentor.name}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _questionsController,
              decoration: InputDecoration(labelText: "Enter your questions"),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      await ref.read(sessionProvider.notifier).requestSession(
                        authState.user!.email,
                        widget.mentor.email,
                        _questionsController.text.trim(),
                      );
                      setState(() => _isLoading = false);

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Session request sent!")));
                      Navigator.pop(context);
                    },
                    child: Text("Request Session"),
                  ),
          ],
        ),
      ),
    );
  }
}
