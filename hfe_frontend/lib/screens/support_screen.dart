import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ayuda y soporte")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Centra toda la columna
          children: [
            const CustomSectionIcon(
              icon: Icons.headset_mic,
              title: "Ayuda y soporte",
              color: Colors.pink,
            ),
            const SizedBox(height: 20),
            Center(child: const SupportButton(label: "Preguntas frecuentes")),
            const SizedBox(height: 8),
            Center(child: const SupportButton(label: "Guías y tutoriales")),
            const SizedBox(height: 8),
            Center(child: const SupportButton(label: "Búsquedas y artículos")),
            const SizedBox(height: 8),
            Center(child: const SupportButton(label: "Soporte por correo")),
            const SizedBox(height: 8),
            Center(child: const SupportButton(label: "Contactarte con un agente")),
          ],
        ),
      ),
    );
  }
}