// auction_products_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:ecofinds/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuctionProductsScreen extends StatefulWidget {
  const AuctionProductsScreen({Key? key}) : super(key: key);

  @override
  State<AuctionProductsScreen> createState() => _AuctionProductsScreenState();
}

class _AuctionProductsScreenState extends State<AuctionProductsScreen> {
  late Future<List<dynamic>> _productsFuture;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _productsFuture = fetchProducts();
    // Update countdown every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<List<dynamic>> fetchProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    final url =
        Uri.parse('$baseUrl/products/auction_products.php?user_id=$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }
String getTimeLeft(String auctionEndTime) {
  try {
    final end = DateFormat('yyyy-MM-dd HH:mm').parse(auctionEndTime); // local time
    final now = DateTime.now();
    final diff = end.difference(now);
    if (diff.isNegative) return 'Auction ended';
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  } catch (e) {
    return 'Invalid time';
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Auctions')),
      body: FutureBuilder<List<dynamic>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final products = snapshot.data!;
          if (products.isEmpty) {
            return const Center(child: Text('No live auctions found.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              _productsFuture = fetchProducts();
              // Update countdown every second
              _timer = Timer.periodic(const Duration(seconds: 1), (_) {
                setState(() {});
              });
            },
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    leading: Image.network(
                      p['image_url'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(p['title']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${p['category']}'),
                        Text('Seller: ${p['username']}'),
                        Text('Price: ₹${p['price']}'),
                        const SizedBox(height: 4),
                        Text(
                          'Time left: ${getTimeLeft(p['auction_end_time'])}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      // Optionally show details
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
