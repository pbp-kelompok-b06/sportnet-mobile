import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportnet/widgets/auth_background.dart';
import 'package:sportnet/widgets/custom_textfield.dart';
import 'package:sportnet/screens/authentication/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  final Color _sportNetOrange = const Color(0xFFFF7F50);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return AuthBackground(
      title: "Sign Up",
      subtitle: "Create your SportNet account",
      imagePath: 'assets/image/register_bg.jpg',
      child: Column(
        children: [
          // Username
          CustomTextField(
            controller: _usernameController,
            hintText: "Username",
            icon: Icons.person,
          ),
          const SizedBox(height: 16),

          // Password
          CustomTextField(
            controller: _passwordController,
            hintText: "Password",
            icon: Icons.lock,
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),

          const SizedBox(height: 30),

          // register button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                String username = _usernameController.text;
                String password = _passwordController.text;

                if (username.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Username dan Password wajib diisi!")),
                  );
                  return;
                }

                if (password.length < 8) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password minimal 8 karakter.")),
                  );
                  return;
                }

                try {
                  final response = await request.postJson(
                    "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/authenticate/api/register/",
                    jsonEncode({
                      'username': username,
                      'password': password,
                    }),
                  );

                  if (context.mounted) {
                    if (response['status'] == true) {
                      // Sukses -> Arahkan ke Login Page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Akun berhasil dibuat! Silakan Login."),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response['message'] ?? "Registration failed."),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _sportNetOrange,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 5,
              ),
              child: const Text(
                "Create Account",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
              GestureDetector(
                onTap: () {
                   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                },
                child: Text(
                  "Sign In",
                  style: TextStyle(color: _sportNetOrange, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}