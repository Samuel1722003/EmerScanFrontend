import 'package:flutter/material.dart';

class CustomSectionIcon extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const CustomSectionIcon({super.key, required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            radius: 30,
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(thickness: 1),
        ],
      ),
    );
  }
}
