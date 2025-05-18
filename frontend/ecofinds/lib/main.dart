import 'package:flutter/material.dart';
import 'package:ecofinds/core/constants.dart';
import 'package:ecofinds/screens/auth/login_screen.dart';
import 'package:ecofinds/screens/home/home_screen.dart';

void main() {
  runApp(const EcoFindsApp());
}

class EcoFindsApp extends StatelessWidget {
  const EcoFindsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoFinds',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
