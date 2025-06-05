import 'dart:convert';

import 'package:ecofinds/screens/Navigation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:ecofinds/screens/home_screen.dart';
import 'package:ecofinds/screens/product_screen.dart';
import 'package:ecofinds/screens/profile.dart';
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
  double _cartTotal = 0;
  late Razorpay _razorpay;

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
      final purchaseResponse = await http.post(
        Uri.parse('$baseUrl/purchases/checkout.php'),
        body: {
          'user_id': userId ?? '',
          // Add other required fields, e.g. cart items, total, etc.
        },
      );

      if (purchaseResponse.statusCode == 200) {
        // Simulate payment success
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Payment Successful'),
            content: const Text('Your payment was successful!'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close popup
                  setState(() => _cartItems.clear());
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Purchase failed. Please try again.')),
        );
      }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CartScreen();
    }));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    //
  }

  @override
  void initState() {
    super.initState();
    _loadCart();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openRazorpayCheckout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    var options = {
      'key': 'rzp_test_GRmGq7DTX159az',
      'amount': (_cartTotal * 100).toInt(), // Amount in paise!
      'name': userId,
      'description': "EcoFinds Payment",
      'prefill': {"contact": "8888888888", "email": "test@razorpay.com"}
    };
    try {
      print('Opening Razorpay...');
      _razorpay.open(options);
    } catch (e) {
      print('Error $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
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
          for (var cartItem in data) {
            _cartTotal += double.parse(cartItem["price"]);
          }
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
    // Card details exist, ask to proceed
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Proceed to Pay?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Do you want to proceed with the payment?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Pay'),
          ),
        ],
      ),
    );
    if (proceed == true) {
      openRazorpayCheckout();
      // Call your purchase API here
      // final purchaseResponse = await http.post(
      //   Uri.parse('$baseUrl/purchases/checkout.php'),
      //   body: {
      //     'user_id': userId ?? '',
      //     // Add other required fields, e.g. cart items, total, etc.
      //   },
      // );

      // if (purchaseResponse.statusCode == 200) {
      //   // Simulate payment success
      //   showDialog(
      //     context: context,
      //     builder: (context) => AlertDialog(
      //       title: const Text('Payment Successful'),
      //       content: const Text('Your payment was successful!'),
      //       actions: [
      //         ElevatedButton(
      //           onPressed: () {
      //             Navigator.pop(context); // Close popup
      //             setState(() => _cartItems.clear());
      //           },
      //           child: const Text('OK'),
      //         ),
      //       ],
      //     ),
      //   );
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //         content: Text('Purchase failed. Please try again.')),
      //   );
      // }
    }
  }

  void _removeFromCart(productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    final response =
        await http.post(Uri.parse('$baseUrl/cart/remove.php'), body: {
      "product_id": productId,
      "user_id": userId,
    });
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonDecode(response.body)["message"])),
      );
      Navigator.push(context, MaterialPageRoute(builder: (c) {
        return CartScreen();
      }));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonDecode(response.body)["error"])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            }, // Open side menu
          ),
          title: const Text('My Cart')),
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
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ProductDetail(productId: product["id"], productOwnerId: product["user_id"],);
                              }));
                            },
                            child: ListTile(
                              leading: product["image_url"] != null
                                  ? Image.network(
                                      '$baseUrl/products/${product["image_url"]}'!,
                                      width: 50,
                                      height: 50)
                                  : const Icon(Icons.image, size: 50),
                              title: Text(product["title"]),
                              subtitle: Text('₹${product["price"]}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _removeFromCart(product["id"]),
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19),
                                  ),
                                  Text(
                                    'Rs. ${_cartTotal.toString()}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(50),
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white),
                                icon: const Icon(Icons.shopping_bag),
                                label: const Text('Checkout'),
                                onPressed: _checkout,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
