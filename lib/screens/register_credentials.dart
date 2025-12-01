import 'package:flutter/material.dart';
import 'package:sportnet/screens/register_profile.dart';
import 'package:sportnet/widgets/auth_background.dart';
import 'package:sportnet/widgets/custom_textfield.dart';
import 'package:sportnet/screens/login_page.dart';

class RegisterCredentials extends StatefulWidget {
  final String role;
  const RegisterCredentials({super.key, required this.role});

  @override
  State<RegisterCredentials> createState() => _RegisterCredentialsState();
}

class _RegisterCredentialsState extends State<RegisterCredentials>{
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context){
    String title = widget.role == 'organizer'
      ? "Create Organizer Account"
      : "Create SportNext Account";

      return AuthBackground(
        title: title,
        subtitle: "First, let's set up your login details.",
        imagePath: 'assets/image/register_bg.jpg',

        child: Column(
          children: [
            // input username
            CustomTextField(
              controller: _usernameController, 
              hintText: "Enter your username",
              icon: Icons.person,
            ),
            const SizedBox(height: 16),

            // input password
            CustomTextField(
              controller: _passwordController, 
              hintText: "Choose a strong password",
              icon: Icons.lock,
              isPassword: true,
            ),
            const SizedBox(height: 16),

            // confirm password field
            CustomTextField(
              controller: _confirmController, 
              hintText: "Confirm your password",
              icon: Icons.lock_clock,
              isPassword: true,
            ),
            const SizedBox(height: 30),

            SizedBox(
            width: 150,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mohon isi semua data")));
                  return;
                }
                if (_passwordController.text != _confirmController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password tidak sama")));
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterProfile(
                      role: widget.role,
                      username: _usernameController.text,
                      password: _passwordController.text,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7F50),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              child: const Text("Next", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildDot(false), _buildDot(true), _buildDot(false)],
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
              GestureDetector(
                onTap: () {
                   Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                },
                child: const Text("Sign In", style: TextStyle(color: Color(0xFFFF7F50), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      )
    );
  }

  Widget _buildDot(bool isActive) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 20 : 10, height: 10,
      decoration: BoxDecoration(color: isActive ? const Color(0xFFFF7F50) : Colors.grey[300], borderRadius: BorderRadius.circular(10)),
  );
}