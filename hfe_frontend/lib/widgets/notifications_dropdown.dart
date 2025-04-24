import 'package:flutter/material.dart';

class NotificationFrequencyDropdown extends StatefulWidget {
  const NotificationFrequencyDropdown({super.key});

  @override
  _NotificationFrequencyDropdownState createState() => _NotificationFrequencyDropdownState();
}

class _NotificationFrequencyDropdownState extends State<NotificationFrequencyDropdown> {
  String selectedFrequency = "Diario";

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Frecuencia:"),
        DropdownButton<String>(
          value: selectedFrequency,
          items: <String>['Diario', 'Semanal', 'Mensual']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedFrequency = newValue!;
            });
          },
        ),
      ],
    );
  }
}