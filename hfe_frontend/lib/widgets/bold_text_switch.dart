import 'package:flutter/material.dart';
import 'package:hfe_frontend/themes/app_theme.dart';

// Para activar/desactivar texto en negrita
class BoldTextSwitch extends StatefulWidget {
  const BoldTextSwitch({super.key});

  @override
  State<BoldTextSwitch> createState() => _BoldTextSwitchState();
}

class _BoldTextSwitchState extends State<BoldTextSwitch> {
  bool boldTextEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppTheme.cardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Texto en negrita', style: AppTheme.cardTitle),
          Switch(
            value: boldTextEnabled,
            onChanged: (value) {
              setState(() => boldTextEnabled = value);
            },
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
