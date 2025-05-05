import 'package:flutter/material.dart';
import 'package:hfe_frontend/themes/app_theme.dart';

// Dropdown para frecuencia de notificaciones
class NotificationFrequencyDropdown extends StatefulWidget {
  const NotificationFrequencyDropdown({super.key});

  @override
  State<NotificationFrequencyDropdown> createState() =>
      _NotificationFrequencyDropdownState();
}

class _NotificationFrequencyDropdownState
    extends State<NotificationFrequencyDropdown> {
  String selectedFrequency = 'Diaria';
  final List<String> frequencies = [
    'Inmediata',
    'Diaria',
    'Semanal',
    'Mensual',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Frecuencia de resumen', style: AppTheme.cardTitle),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedFrequency,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => selectedFrequency = newValue);
              }
            },
            items:
                frequencies.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
