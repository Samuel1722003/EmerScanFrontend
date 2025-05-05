import 'package:flutter/material.dart';
import 'package:hfe_frontend/themes/app_theme.dart';

// Botón para pantalla de soporte
class SupportButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const SupportButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: onPressed ?? () {},
        style: AppTheme.primaryButtonStyle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
