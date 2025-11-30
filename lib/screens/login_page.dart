import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportnet/screens/homepage.dart';
// import 'package:sportnet/screens/register_page.dart';

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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // stack untuk menumpuk background image & card
      body: Stack(
        children: [
          Container(
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_bg.png'), 
                fit: BoxFit.cover,
              ),
            ),
          ),

          // layer tengah
          Container(
            height: size.height,
            width: size.width,
            color: Colors.black.withValues(alpha: 0.1),
          ),

          // layer paling depan
          Center(
            child: SingleChildScrollView(
              child: Container(
                // lebar card agar tidak terlalu mepet pinggir
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                decoration: BoxDecoration(
                  // frosted glass effect
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color:  _sportNetOrange,
                      )
                    ),
                    const SizedBox(height: 10),

                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                        children: [
                          const TextSpan(text: 'Welcome Back to '),
                          TextSpan(
                            text: 'SportNet',
                            style: TextStyle(
                              color: _sportNetOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // input username
                    _buildCustomTextField(
                      controller: _usernameController,
                      hintText: 'Enter your username',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),

                    // input password
                    _buildCustomTextField(
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

                          final response = await request.login(
                            "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/authenticate/api/login/", 
                            {
                              'username': username,
                              'password': password,
                            }
                          );

                          if(request.loggedIn){
                            String message = response['message'];
                            String uname = response['username'];

                            if(context.mounted){
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const HomePage()),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("$message Selamat datang, $uname.")),
                              );
                            }
                          } else{
                            if(context.mounted){
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Login Gagal'),
                                  content: Text(response(['message'] ?? "Cek Koneksi Internet.")),
                                  actions: [
                                    TextButton(
                                      child: const Text("OK"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
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
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  // widget bantuan
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400]) : null,
        filled: true,
        fillColor: Colors.white, // Latar belakang putih
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50), // Sangat bulat
          borderSide: BorderSide.none, // Hilangkan garis border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Color(0xFFFF7F50), width: 1.5), // Sedikit oranye saat diklik
        ),
      ),
    );
  }
}