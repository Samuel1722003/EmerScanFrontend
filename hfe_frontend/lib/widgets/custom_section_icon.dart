import 'package:flutter/material.dart';
import 'package:hfe_frontend/themes/app_theme.dart';

// Widget para encabezados de sección con icono
class CustomSectionIcon extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const CustomSectionIcon({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          radius: 30,
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 10),
        Text(title, style: AppTheme.heading, textAlign: TextAlign.center),
        const Divider(thickness: 1, height: 30),
      ],
    );
  }
}
