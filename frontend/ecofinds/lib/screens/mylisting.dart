import 'dart:convert';
import 'package:ecofinds/screens/product_screen.dart';
import 'package:intl/intl.dart';
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

  void deleteProduct(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    http.post(Uri.parse('$baseUrl/products/delete.php'),
        body: {"user_id": '$userId', "product_id": '$id'}).then((response) {
      if (response.statusCode == 200) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MyListingsScreen();
        }));
      } else {
        // Handle error
      }
    });
  }

  Future<void> _deleteProduct(String id) async {
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
              onPressed: () {
                deleteProduct(id);
              },
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {}
  }

  void _showAuctionModal(String productId, String userId) {
    DateTime? selectedDateTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Start Auction'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Auction Final Time'),
                  ElevatedButton(
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                      backgroundColor:
                          WidgetStatePropertyAll(AppColors.primary),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    onPressed: () async {
                      final now = DateTime.now();
                      final date = await showDatePicker(
                        context: context,
                        initialDate: now,
                        firstDate: now,
                        lastDate: DateTime(now.year + 2),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setModalState(() {
                            selectedDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Text(selectedDateTime == null
                        ? 'Select Date & Time'
                        : selectedDateTime.toString()),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )),
                    backgroundColor: WidgetStatePropertyAll(AppColors.primary),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  onPressed: selectedDateTime == null
                      ? null
                      : () async {
                          // Call your auction start API here
                          await _startAuction(
                              productId, userId, selectedDateTime!);
                          Navigator.pop(context);
                        },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _startAuction(
      String productId, String userId, DateTime dateTime) async {
    // Replace with your actual API endpoint and parameters
    final response = await http.post(
      Uri.parse('$baseUrl/products/start_auction.php'),
      body: {
        'product_id': productId,
        'user_id': userId,
        'end_time': DateFormat('yyyy-MM-dd HH:mm').format(dateTime),
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auction started!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start auction: ${response.body}')),
      );
    }
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
                    return GestureDetector(
                      onTap: () {
                        print('Hi navigator');
                        print('Hi navigator');
                        print('Hi navigator');
                        print('Hi navigator');
                        print({
                          'productOwnerId': product["user_id"],
                          'productId': product["id"]
                        });
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ProductDetail(
                              productOwnerId: product["user_id"],
                              productId: product["id"]);
                        }));
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: product['image_url'] != null
                              ? Image.network(
                                  '$baseUrl/products/${product["image_url"]}'!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover)
                              : const Icon(Icons.image, size: 50),
                          title: Text(product['title']),
                          subtitle: Text("₹${product['price']}"),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'delete') {
                                _deleteProduct(product["id"]);
                              } else if (value == 'alter') {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return AddProductScreen(product: product);
                                }));
                              } else if (value == 'auction') {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String? userId = prefs.getString('user_id');
                                if (userId != null) {
                                  _showAuctionModal(product["id"], userId);
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                  value: 'auction',
                                  child: Text('Start Auction')),
                              const PopupMenuItem(
                                  value: 'alter',
                                  child: Text('Update Product')),
                              const PopupMenuItem(
                                  value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddProductScreen()),
          );
          // _fetchMyListings();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
