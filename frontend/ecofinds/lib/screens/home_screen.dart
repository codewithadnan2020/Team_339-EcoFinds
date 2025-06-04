import 'dart:convert';

import 'package:ecofinds/core/constants.dart';
import 'package:ecofinds/screens/Navigation.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecofinds/screens/add_edit_product.dart';
import 'package:ecofinds/screens/cart_screen.dart';
import 'package:ecofinds/screens/product_screen.dart';
import 'package:ecofinds/screens/shakingIcon.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> allProducts = [];
  List<dynamic> products = [];
  int? cartCount;
  TextEditingController _searchController = TextEditingController();
  List<String> categories = [];
  Map<String, List<dynamic>> productsByCategory = {};
  var images = ["assets/img1.jpg", "assets/img2.jpg", "assets/img3.jpg"];
  @override
  void initState() {
    super.initState();
    getUser();
    _searchController.addListener(_onSearchChanged);
  updateCartCount(); // Fetch cart count on init
  }
 void updateCartCount() async {
    int count = await getCartCount();
    setState(() {
      cartCount = count;
    });
  }
  void getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    fetchCategory().then((cats) {
      setState(() {
        categories = cats;
      });
      for (var category in cats) {
        fetchCategoryProducts(category, userId!);
      }
    });
  }

  Future<List<String>> fetchCategory() async {
    var res = await http.get(Uri.parse(
        'http://192.168.242.110/ecofinds/api/products/categories.php'));
    if (res.statusCode == 200) {
      return List<String>.from(jsonDecode(res.body));
    } else {
      return [];
    }
  }

  void fetchCategoryProducts(String category, String userId) async {
    final response = await http.post(Uri.parse(
        '$baseUrl/products/list.php?user_id=$userId&category=$category'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        productsByCategory[category] = List<dynamic>.from(data);
      });
    }
  }

  void _onSearchChanged() async {
    String query = _searchController.text.toLowerCase();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    setState(() {
      if (query.isEmpty) {
        // Re-fetch all products for each category
        for (var category in categories) {
          fetchCategoryProducts(category, userId!);
        }
      } else {
        // Filter products in each category
        productsByCategory.updateAll((category, products) {
          return products
              .where((item) => (item['title'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(query))
              .toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoFinds'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
          }, // Open side menu
        ),
        elevation: 10,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          CartCount(context, cartCount)
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // padding: const EdgeInsets.all(16),
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for products...',
                  prefixIcon: const Icon(Icons.search),
                  // border: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(12),
                  // ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Chips
              // SizedBox(
              //   height: 40,
              //   child: ListView.separated(
              //     scrollDirection: Axis.horizontal,
              //     itemCount: dummyCategories.length,
              //     separatorBuilder: (_, __) => const SizedBox(width: 8),
              //     itemBuilder: (context, index) {
              //       return CategoryChip(label: dummyCategories[index]);
              //     },
              //   ),
              // ),
              // const SizedBox(height: 16),

              CarouselSlider(
                options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.9,
                    height: 100.0),
                items: [0, 1, 2].map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Image.asset(
                        images[i],
                        width: 1500,
                        height: 1500,
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Product Section
              // ...inside your build method, replace the Product Section with:
              // ...existing code...

              Expanded(
                child: ListView.builder(
                  itemCount: categories
                      .where((cat) =>
                          (productsByCategory[cat]?.isNotEmpty ?? false))
                      .length,
                  itemBuilder: (context, catIndex) {
                    // Only include categories with products
                    final visibleCategories = categories
                        .where((cat) =>
                            (productsByCategory[cat]?.isNotEmpty ?? false))
                        .toList();
                    final category = visibleCategories[catIndex];
                    final products = productsByCategory[category] ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: products.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3 / 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) {
                            final item = products[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetail(productId: item['id']),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade300,
                                      blurRadius: 6,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                      child: Image.network(
                                        item['image_url'] ?? '',
                                        height: 130,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.broken_image,
                                                size: 100),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        item['title'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        "₹ ${item['price']}",
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
              // const Text(
              //   'Products',
              //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              // ),
              // const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
        BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
        BottomNavigationBarItem(label: "Live Auctions", icon: ShakingIcon(
    icon: Icon(Icons.gavel, color: Colors.red),
  ),)
      ]),
    );
  }
}
