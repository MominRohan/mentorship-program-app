/*
Developer: SERGE MUNEZA
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String role = "user"; // Default role

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
         
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: "First Name",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter your first name" : null,
              ),

             
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: "Last Name",
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter your last name" : null,
              ),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return "Enter your email";
                  if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                      .hasMatch(value)) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                obscureText: true,
                validator: (value) => value!.length < 6
                    ? "Password must be at least 6 characters"
                    : null,
              ),

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter your address" : null,
              ),

              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: "Bio",
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => value!.isEmpty ? "Enter your bio" : null,
              ),

              TextFormField(
                controller: _occupationController,
                decoration: InputDecoration(
                  labelText: "Occupation",
                  prefixIcon: Icon(Icons.work),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter your occupation" : null,
              ),

              TextFormField(
                controller: _expertiseController,
                decoration: InputDecoration(
                  labelText: "Expertise",
                  prefixIcon: Icon(Icons.star),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter your expertise" : null,
              ),


              _buildRoleDropdown(),

              SizedBox(height: 20),

              _buildSignupButton(),

              SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text("Already have an account? Log in"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        obscureText: isObscure,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: DropdownButtonFormField<String>(
        value: role,
        decoration: InputDecoration(
          labelText: "Select Role",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: ["user", "admin"].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value.toUpperCase()),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            role = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildSignupButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)), // Rounded button
      ),
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
        
          FocusScope.of(context).unfocus();

          User newUser = User(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            address: _addressController.text,
            bio: _bioController.text,
            occupation: _occupationController.text,
            expertise: _expertiseController.text,
            role: role,
          );

          bool success = await ref.read(authProvider.notifier).signup(newUser);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Signup successful! Please log in.")),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Signup failed. Email already exists.")),
            );
          }
        }
      },
      child: Text("Sign Up",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
