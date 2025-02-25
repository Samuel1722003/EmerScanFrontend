// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/screen.dart';
import 'package:hfe_frontend/widgets/inputText.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Correo: '),
            InputText(
              title: 'Introduce un correo',
            ),
            Text('Contraseña: '),
            InputText(title: 'Introduce una contraseña'),
            // Boton navega entre pantallas.
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()),
                );
              },
              child: Text('Registrate'),
            )
          ],
        ),
      ),
    );
  }
}
