import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notificaciones")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.purple.shade100,
                    radius: 30,
                    child: const Icon(Icons.notifications, color: Colors.purple, size: 30),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Notificaciones",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(thickness: 1),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const NotificationSwitch(label: "Notificaciones por email"),
            const NotificationSwitch(label: "Notificaciones por SMS"),
            const DoNotDisturbSwitch(),
            const FrequencyDropdown(),
          ],
        ),
      ),
    );
  }
}

class NotificationSwitch extends StatelessWidget {
  final String label;

  const NotificationSwitch({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Switch(value: true, onChanged: (value) {}),
      ],
    );
  }
}

class DoNotDisturbSwitch extends StatelessWidget {
  const DoNotDisturbSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("No molestar"),
        Switch(value: false, onChanged: (value) {}),
      ],
    );
  }
}

class FrequencyDropdown extends StatelessWidget {
  const FrequencyDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Frecuencia:"),
        DropdownButton<String>(
          value: "Diario",
          items: <String>['Diario', 'Semanal', 'Mensual']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {},
        ),
      ],
    );
  }
}