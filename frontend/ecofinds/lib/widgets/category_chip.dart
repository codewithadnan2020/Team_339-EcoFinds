import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  const CategoryChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.green.shade100,
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
    );
  }
}
