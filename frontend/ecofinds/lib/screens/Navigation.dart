import 'dart:convert';

import 'package:ecofinds/screens/auth/login_screen.dart';
import 'package:ecofinds/screens/cart_screen.dart';
import 'package:ecofinds/screens/home_screen.dart';
import 'package:ecofinds/screens/mylisting.dart';
import 'package:ecofinds/screens/profile.dart';
import 'package:http/http.dart' as http;
import 'package:ecofinds/screens/purchase_history.dart';
import 'package:flutter/material.dart';
// import 'package:ecofinds/screens/cart/cart_screen.dart';
// import 'package:ecofinds/screens/product/my_listings.dart';
// import 'package:ecofinds/screens/purchase/purchase_history.dart';
// import 'package:ecofinds/screens/profile/edit_profile.dart';
import 'package:ecofinds/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
  const SizedBox(height: 32),

            // Navigation List
            _buildNavItem(
              context,
              icon: Icons.home,
              label: 'Home',
              onTap: () => {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              )
              },
            ),
            _buildNavItem(
              context,
              icon: Icons.person,
              label: 'Update Profile',
              onTap: () => {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UpdateProfileScreen()),
              )
              },
            ),
            _buildNavItem(
              context,
              icon: Icons.inventory,
              label: 'My Listings',
              onTap: () => {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyListingsScreen()),
              )
              },
            ),
            _buildNavItem(
              context,
              icon: Icons.shopping_cart,
              label: 'Cart',
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                )
              },
            ),
            _buildNavItem(
              context,
              icon: Icons.history,
              label: 'Purchase History',
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PurchaseHistoryScreen()),
                )
              },
            ),
            // _buildNavItem(
            //   context,
            //   icon: Icons.edit,
            //   label: 'Edit Profile',
            //   onTap: () =>{
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            //     // )
            //   },
            // ),
            _buildNavItem(
              context,
              icon: Icons.logout,
              label: 'Logout',
              onTap: () {
                SharedPreferences.getInstance().then((prefs) {
                  prefs.remove('user_id'); // Remove user ID from shared preferences
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                });
                // TODO: Handle logout properly
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
