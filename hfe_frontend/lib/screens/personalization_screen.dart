import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';

class PersonalizationScreen extends StatelessWidget {
  const PersonalizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personalización")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.amber.shade100,
                    radius: 30,
                    child: const Icon(Icons.format_paint, color: Colors.amber, size: 30),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Personalización",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(thickness: 1),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const ThemeSwitch(),
            const LanguageSelector(),
            const TextSizeSlider(),
            const BoldTextSwitch(),
          ],
        ),
      ),
    );
  }
}