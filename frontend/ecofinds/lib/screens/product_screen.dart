import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';

class ProductDetail extends StatefulWidget {
  final String productId;

  const ProductDetail({super.key, required this.productId});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  Map _product = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  void _fetchProduct() async {
    print('asdasdas');
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      print('asdasdas1');
      final response = await http.get(
          Uri.parse('$baseUrl/products/details.php?id=${widget.productId}'));
      print('asdasdas');
      print('response ${response.statusCode}');
      if (response.statusCode == 200) {
        setState(() {
          final data = jsonDecode(response.body);
          _product = data;
          print('hiiiii');
          print('hiiiii');
          print('hiiiii');
          print('hiiiii');
        });
      } else {
        setState(() => _errorMessage = 'Failed to load product');
      }
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load product');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addToCart(productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    print('incoming here');
    final response = await http.post(Uri.parse('$baseUrl/cart/add.php'), body: {
      "product_id": productId,
      "user_id": userId,
    });
    print({
      "product_id": productId,
      "user_id": userId,
    });
    print('${response.statusCode}');

    if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(jsonDecode(response.body)["message"])),
                  );
    } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(jsonDecode(response.body)["error"])),
                  );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_product['title'])),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              width: double.infinity,
              height: 250,
              child: Image.network(
                _product['image_url'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.broken_image, size: 60)),
              ),
            ),

            const SizedBox(height: 16),

            // Name & Price
            Text(
              _product['title'],
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: 8),
            Text(
              "\Rs.${_product['price'].toString()}",
              style: AppTextStyles.priceText,
            ),

            const SizedBox(height: 16),

            // Description
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _product['description'],
                  style: AppTextStyles.bodyText,
                ),
              ),
            ),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // cartProvider.addItem(_product!);
                  _addToCart(widget.productId);
                },
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
