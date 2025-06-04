import 'dart:convert';

import 'package:ecofinds/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool emailError = false;
  String emailErrorMsg = '';
  bool passwordError = false;
  String passwordErrorMsg = '';

  bool isLoading = false;

  void handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        if (email.isEmpty) {
          emailError = true;
          emailErrorMsg = "All fields are required";
        } else if(emailValidator(email) == false) {
          emailError = true;
          emailErrorMsg = "Please Enter a valid Email ID";
        }else{
          emailError = false;
          emailErrorMsg = "";
        }
        if (password.isEmpty) {
          passwordError = true;
          passwordErrorMsg = "All fields are required";
        } else {
          passwordError = false;
          passwordErrorMsg = "";
        }
      });
      // Fluttertoast.showToast(msg: "All fields are required");
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse('$baseUrl/auth/login.php');
    final response = await http.post(
      url,
      body: {"email": email, "password": password},
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userId = data['userId'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      Fluttertoast.showToast(msg: "Login successful");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'Login failed';
      setState(() {
        passwordError = true;
        passwordErrorMsg = error.toString();
      });
      // Fluttertoast.showToast(msg: error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            Visibility(
              visible: emailError,
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(emailErrorMsg,
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            Visibility(
              visible: passwordError,
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(passwordErrorMsg,
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Color(0xFF4CAF50)),
                    foregroundColor: WidgetStatePropertyAll(Colors.white)),
                onPressed: isLoading ? null : handleLogin,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Don't have an account? Register"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
