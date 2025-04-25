import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';
import 'package:hfe_frontend/screens/screen.dart';

class SignUpScreen2 extends StatefulWidget {
  const SignUpScreen2({super.key});

  @override
  State<SignUpScreen2> createState() => _SignUpScreen2State();
}

class _SignUpScreen2State extends State<SignUpScreen2> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final datosPersona = ModalRoute.of(context)!.settings.arguments as Persona;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro (2/4)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CustomProgressBar(progress: 0.50),
              const SizedBox(height: 20),
              const Text(
                'Crea tu cuenta',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              SignUpTextField(label: 'Correo', controller: _emailController),
              const SizedBox(height: 20),
              SignUpTextField(
                label: 'Contraseña',
                controller: _passwordController,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    datosPersona
                      ..correo = _emailController.text
                      ..contrasena = _passwordController.text;

                    Navigator.pushNamed(
                      context,
                      'RegisterScreen3',
                      arguments: datosPersona,
                    );
                  },
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
