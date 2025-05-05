import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/screen.dart';
import 'package:hfe_frontend/screens/widgets.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seguridad y datos"),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: Container(
        color: AppTheme.background,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomSectionIcon(
                  icon: Icons.lock,
                  title: "Seguridad y datos",
                  color: AppTheme.hospitalizations,
                ),
                const SizedBox(height: 20),

                const ToggleSwitch(label: "Localización", initialValue: true),
                const SizedBox(height: 10),

                const ToggleSwitch(label: "Autenticación", initialValue: true),
                const SizedBox(height: 20),

                const SessionList(),
                const SizedBox(height: 20),

                SupportButton(
                  label: "Cerrar sesión en todos los dispositivos",
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
