import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notificaciones")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomSectionIcon(
              icon: Icons.notifications,
              title: "Notificaciones",
              color: Colors.purple,
            ),
            const SizedBox(height: 20),
            const ToggleSwitch(label: "Notificaciones por email"),
            const ToggleSwitch(label: "Notificaciones por SMS"),
            const ToggleSwitch(label: "No Molestar",),
            const NotificationFrequencyDropdown(),
          ],
        ),
      ),
    );
  }
}
