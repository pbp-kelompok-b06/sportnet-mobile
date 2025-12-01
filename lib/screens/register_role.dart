import 'package:flutter/material.dart';
import 'package:sportnet/screens/register_credentials.dart';
import 'package:sportnet/widgets/auth_background.dart';

class RegisterRole extends StatelessWidget {
  const RegisterRole({super.key});

  @override
  Widget build(BuildContext context){
    return AuthBackground(
      title: "Join SportNet!",
      subtitle: "How would you like to get started?",
      imagePath: 'assets/image/register_bg.jpg',

      child: Column(
        children: [
          Row(
            children: [
              // organizer card
              Expanded(
                child: _buildRoleButton(
                  context,
                  "Organizer",
                  "Create Events",
                  Icons.event_note_rounded,
                  "organizer",
                ),
              ),
              const SizedBox(width: 16),
              // participant card
              Expanded(
                child: _buildRoleButton(
                  context,
                  "Participant",
                  "Join Sports",
                  Icons.directions_run_rounded,
                  "participant",
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildDot(true), _buildDot(false), _buildDot(false)],
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Already have an account? ",
                style: TextStyle(color: Colors.grey),
              ),
              GestureDetector(
                onTap: () {
                  // Karena halaman ini dibuka dari Login, cukup kembali
                  Navigator.pop(context); 
                },
                child: const Text(
                  "Sign In",
                  style: TextStyle(
                    color: Color(0xFFFF7F50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      )
    );
  }

  Widget _buildRoleButton(BuildContext context, String title, String subtitle, IconData icon, String role) {
    const color = Color(0xFFFF7F50); // Warna oranye
    
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman credentials
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterCredentials(role: role),
          ),
        );
      },
      child: Container(
        height: 160, // KUNCI UTAMA: Tinggi fix biar jadi kotak
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Icon dalam lingkaran
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            
            // 2. Judul (Organizer/Participant)
            Text(
              title,
              style: const TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: Colors.black87
              ),
            ),
            const SizedBox(height: 4),
            
            // 3. Subjudul Kecil
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 20 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFF7F50) : Colors.grey[300], // Ubah warna dikit biar keliatan di card putih
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}