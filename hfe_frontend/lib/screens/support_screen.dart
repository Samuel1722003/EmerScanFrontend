import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/screen.dart';
import 'package:hfe_frontend/screens/widgets.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayuda y soporte"),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: Container(
        color: AppTheme.background,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomSectionIcon(
                icon: Icons.headset_mic,
                title: "Ayuda y soporte",
                color: AppTheme.diseases,
              ),
              const SizedBox(height: 24),

              const SupportButton(label: "Preguntas frecuentes"),
              const SizedBox(height: 12),

              const SupportButton(label: "Guías y tutoriales"),
              const SizedBox(height: 12),

              const SupportButton(label: "Búsquedas y artículos"),
              const SizedBox(height: 12),

              const SupportButton(label: "Soporte por correo"),
              const SizedBox(height: 12),

              const SupportButton(label: "Contactarte con un agente"),
            ],
          ),
        ),
      ),
    );
  }
}
