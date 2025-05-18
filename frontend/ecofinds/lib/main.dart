import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'screens/splash_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
