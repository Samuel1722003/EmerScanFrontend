import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seguridad y datos")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomSectionIcon(
              icon: Icons.lock,
              title: "Seguridad y datos",
              color: Colors.teal,
            ),
            const SizedBox(height: 20),
            const ToggleSwitch(label: "Localización"),
            const ToggleSwitch(label: "Autenticación"),
            const SizedBox(height: 20),
            const SessionList(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Cerrar sesión en todos los dispositivos"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
