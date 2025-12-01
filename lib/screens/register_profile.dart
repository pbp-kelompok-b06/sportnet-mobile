import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportnet/screens/login_page.dart';
import 'package:sportnet/widgets/auth_background.dart';
import 'package:sportnet/widgets/custom_textfield.dart';


class RegisterProfile extends StatefulWidget{
  final String role;
  final String username;
  final String password;

  const RegisterProfile({
    super.key,
    required this.role,
    required this.username,
    required this.password,
  });

  @override
  State<RegisterProfile> createState() => _RegisterProfileState();
}

class _RegisterProfileState extends State<RegisterProfile>{
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _extraController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 17)), // Default umur 17 thn
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Kustomisasi warna date picker agar sesuai tema oranye
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF7F50), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF7F50), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Ubah format tanggal jadi YYYY-MM-DD untuk ditampilkan di textfield
        _extraController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context){
    final request = context.watch<CookieRequest>();
    String title = widget.role == 'organizer' ? "Organizer Detail" : "Profile Details";

    return AuthBackground(
      title: title,
      subtitle: "Complete your information",
      imagePath: 'assets/image/register_bg.jpg',

      child: Column(
        children: [
          CustomTextField(
            controller: _nameController, 
            hintText: widget.role == 'organizer' ? "Organizer Name" : "Full Name", 
            icon: Icons.badge
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _contactController, 
            hintText: widget.role == 'organizer' ? "Contact Email" : "Your City", 
            icon: widget.role == 'organizer' ? Icons.email : Icons.location_city,
            keyboardType: widget.role == 'organizer' ? TextInputType.emailAddress : TextInputType.text,
          ),
          const SizedBox(height: 16),

          if (widget.role == 'participant') ...[
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: CustomTextField(
                  controller: _extraController,
                  hintText: "Birth Date (YYYY-MM-DD)", 
                  icon: Icons.calendar_today,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ] else ...[
             const SizedBox(height: 30),
          ],

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isEmpty ||
                    _contactController.text.isEmpty ||
                    _extraController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Semua data wajib diisi!")),
                  );
                  return;
                }
                
                try {
                  final response = await request.postJson(
                    "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/authenticate/api/register/",
                    jsonEncode({
                      'username': widget.username,
                      'password': widget.password,
                      'role': widget.role,
                      'email': '', // Default kosong

                      if (widget.role == 'participant') ...{
                        'full_name': _nameController.text,
                        'location': _contactController.text,
                        'interests': _extraController.text,
                        'birth_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        'about': '-',
                      } else ...{
                        'organizer_name': _nameController.text,
                        'contact_email': _contactController.text,
                        'contact_phone': _extraController.text,
                        'email': _contactController.text,
                        'about': '-',
                      }
                    })
                  );

                  if (context.mounted) {
                    if (response['status'] == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Registrasi Berhasil! Silakan Login."),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response['message'] ?? "Registrasi Gagal"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Terjadi kesalahan koneksi: $e")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7F50),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 5,
              ),
              child: const Text(
                "Create Account",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          // Dots Indicator
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildDot(false), _buildDot(false), _buildDot(true)]),
          const SizedBox(height: 24),
          // Link ke Login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
              GestureDetector(
                onTap: () {
                   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
                },
                child: const Text("Sign In", style: TextStyle(color: Color(0xFFFF7F50), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 20 : 10, height: 10,
      decoration: BoxDecoration(color: isActive ? const Color(0xFFFF7F50) : Colors.grey[300], borderRadius: BorderRadius.circular(10)),
  );
}