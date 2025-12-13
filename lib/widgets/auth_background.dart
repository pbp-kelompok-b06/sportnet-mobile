import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final String imagePath;

  const AuthBackground({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.imagePath = 'assets/image/login_bg.png',
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final Color sportNetOrange = const Color(0xFFFF7F50);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath), 
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(
            height: size.height,
            width: size.width,
            color: Colors.black.withValues(alpha: 0.2),
          ),

          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: sportNetOrange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 30),

                    child, 
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}