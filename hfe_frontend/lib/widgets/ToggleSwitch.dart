import 'package:flutter/material.dart';

class ToggleSwitch extends StatefulWidget {
  final String label;

  const ToggleSwitch({super.key, required this.label});

  @override
  _ToggleSwitchState createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.label),
        Switch(value: isSwitched, onChanged: (value) => setState(() => isSwitched = value)),
      ],
    );
  }
}