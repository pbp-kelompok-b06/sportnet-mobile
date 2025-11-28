import 'package:flutter/material.dart';
import '../screens/homepage.dart';

// --- MAIN APPLICATION WIDGET ---

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Custom orange color inferred from the design
    const Color primaryOrange = Color(0xFFF0544F); 

    return MaterialApp(
      title: 'SportNet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryOrange,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}