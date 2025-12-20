import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportnet/screens/homepage.dart';
import 'package:sportnet/widgets/auth_background.dart';
import 'package:sportnet/screens/authentication/register_role.dart';
import 'package:sportnet/widgets/custom_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final Color _sportNetOrange = const Color(0xFFFF7F50);

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();

    return AuthBackground(
      title: "Sign In",
      subtitle: "Welcome back to SportNet",
      imagePath: 'assets/image/login_bg.jpg',
      child: Column(
        children: [
          // Username
          CustomTextField(
            controller: _usernameController,
            hintText: 'Enter your username',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),

          // Password
          CustomTextField(
            controller: _passwordController,
            hintText: "Enter your password",
            icon: Icons.lock,
            obscureText: !_isPasswordVisible,
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Sign In Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final username = _usernameController.text.trim();
                final password = _passwordController.text;

                if (username.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Username dan password harus diisi!"),
                    ),
                  );
                  return;
                }

                try {
                  // === LOGIN KE DJANGO (SESSION BASED) ===
                  final response = await request.login(
                    "http://127.0.0.1:8000/authenticate/api/login/",
                    {
                      'username': username,
                      'password': password,
                    },
                  );

                  if (response['status'] == 'success') {
                    // === SIMPAN USERNAME (PENTING) ===
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('username', username);

                    if (!context.mounted) return;

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Login berhasil. Selamat datang, $username!",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          response['message'] ?? "Login gagal.",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Login error: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _sportNetOrange,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 5,
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Register link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style: TextStyle(color: Colors.grey),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterRole(),
                    ),
                  );
                },
                child: Text(
                  "Register Now",
                  style: TextStyle(
                    color: _sportNetOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
