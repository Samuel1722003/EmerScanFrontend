import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';

class SignUpScreen1 extends StatefulWidget {
  const SignUpScreen1({super.key});

  @override
  State<SignUpScreen1> createState() => _SignUpScreen1State();
}

class _SignUpScreen1State extends State<SignUpScreen1> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  String _genderValue = '';
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro (1/4)')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CustomProgressBar(progress: 0.25),
              const SizedBox(height: 20),
              const Text(
                'Datos personales',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              SignUpTextField(label: 'Nombres', controller: _nameController),
              const SizedBox(height: 20),
              SignUpTextField(
                label: 'Apellidos',
                controller: _lastNameController,
              ),
              const SizedBox(height: 20),
              SignUpTextField(
                label: 'Fecha de nacimiento',
                controller: _birthDateController,
                isDate: true,
              ),
              const SizedBox(height: 20),
              SignUpDropdown(
                label: 'Género',
                items: const ['Masculino', 'Femenino'],
                onChanged: (value) => _genderValue = value ?? '',
              ),
              const SizedBox(height: 20),
              SignUpTextField(label: 'Teléfono', controller: _phoneController),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'RegisterScreen2');
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