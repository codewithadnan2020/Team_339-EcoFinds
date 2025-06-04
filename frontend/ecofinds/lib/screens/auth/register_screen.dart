import 'dart:convert';

import 'package:ecofinds/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool nameError = false;
  String nameErrorMsg = '';
  bool emailError = false;
  String emailErrorMsg = '';
  bool passwordError = false;
  String passwordErrorMsg = '';

  bool isLoading = false;

  void handleRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {

        if (name.isEmpty) {
          nameError = true;
          nameErrorMsg = "All fields are required";
        } else {
          nameError = false;
          nameErrorMsg = "";
        }
        if (email.isEmpty) {
          emailError = true;
          emailErrorMsg = "All fields are required";
        } else if(emailValidator(email) == false) {
          emailError = true;
          emailErrorMsg = "Please Enter a valid Email ID";
        } else{
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
      // Fluttertoast.showToast(msg: "All fields are required");
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse('$baseUrl/auth/register.php');
    final response = await http.post(
      url,
      body: {
        "username": name,
        "email": email,
        "password": password,
      },
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userId = data['userId'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      Fluttertoast.showToast(msg: "Registration successful");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'Registration failed';
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
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
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
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(AppColors.primary),
                    foregroundColor: WidgetStatePropertyAll(Colors.white)
                  ),
                  onPressed: isLoading ? null : handleRegister,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
