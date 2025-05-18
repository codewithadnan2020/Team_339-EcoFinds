import 'dart:convert';

import 'package:ecofinds/screens/add_edit_product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ecofinds/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  List<dynamic> products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  void getProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    print('userId');
    print('$userId');
    print('userId');
    print({"user_id": '$userId'});
    http.post(Uri.parse('$baseUrl/products/mylist.php'),
        body: {"user_id": '$userId'}).then((response) {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
      print(data);
        setState(() {
          products = data;
          _isLoading = false;
        });
      } else {
        // Handle error
      }
    });
  }

  Future<void> _deleteProduct(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('You have no products listed yet.'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: product['image_url'] != null
                            ? Image.network(product['image_url']!,
                                width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.image, size: 50),
                        title: Text(product['title']),
                        subtitle: Text("₹${product['price']}"),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteProduct(product["id"]);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) =>  AddProductScreen()),
          );
          // _fetchMyListings();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
