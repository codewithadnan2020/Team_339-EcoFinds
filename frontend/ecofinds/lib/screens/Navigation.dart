import 'package:ecofinds/screens/auth/login_screen.dart';
import 'package:ecofinds/screens/cart_screen.dart';
import 'package:ecofinds/screens/mylisting.dart';
import 'package:ecofinds/screens/purchase_history.dart';
import 'package:flutter/material.dart';
// import 'package:ecofinds/screens/cart/cart_screen.dart';
// import 'package:ecofinds/screens/product/my_listings.dart';
// import 'package:ecofinds/screens/purchase/purchase_history.dart';
// import 'package:ecofinds/screens/profile/edit_profile.dart';
import 'package:ecofinds/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy user data – replace with real data later
    final userName = 'John Doe';
    final userEmail = 'john@example.com';
    final profileInitials = userName.isNotEmpty ? userName[0] : '?';

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
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    profileInitials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(userEmail),
                  ],
                )
              ],
            ),
            const SizedBox(height: 32),

            // Navigation List
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
