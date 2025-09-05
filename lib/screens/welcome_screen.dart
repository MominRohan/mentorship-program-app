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
                "Welcome to Path with Purpose ",
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
                  "Discover Your Path with Purpose\n"
                      "Explore careers, build essential skills, and connect with mentors and peers worldwide. Start your journey today and shape the future with confidence.",

                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),

              SizedBox(height: 160),

              _buildButton(context, "Log In", () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              }),

              SizedBox(height: 15),

              _buildButton(context, "Sign Up", () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignupScreen()));
              }),

              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildButton(BuildContext context, String text, VoidCallback onTap) {
    return SizedBox(
      width: 250, // ✅ fixed width
      height: 55, // ✅ fixed height
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Rounded buttons
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
