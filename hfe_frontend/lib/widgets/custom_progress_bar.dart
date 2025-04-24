import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress; // Valor entre 0.0 y 1.0 (ej: 0.25 = 25%)
  
  const CustomProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: progress.clamp(0.0, 1.0),
      backgroundColor: Colors.grey[300],
      color: Colors.blue,
      minHeight: 8,
    );
  }
}