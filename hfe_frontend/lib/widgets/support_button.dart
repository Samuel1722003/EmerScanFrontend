import 'package:flutter/material.dart';

class SupportButton extends StatelessWidget {
  final String label;

  const SupportButton({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.grey),
        ),
        child: Text(label),
      ),
    );
  }
}