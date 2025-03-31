import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';

class SignUpScreen3 extends StatelessWidget {
  const SignUpScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro (3/4)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CustomProgressBar(progress: 0.75),
            const SizedBox(height: 20),
            const Text(
              'Confirma tus datos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            SignUpTextField(label: 'Correo'),
            const SizedBox(height: 20),
            SignUpTextField(label: 'Contraseña'),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'RegisterScreen4');
                },
                child: const Text('Crear cuenta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}