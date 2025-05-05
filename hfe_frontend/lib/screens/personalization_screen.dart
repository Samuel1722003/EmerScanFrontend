import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/screen.dart';
import 'package:hfe_frontend/screens/widgets.dart';

class PersonalizationScreen extends StatelessWidget {
  const PersonalizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personalización"),
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
                icon: Icons.format_paint,
                title: "Personalización",
                color: Colors.amber,
              ),
              const SizedBox(height: 20),

              const ThemeSwitch(),
              const SizedBox(height: 10),

              const LanguageSelector(),
              const SizedBox(height: 10),

              const TextSizeSlider(),
              const SizedBox(height: 10),

              const BoldTextSwitch(),
            ],
          ),
        ),
      ),
    );
  }
}
