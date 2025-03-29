import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: Colors.lightBlue[50],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Ajustes",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 20),

            // Usamos el widget SettingsOption en lugar de ListTile
            SettingsOption(
              icon: Icons.format_paint,
              label: "Personalización",
              color: Colors.amberAccent,
              onTap: () {}, // Acción al presionar
            ),
            SettingsOption(
              icon: Icons.notifications,
              label: "Notificaciones",
              color: Colors.purpleAccent,
              onTap: () {},
            ),
            SettingsOption(
              icon: Icons.lock,
              label: "Seguridad y privacidad",
              color: Colors.cyan,
              onTap: () {},
            ),
            SettingsOption(
              icon: Icons.headset_mic,
              label: "Ayuda y soporte",
              color: Colors.pinkAccent,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}