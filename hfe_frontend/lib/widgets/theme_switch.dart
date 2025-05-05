import 'package:flutter/material.dart';
import 'package:hfe_frontend/themes/app_theme.dart';

// Para cambiar tema claro/oscuro
class ThemeSwitch extends StatefulWidget {
  const ThemeSwitch({super.key});

  @override
  State<ThemeSwitch> createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppTheme.cardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Tema oscuro', style: AppTheme.cardTitle),
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              setState(() => isDarkMode = value);
            },
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
