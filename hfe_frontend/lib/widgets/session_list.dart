import 'package:flutter/material.dart';

class SessionList extends StatelessWidget {
  const SessionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Dispositivo 1: "iPhone 12 - Chrome - Tecnológico de Culiacán - Última actividad: hace 2 horas".',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}