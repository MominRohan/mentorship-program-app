/*
Developer: Momin Rohan
 */

import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
        ),
        child: SingleChildScrollView(
         
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 80),

              Image.asset(
                'assets/images/logo.png', 
                height: 160,
                width: 160,
              ),

              SizedBox(height: 20),

              Text(
                "Welcome to Career & Life Mentorship Program ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "PathWay to Purpose is a mobile application designed to connect young individuals with "
                  "experienced professionals for mentorship sessions."
                  "request mentorship, and interact with mentors.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),

              SizedBox(height:160),

              _buildButton(context, "Login", () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              }),

              SizedBox(height: 15),

              _buildButton(context, "Sign Up", () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignupScreen()));
              }),

              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildButton(BuildContext context, String text, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)), // Rounded buttons
      ),
      onPressed: onTap,
      child: Text(text,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
