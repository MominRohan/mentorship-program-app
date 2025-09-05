/*
Developer: Momin Rohan
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
  final TextEditingController _ageController = TextEditingController();
  String role = "mentee"; // Default role

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(17.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Role Selection (moved to top)
              _buildRoleDropdown(),
              
              SizedBox(height: 20),
              
              // Common fields for all roles
              _buildTextField(
                controller: _firstNameController,
                label: "First Name",
                icon: Icons.person,
                validator: (value) => value!.isEmpty ? "Enter your first name" : null,
              ),
              
              _buildTextField(
                controller: _lastNameController,
                label: "Last Name",
                icon: Icons.person_outline,
                validator: (value) => value!.isEmpty ? "Enter your last name" : null,
              ),
              
              _buildTextField(
                controller: _emailController,
                label: "Email",
                icon: Icons.email,
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
              
              _buildTextField(
                controller: _passwordController,
                label: "Password",
                icon: Icons.lock,
                isObscure: true,
                validator: (value) => value!.length < 6
                    ? "Password must be at least 6 characters"
                    : null,
              ),
              
              _buildTextField(
                controller: _confirmPasswordController,
                label: "Confirm Password",
                icon: Icons.lock_outline,
                isObscure: true,
                validator: (value) {
                  if (value!.isEmpty) return "Confirm your password";
                  if (value != _passwordController.text) return "Passwords do not match";
                  return null;
                },
              ),
              
              // Role-specific fields
              ..._buildRoleSpecificFields(),
              
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
                child: Text(
                  "Already have an account? Log in",
                ),
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
        items: ["mentee", "mentor", "admin"].map((String value) {
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
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          // Additional password confirmation check
          if (_passwordController.text != _confirmPasswordController.text) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Passwords do not match!")),
            );
            return;
          }
        
          FocusScope.of(context).unfocus();

          User newUser = User(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            address: role == 'mentee' ? '' : _addressController.text,
            bio: role == 'mentee' ? '' : _bioController.text,
            occupation: (role == 'mentor') ? _occupationController.text : '',
            expertise: (role == 'mentor') ? _expertiseController.text : '',
            role: role == 'mentee' ? 'user' : role,
            age: role == 'mentee' ? int.tryParse(_ageController.text) : null,
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

  List<Widget> _buildRoleSpecificFields() {
    List<Widget> fields = [];
    
    switch (role) {
      case 'admin':
        // Admin only needs basic fields (already included above)
        break;
        
      case 'mentor':
        fields.addAll([
          _buildTextField(
            controller: _occupationController,
            label: "Occupation",
            icon: Icons.work,
            validator: (value) => value!.isEmpty ? "Enter your occupation" : null,
          ),
          _buildTextField(
            controller: _expertiseController,
            label: "Expertise",
            icon: Icons.star,
            validator: (value) => value!.isEmpty ? "Enter your expertise" : null,
          ),
        ]);
        break;
        
      case 'mentee':
        fields.add(
          _buildTextField(
            controller: _ageController,
            label: "Age",
            icon: Icons.cake,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) return "Enter your age";
              int? age = int.tryParse(value);
              if (age == null || age < 13 || age > 100) {
                return "Enter a valid age (13-100)";
              }
              return null;
            },
          ),
        );
        break;
    }
    
    return fields;
  }
}
