import 'package:flutter/material.dart';

class SignUpDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  const SignUpDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          )).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}