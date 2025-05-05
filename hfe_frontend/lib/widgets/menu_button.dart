import 'package:flutter/material.dart';

// Widget personalizado para el botón cuadrado
class MenuButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 200, // cuadrado
            height: 200,
            decoration: BoxDecoration(
              color: Colors.blueGrey[50], // Color de fondo del botón
              borderRadius: BorderRadius.circular(
                8,
              ), // Bordes levemente redondeados
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(icon, size: 75, color: Colors.blueGrey[700]),
          ),
          SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 21,
              color: Colors.blueGrey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
