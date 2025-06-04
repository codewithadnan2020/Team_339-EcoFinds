import 'dart:convert';
import 'dart:io';
import 'package:ecofinds/screens/mylisting.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? product; // Pass product for edit, null for add

  AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameCtrl = TextEditingController();
  TextEditingController _descCtrl = TextEditingController();
  TextEditingController _priceCtrl = TextEditingController();
  TextEditingController _selectedCategory = TextEditingController();
  bool _isSubmitting = false;
  List<dynamic> categories = [];
  File? _selectedImage;
  String? _currentImageUrl; // For showing existing image

  @override
  void initState() {
    super.initState();
    fetchCategory().then((cats) {
      setState(() {
        categories = cats;
      });
    });

    // If editing, pre-fill fields
    if (widget.product != null) {
      _nameCtrl.text = widget.product!['title'] ?? '';
      _descCtrl.text = widget.product!['description'] ?? '';
      _priceCtrl.text = widget.product!['price']?.toString() ?? '';
      _selectedCategory.text = widget.product!['category_name'] ?? '';
      _currentImageUrl = widget.product!['image_url'];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<List<String>> fetchCategory() async {
    var res = await http.get(Uri.parse(
        '$baseUrl/products/categories.php'));
    if (res.statusCode == 200) {
      return List<String>.from(jsonDecode(res.body));
    } else {
      return [];
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    if (widget.product == null && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      bool isEdit = widget.product != null;
      var uri = Uri.parse(
        isEdit ? '$baseUrl/products/update.php' : '$baseUrl/products/create.php'
      );
      var request = http.MultipartRequest('POST', uri);

      request.fields['user_id'] = userId ?? '';
      request.fields['title'] = _nameCtrl.text.trim();
      request.fields['description'] = _descCtrl.text.trim();
      request.fields['price'] = _priceCtrl.text.trim();
      request.fields['category'] = _selectedCategory.text.trim();

      if (isEdit) {
        request.fields['product_id'] = widget.product!['id'].toString();
        // Only add image if user picked a new one
        if (_selectedImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'image', _selectedImage!.path,
          ));
        }
      } else {
        // For add, image is required
        request.files.add(await http.MultipartFile.fromPath(
          'image', _selectedImage!.path,
        ));
      }

      var response = await request.send();
      var respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? 'Product updated' : 'Product added')),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return MyListingsScreen();
        }));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $respStr')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.product != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TypeAheadField(
                suggestionsCallback: (search) async {
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
                      labelText: 'Product Category',
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
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text(isEdit ? 'Change Image' : 'Select Image'),
                  ),
                  const SizedBox(width: 10),
                  _selectedImage != null
                      ? Image.file(_selectedImage!, width: 80, height: 80)
                      : (_currentImageUrl != null
                          ? Image.network(
                              '$baseUrl/products/${_currentImageUrl!}',
                              width: 80,
                              height: 80,
                            )
                          : const Text('No image selected')),
                ],
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
                      child: Text(isEdit ? 'Update Product' : 'Add Product'),
                    )
            ],
          ),
        ),
      ),
    );
  }
}