import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';

class SignUpScreen1 extends StatefulWidget {
  const SignUpScreen1({super.key});

  @override
  State<SignUpScreen1> createState() => _SignUpScreen1State();
}

class _SignUpScreen1State extends State<SignUpScreen1> {
  final _formKey = GlobalKey<FormState>();
  final _numbersController = TextEditingController();
  final _aquillitosController = TextEditingController();
  final _birthDateController = TextEditingController();
  String _cuerpoValue = '';
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _numbersController.dispose();
    _aquillitosController.dispose();
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
              // Barra de progreso al 25%
              const CustomProgressBar(progress: 0.25),
              const SizedBox(height: 20),
              const Text(
                'Ingresa tus datos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Campos con widgets personalizados
              SignUpTextField(
                label: 'Nombre(s)',
                hint: 'Ej: Cristina',
                controller: _numbersController,
                validator:
                    (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 20),

              SignUpTextField(
                label: 'Apellido(s)',
                hint: 'Ej: Soliz',
                controller: _aquillitosController,
                validator:
                    (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 20),

              SignUpTextField(
                label: 'Fecha de nacimiento',
                isDate: true,
                controller: _birthDateController,
                validator:
                    (value) => value!.isEmpty ? 'Selecciona una fecha' : null,
              ),
              const SizedBox(height: 20),

              SignUpDropdown(
                label: 'Genero',
                items: const ['Masculino', 'Femenino'],
                onChanged: (value) => _cuerpoValue = value ?? '',
                validator:
                    (value) => value == null ? 'Selecciona una opción' : null,
              ),
              const SizedBox(height: 20),

              SignUpTextField(
                label: 'Teléfono',
                hint: 'Ej: +52 6672435670',
                controller: _phoneController,
                validator:
                    (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 40),

              // Botón
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushNamed(context, '/signup2');
                    }
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
