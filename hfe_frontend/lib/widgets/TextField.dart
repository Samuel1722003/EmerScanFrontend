import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEditable;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: isEditable,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        fillColor: Colors.grey[100],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      style: TextStyle(color: isEditable ? Colors.black87 : Colors.grey[600]),
    );
  }
}