import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportnet/screens/homepage.dart';
import 'package:sportnet/widgets/auth_background.dart';
import 'package:sportnet/screens/register_role.dart';
import 'package:sportnet/widgets/custom_textfield.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final Color _sportNetOrange = const Color(0xFFFF7F50);

  @override
  Widget build(BuildContext context){
    final request = context.watch<CookieRequest>();

    return AuthBackground(
      title: "Sign In",
      subtitle: "Welcome back to SportNet",
      imagePath: 'assets/image/login_bg.jpg',
      child: Column(
        children: [
          // input username
          CustomTextField(
            controller: _usernameController,
            hintText: 'Enter your username',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),

          // input password
          CustomTextField(
            controller: _passwordController,
            hintText: 'Enter your password',
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 40),

          // sign in button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                String username = _usernameController.text;
                String password = _passwordController.text;

                if(username.isEmpty || password.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Username dan password harus diisi!")),
                  );
                  return;
                }

                try {
                  final response = await request.postJson(
                  "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/authenticate/api/login/", 
                    jsonEncode({
                      'username': username,
                      'password': password,
                    }));  

                  if (response['status'] == 'success') {
                    
                    // Sukses
                    String message = response['message'];
                    String uname = response['username'];
                    
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("$message Selamat datang, $uname."),
                          backgroundColor: Colors.green, // Kasih warna hijau biar jelas
                        ),
                      );
                    }

                  } else {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Login Gagal'),
                          content: Text(response['message'] ?? "Cek username/password."),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Terjadi kesalahan: $e")),
                      );
                    }
                }
                // end logic login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _sportNetOrange, // Warna tombol
                foregroundColor: Colors.white, // Warna teks
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

          // text register
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style: TextStyle(color: Colors.grey),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterRole()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Arahkan ke Register Page")),
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