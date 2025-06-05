import 'dart:convert';

import 'package:ecofinds/core/constants.dart';
import 'package:ecofinds/screens/Navigation.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecofinds/screens/add_edit_product.dart';
import 'package:ecofinds/screens/auction_products.dart';
import 'package:ecofinds/screens/cart_screen.dart';
import 'package:ecofinds/screens/notifications.dart';
import 'package:ecofinds/screens/product_screen.dart';
import 'package:ecofinds/screens/shakingIcon.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SortOption { priceLowHigh, priceHighLow, newest }

enum GroupOption { category, priceRange }

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
  SortOption? _selectedSort;
  GroupOption _selectedGroup = GroupOption.category;
  double? _minPrice;
  double? _maxPrice;
  @override
  void initState() {
    super.initState();
    getUser();
    _searchController.addListener(_onSearchChanged);
    updateCartCount(); // Fetch cart count on init
  }

  int _selectedIndex = 0; // Add this at the top of your _HomeScreenState

  void _onNavBarTapped(int index) async {
    if (index == 1) {
      // Navigate to Live Auctions screen
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id') ?? '0';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AuctionProductsScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      setState(() {
        _selectedIndex = index;
      });
    }
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

  void _showSortDialog() async {
    final selected = await showDialog<SortOption>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Sort By'),
        children: [
          RadioListTile(
            value: SortOption.priceLowHigh,
            groupValue: _selectedSort,
            title: const Text('Price: Low to High'),
            onChanged: (val) => Navigator.pop(context, val),
          ),
          RadioListTile(
            value: SortOption.priceHighLow,
            groupValue: _selectedSort,
            title: const Text('Price: High to Low'),
            onChanged: (val) => Navigator.pop(context, val),
          ),
          RadioListTile(
            value: SortOption.newest,
            groupValue: _selectedSort,
            title: const Text('Newest First'),
            onChanged: (val) => Navigator.pop(context, val),
          ),
        ],
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedSort = selected;
        _applySortFilterGroup();
      });
    }
  }

  void _showFilterDialog() async {
    double? min = _minPrice;
    double? max = _maxPrice;
    final minCtrl = TextEditingController(text: min?.toString() ?? '');
    final maxCtrl = TextEditingController(text: max?.toString() ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Price'),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: minCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Min'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: maxCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Max'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (result == true) {
      setState(() {
        _minPrice = double.tryParse(minCtrl.text);
        _maxPrice = double.tryParse(maxCtrl.text);
        _applySortFilterGroup();
      });
    } else if (result == false) {
      setState(() {
        _minPrice = null;
        _maxPrice = null;
        _applySortFilterGroup();
      });
    }
  }

  void _showGroupDialog() async {
    final selected = await showDialog<GroupOption>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Group By'),
        children: [
          RadioListTile(
            value: GroupOption.category,
            groupValue: _selectedGroup,
            title: const Text('Category'),
            onChanged: (val) => Navigator.pop(context, val),
          ),
          RadioListTile(
            value: GroupOption.priceRange,
            groupValue: _selectedGroup,
            title: const Text('Price Range'),
            onChanged: (val) => Navigator.pop(context, val),
          ),
        ],
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedGroup = selected;
        _applySortFilterGroup();
      });
    }
  }

  void _applySortFilterGroup() {
    for (var category in categories) {
      var list = List<dynamic>.from(productsByCategory[category] ?? []);
      // Filter
      if (_minPrice != null) {
        list = list
            .where((item) =>
                double.tryParse(item['price'].toString()) != null &&
                double.parse(item['price'].toString()) >= _minPrice!)
            .toList();
      }
      if (_maxPrice != null) {
        list = list
            .where((item) =>
                double.tryParse(item['price'].toString()) != null &&
                double.parse(item['price'].toString()) <= _maxPrice!)
            .toList();
      }
      // Sort
      if (_selectedSort == SortOption.priceLowHigh) {
        list.sort((a, b) => double.parse(a['price'].toString())
            .compareTo(double.parse(b['price'].toString())));
      } else if (_selectedSort == SortOption.priceHighLow) {
        list.sort((a, b) => double.parse(b['price'].toString())
            .compareTo(double.parse(a['price'].toString())));
      } else if (_selectedSort == SortOption.newest) {
        list.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
      }
      productsByCategory[category] = list;
    }
    setState(() {});
  }

  // Helper for group by price range
  Map<String, List<dynamic>> _groupByPriceRange() {
    Map<String, List<dynamic>> grouped = {};
    for (var category in categories) {
      for (var item in productsByCategory[category] ?? []) {
        double price = double.tryParse(item['price'].toString()) ?? 0.0;
        String range;
        if (price < 500) {
          range = 'Below ₹500';
        } else if (price < 1000) {
          range = '₹500 - ₹999';
        } else if (price < 5000) {
          range = '₹1000 - ₹4999';
        } else {
          range = '₹5000+';
        }
        grouped.putIfAbsent(range, () => []).add(item);
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(18),
          ),
        ),
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
          CartCount(context, cartCount),
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return NotificationsScreen();
                }));
              },
              icon: Icon(Icons.notification_add))
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
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search for products...',
            prefixIcon: const Icon(Icons.search, color: Colors.black54),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
              const SizedBox(height: 12),

              // --- SORT, FILTER, GROUP BUTTONS ---
                SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: _showSortDialog,
                icon: const Icon(Icons.sort, color: Colors.black87),
                label: const Text('Sort', style: TextStyle(color: Colors.black87)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _showFilterDialog,
                icon: const Icon(Icons.filter_alt_outlined, color: Colors.black87),
                label: const Text('Filter', style: TextStyle(color: Colors.black87)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _showGroupDialog,
                icon: const Icon(Icons.tune, color: Colors.black87),
                label: const Text('Group By', style: TextStyle(color: Colors.black87)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

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

              Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                enlargeFactor: 0.98,
                height: 110.0,
              ),
              items: images.map((img) {
                return Image.asset(
                  img,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              }).toList(),
            ),
          ),
        ),
              const SizedBox(height: 24),

              // Product Section
              // ...inside your build method, replace the Product Section with:
              // ...existing code...

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    getUser();
                    updateCartCount();
                    setState(() {});
                  },
                  child: _selectedGroup == GroupOption.category
                      ? ListView.builder(
                          itemCount: categories
                              .where((cat) =>
                                  (productsByCategory[cat]?.isNotEmpty ??
                                      false))
                              .length,
                          itemBuilder: (context, catIndex) {
                            final visibleCategories = categories
                                .where((cat) =>
                                    (productsByCategory[cat]?.isNotEmpty ??
                                        false))
                                .toList();
                            final category = visibleCategories[catIndex];
                            final products = productsByCategory[category] ?? [];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    category, // or range
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(
                                          0xFF2E7D32), // Deep green for eco feel
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
                                      return
                                          // ...inside GridView.builder...
                                          Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        elevation: 2,
                                        margin: const EdgeInsets.all(4),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProductDetail(
                                                  productId: item['id'],
                                                  productOwnerId:
                                                      item["user_id"],
                                                ),
                                              ),
                                            );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: const BorderRadius
                                                    .vertical(
                                                    top: Radius.circular(16)),
                                                child: Image.network(
                                                  '$baseUrl/products/${item["image_url"]}' ??
                                                      '',
                                                  height: 110,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Icon(
                                                          Icons.broken_image,
                                                          size: 80),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  item['title'],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Text(
                                                  "₹ ${item['price']}",
                                                  style: TextStyle(
                                                    color:
                                                        Colors.green.shade700,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
// ...existing code...},
                                    ),
                                const SizedBox(height: 24),
                              ],
                            );
                          },
                        )
                      : ListView(
                          children: _groupByPriceRange().entries.map((entry) {
                            final range = entry.key;
                            final products = entry.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  range,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
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
                                            builder: (context) => ProductDetail(
                                                productId: item['id'],
                                                productOwnerId:
                                                    item["user_id"]),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                      top: Radius.circular(16)),
                                              child: Image.network(
                                                '$baseUrl/products/${item["image_url"]}' ??
                                                    '',
                                                height: 130,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    const Icon(
                                                        Icons.broken_image,
                                                        size: 100),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                          }).toList(),
                        ),
                ),
              )

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
  backgroundColor: Colors.white,
  selectedItemColor: Colors.black87,
  unselectedItemColor: Colors.black87,
  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
  currentIndex: _selectedIndex,
  onTap: _onNavBarTapped,
  items: [
    const BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
    BottomNavigationBarItem(
      label: "Live Auctions",
      icon: ShakingIcon(
        icon: Icon(Icons.gavel, color: Colors.red),
      ),
    ),
  ],
),);
  }
}
