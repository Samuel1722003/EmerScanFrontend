import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/screen.dart';
import 'package:hfe_frontend/screens/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
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
                icon: Icons.settings,
                title: "Ajustes",
                color: AppTheme.primary,
              ),
              const SizedBox(height: 16),

              SettingsOption(
                icon: Icons.format_paint,
                label: "Personalización",
                color: Colors.amber,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PersonalizationScreen(),
                    ),
                  );
                },
              ),
              SettingsOption(
                icon: Icons.notifications,
                label: "Notificaciones",
                color: AppTheme.accent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              SettingsOption(
                icon: Icons.lock,
                label: "Seguridad y privacidad",
                color: AppTheme.hospitalizations,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SecurityScreen()),
                  );
                },
              ),
              SettingsOption(
                icon: Icons.headset_mic,
                label: "Ayuda y soporte",
                color: AppTheme.diseases,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SupportScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
