import 'package:flutter/material.dart';
import 'package:hfe_frontend/themes/app_theme.dart';

// Toggle switch para opciones de configuración
class ToggleSwitch extends StatefulWidget {
  final String label;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const ToggleSwitch({
    super.key,
    required this.label,
    this.initialValue = false,
    this.onChanged,
  });

  @override
  State<ToggleSwitch> createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch> {
  late bool isEnabled;

  @override
  void initState() {
    super.initState();
    isEnabled = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppTheme.cardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.label, style: AppTheme.cardTitle),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              setState(() => isEnabled = value);
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
