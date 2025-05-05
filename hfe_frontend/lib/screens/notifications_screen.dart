import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/screen.dart';
import 'package:hfe_frontend/screens/widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificaciones"),
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
                icon: Icons.notifications,
                title: "Notificaciones",
                color: AppTheme.accent,
              ),
              const SizedBox(height: 20),

              const ToggleSwitch(
                label: "Notificaciones por email",
                initialValue: true,
              ),
              const SizedBox(height: 10),

              const ToggleSwitch(
                label: "Notificaciones por SMS",
                initialValue: false,
              ),
              const SizedBox(height: 10),

              const ToggleSwitch(label: "No Molestar", initialValue: false),
              const SizedBox(height: 16),

              const NotificationFrequencyDropdown(),
            ],
          ),
        ),
      ),
    );
  }
}
