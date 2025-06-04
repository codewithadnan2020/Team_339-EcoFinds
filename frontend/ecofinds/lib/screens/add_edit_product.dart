import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddProductScreen extends StatefulWidget {
  AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameCtrl = TextEditingController();
  TextEditingController _descCtrl = TextEditingController();
  TextEditingController _priceCtrl = TextEditingController();
  TextEditingController _qtyCtrl = TextEditingController();
  TextEditingController _imageCtrl = TextEditingController();
  TextEditingController _selectedCategory = TextEditingController();
  bool _isSubmitting = false;
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    // fetchCategory();
    fetchCategory().then((cats) {
      setState(() {
        categories = cats;
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<List<String>> fetchCategory() async {
    var res = await http.get(Uri.parse(
        'http://192.168.242.110/ecofinds/api/products/categories.php'));
    if (res.statusCode == 200) {
      // Assuming the API returns a JSON array of strings
      return List<String>.from(jsonDecode(res.body));
    } else {
      return [];
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      final response =
          await http.post(Uri.parse('$baseUrl/products/create.php'), body: {
        'user_id': userId ?? '',
        'title': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': _priceCtrl.text.trim(),
        'image_url': _imageCtrl.text.trim(),
        'category': _selectedCategory.text.trim() ?? '',
      });
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AddProductScreen();
      }));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save product: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TypeAheadField(
                suggestionsCallback: (search) async {
                  // Optionally filter categories by search
                  if (search.isEmpty) return categories;
                  return categories
                      .where((cat) =>
                          cat.toLowerCase().contains(search.toLowerCase()))
                      .toList();
                },
                builder: (context, controller, focusNode) {
                  return TextFormField(
                    readOnly: true,
                    controller: _selectedCategory,
                    focusNode: focusNode,
                    autofocus: false,
                    decoration: InputDecoration(
                      labelText: 'Product  Category',
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  );
                },
                itemBuilder: (context, value) {
                  return ListTile(
                    title: Text(value),
                  );
                },
                onSelected: (value) {
                  _selectedCategory.text = value;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (val) => double.tryParse(val ?? '') == null
                    ? 'Enter valid price'
                    : null,
              ),
              const SizedBox(height: 12),
              // TextFormField(
              //   controller: _selectedCategory,
              //   decoration: const InputDecoration(labelText: 'Category'),
              // ),
              TextFormField(
                controller: _imageCtrl,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: const ButtonStyle(
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                          backgroundColor:
                              WidgetStatePropertyAll(AppColors.primary),
                          foregroundColor:
                              WidgetStatePropertyAll(Colors.white)),
                      onPressed: _handleSubmit,
                      child: const Text('Add Product'),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
