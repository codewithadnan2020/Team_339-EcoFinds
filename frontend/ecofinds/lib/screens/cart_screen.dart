import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:ecofinds/models/product.dart';
// import 'package:ecofinds/services/cart_service.dart';
import 'package:ecofinds/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      // final data = await CartService().fetchCart();
      final response =
          await http.get(Uri.parse('$baseUrl/cart/view.php?user_id=$userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Cart data: $data');
        setState(() {
          _cartItems = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load cart')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cart: $e')),
      );
    }
  }

  // void _updateQuantity(Product product, int delta) async {
  //   final newQty = (_cartItems[product] ?? 1) + delta;
  //   if (newQty < 1) return;

  //   setState(() => _cartItems[product] = newQty);
  //   await CartService().updateQuantity(product.id, newQty);
  // }

  // void _removeFromCart(Product product) async {
  //   setState(() => _cartItems.remove(product));
  //   await CartService().removeItem(product.id);
  // }

  double _calculateTotal() {
    return 0;
    // return _cartItems.entries.fold(
    //   0,
    //   (sum, item) => sum + (item.key.price * item.value),
    // );
  }

  void _checkout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    final response =
        await http.post(Uri.parse('$baseUrl/purchases/checkout.php'), body: {
      "user_id": userId,
    });
    print(response.statusCode);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['error'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checkout successful!')),
        );
        setState(() => _cartItems.clear());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checkout failed.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to checkout')),
      );
    }
    // final success = await CartService().checkoutCart();
    // if (success) {
    //   setState(() => _cartItems.clear());
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Checkout successful!')),
    //   );
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Checkout failed.')),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? const Center(child: Text('Your cart is empty.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final product = _cartItems[index];
                          return ListTile(
                            leading: product["image_url"] != null
                                ? Image.network(product["image_url"]!,
                                    width: 50, height: 50)
                                : const Icon(Icons.image, size: 50),
                            title: Text(product["title"]),
                            subtitle: Text('₹${product["price"]} × 1'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // IconButton(
                                //   onPressed: () => _removeFromCart(product),
                                //   icon: const Icon(Icons.delete, color: Colors.red),
                                // ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                            icon: const Icon(Icons.shopping_bag),
                            label: const Text('Checkout'),
                            onPressed: _checkout,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
