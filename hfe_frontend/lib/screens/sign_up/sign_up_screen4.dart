import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';

class SignUpScreen4 extends StatelessWidget {
  const SignUpScreen4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro (4/4)')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CustomProgressBar(progress: 1.0),
            const SizedBox(height: 20),
            const Text(
              'Cuenta creada con éxito',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'LoginScreen');
                },
                child: const Text('Iniciar Sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}