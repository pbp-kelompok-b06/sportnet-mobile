import 'package:flutter/material.dart';
import '../screens/homepage.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sportnet/models/bookmarks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Custom orange color inferred from the design
    const Color primaryOrange = Color(0xFFF0544F); 

    return MultiProvider(
      providers: [
        Provider<CookieRequest>(
          create: (_) => CookieRequest(),
        ),
        ChangeNotifierProvider<BookmarkProvider>(
          create: (_) => BookmarkProvider(),
        ),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}