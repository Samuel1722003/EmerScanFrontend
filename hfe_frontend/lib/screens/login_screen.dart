import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';
import 'package:hfe_frontend/screens/sign_up/sign_up_screen1.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo EMER
              Column(
                children: [
                  Text(
                    'E M',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'E R',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Campos de formulario
              const InputText(hintText: 'Usuario'),
              const SizedBox(height: 20),
              const InputText(hintText: 'Contraseña', obscureText: true),
              const SizedBox(height: 24),

              // Botón Login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0), // Bordes rectos
                    ),
                  ),
                  child: const Text('Iniciar sesión'),
                ),
              ),
              const SizedBox(height: 16),

              // Enlace a registro
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen1(),
                    ),
                  );
                },
                child: const Text('¿Crear cuenta?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
