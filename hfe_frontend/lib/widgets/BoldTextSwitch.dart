import 'package:flutter/material.dart';

class BoldTextSwitch extends StatefulWidget {
  const BoldTextSwitch({super.key});

  @override
  _BoldTextSwitchState createState() => _BoldTextSwitchState();
}

class _BoldTextSwitchState extends State<BoldTextSwitch> {
  bool isBold = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text("Negritas:"),
      value: isBold,
      onChanged: (value) {
        setState(() {
          isBold = value;
        });
      },
    );
  }
}