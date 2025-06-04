import 'dart:convert';
import 'package:ecofinds/screens/home_screen.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ecofinds/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cvcController = TextEditingController();
  final _expiryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cardNumberController.dispose();
    _cvcController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getExistingProfile();
  }

  void getExistingProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    final response =
        await http.post(Uri.parse('$baseUrl/users/profile.php'), body: {
      'user_id': userId ?? '',
    });
    print(response.statusCode);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _nameController.text = data['username'];
        _emailController.text = data['email'];
        _cardNumberController.text = data['card_number'];
        _cvcController.text = data['cvc_number'];
        _expiryController.text = data['expiry'];
      });
    }
  }

  void updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    final response = await http.post(
      Uri.parse('$baseUrl/users/update.php'),
      body: {
        'user_id': userId,
        'username': _nameController.text.toString(),
        'email': _emailController.text.toString(),
        'card_number': _cardNumberController.text.toString(),
        'cvc_number': _cvcController.text.toString(),
        'expiry': _expiryController.text.toString(),
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Updated!')),
      );
      print('response');
      print(response.body.toString());
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HomeScreen();
      }));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Personal Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              const Text('Credit Card Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter card number';
                  }
                  if (value.length != 16) {
                    return 'Card number must be 16 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cvcController,
                      decoration: const InputDecoration(
                        labelText: 'CVC',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter CVC';
                        }
                        if (value.length < 3) {
                          return 'CVC must be 3 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry (MM/YY)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                        LengthLimitingTextInputFormatter(5),
                        ExpiryDateTextInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter expiry';
                        }
                        if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$')
                            .hasMatch(value)) {
                          return 'Invalid format (MM/YY)';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: const ButtonStyle(
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)))),
                      backgroundColor:
                          WidgetStatePropertyAll(AppColors.primary),
                      foregroundColor: WidgetStatePropertyAll(Colors.white)),
                  onPressed: () {
                    // TODO: Implement update logic
                    if (_formKey.currentState!.validate()) {
                      updateProfile();
                    }
                  },
                  child: const Text('Update Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add this class in the same file or in a utils file
class ExpiryDateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (text.length == 2 && oldValue.text.length == 1) {
      text += '/';
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
