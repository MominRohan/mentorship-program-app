/*
Developer: Momin Rohan
Example Navigation Screen - Shows how to navigate to verification screens
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'verification_method_screen.dart';

class ExampleNavigationScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verification Example'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Firebase Verification Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            
            // Example navigation button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToVerification(context),
                icon: Icon(Icons.verified_user),
                label: Text('Start Verification Process'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            Text(
              'This will demonstrate both phone and email verification using Firebase Authentication.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToVerification(BuildContext context) {
    // Navigate to verification method selection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationMethodScreen(
          userEmail: "user@example.com",
          userPhone: "+1234567890",
          userName: "John Doe",
        ),
      ),
    );
  }
}
