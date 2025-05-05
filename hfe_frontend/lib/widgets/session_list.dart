import 'package:flutter/material.dart';
import 'package:hfe_frontend/themes/app_theme.dart';

// Lista de sesiones para pantalla de seguridad
class SessionList extends StatelessWidget {
  const SessionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sesiones activas', style: AppTheme.subheading),
          const SizedBox(height: 12),
          _buildSessionItem(
            deviceName: 'iPhone 14 Pro Max',
            location: 'Ciudad de México',
            isCurrentDevice: true,
            lastActive: 'Ahora',
            icon: Icons.phone_iphone,
          ),
          const Divider(),
          _buildSessionItem(
            deviceName: 'MacBook Pro',
            location: 'Ciudad de México',
            isCurrentDevice: false,
            lastActive: 'Hace 2 horas',
            icon: Icons.laptop_mac,
          ),
          const Divider(),
          _buildSessionItem(
            deviceName: 'Chrome - Windows',
            location: 'Guadalajara',
            isCurrentDevice: false,
            lastActive: 'Ayer',
            icon: Icons.computer,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem({
    required String deviceName,
    required String location,
    required bool isCurrentDevice,
    required String lastActive,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      deviceName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (isCurrentDevice)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Actual',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$location • $lastActive',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          if (!isCurrentDevice)
            IconButton(
              icon: const Icon(Icons.logout, size: 16),
              color: Colors.red,
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}
