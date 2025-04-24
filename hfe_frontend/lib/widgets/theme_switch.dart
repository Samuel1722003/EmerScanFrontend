import 'package:flutter/material.dart';

class ThemeSwitch extends StatefulWidget {
  const ThemeSwitch({super.key});

  @override
  _ThemeSwitchState createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text("Modo oscuro"),
      value: isDarkMode,
      onChanged: (value) {
        setState(() {
          isDarkMode = value;
        });
      },
    );
  }
}