import 'dart:convert';
import 'dart:math';
import 'package:ecofinds/screens/cart_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App colors used throughout the app
class AppColors {
  // static const Color primary = Color(0xFF4CAF50); // Green shade for eco-friendly vibes
  static const Color primary =
      Color.fromARGB(255, 76, 99, 175); // Green shade for eco-friendly vibes
  static const Color primaryDark = Color.fromARGB(255, 56, 82, 142);
  static const Color accent = Color(0xFFFFC107); // Amber for highlights
  static const Color background = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color buttonText = Colors.white;
  static const Color bannerBackground = Color(0xFFE8F5E9);
}

/// Common text styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  static const TextStyle priceText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.green,
  );
}

/// API endpoints (mock or real)
class ApiEndpoints {
  static const String baseUrl = "https://api.ecofinds.com";
  static const String products = "$baseUrl/products";
  static const String categories = "$baseUrl/categories";
  static const String cart = "$baseUrl/cart";
  // Add other endpoints here
}

/// Categories (used for category chips)
const List<String> categoriesList = [
  "All",
  "Clothing",
  "Accessories",
  "Home",
  "Electronics",
  "Books",
  "Toys",
  "Garden",
  "Beauty",
];

/// Banner images (local assets or URLs)
const List<String> bannerImages = [
  "assets/images/banner1.png",
  "assets/images/banner2.png",
  "assets/images/banner3.png",
];

/// Other constants
const double defaultPadding = 16.0;
const double borderRadius = 12.0;

const String baseUrl = "http://192.168.242.110/ecofinds/api";

Future<int> getCartCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_id');
  final response =
      await http.get(Uri.parse('$baseUrl/cart/view.php?user_id=$userId'));
  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);
    return data.length;
  }
  return 0;
}

bool emailValidator(email) {
  return RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
  ).hasMatch(email);
}
 void updateCartCount() async {
  }
Widget CartCount(context, cartCount) {
  return Stack(
    alignment: Alignment.topRight,
    children: [
      IconButton(
        icon: const Icon(Icons.shopping_cart),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CartScreen(),
            ),
          );

          int count = await getCartCount();
          cartCount = count; 
        },
      ),
      if (cartCount != null && cartCount! > 0)
        Positioned(
          right: 4,
          top: 2,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(50),
            ),
            constraints: const BoxConstraints(
              minWidth: 10,
              minHeight: 5,
            ),
            child: Text(
              '$cartCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
    ],
  );
}
