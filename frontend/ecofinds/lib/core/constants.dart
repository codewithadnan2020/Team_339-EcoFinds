import 'package:flutter/material.dart';

/// App colors used throughout the app
class AppColors {
  static const Color primary = Color(0xFF4CAF50); // Green shade for eco-friendly vibes
  static const Color primaryDark = Color(0xFF388E3C);
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

const String baseUrl = "http://192.168.152.110/ecofinds/api";