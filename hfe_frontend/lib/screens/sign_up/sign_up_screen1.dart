import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';
import 'package:hfe_frontend/screens/screen.dart';

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
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu nombre';
    }
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$').hasMatch(value)) {
      return 'Solo se permiten letras y espacios';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tus apellidos';
    }
    if (value.length < 2) {
      return 'Los apellidos deben tener al menos 2 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$').hasMatch(value)) {
      return 'Solo se permiten letras y espacios';
    }
    return null;
  }

  String? _validateBirthDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu fecha de nacimiento';
    }
    
    final parts = value.split('/');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    
    if (day == null || month == null || year == null) {
      return 'Fecha inválida';
    }
    
    try {
      final birthDate = DateTime(year, month, day);
      final now = DateTime.now();
      final age = now.difference(birthDate).inDays ~/ 365;
      
      if (age < 13) {
        return 'Debes tener al menos 13 años';
      }
      if (birthDate.isAfter(now)) {
        return 'La fecha no puede ser futura';
      }
    } catch (e) {
      return 'Fecha inválida';
    }
    
    return null;
  }

  String? _validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor selecciona tu género';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu teléfono';
    }
    
    // Eliminar espacios y caracteres especiales
    final cleanPhone = value.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Validar teléfono mexicano (10 dígitos) o internacional
    if (!RegExp(r'^(\+?\d{1,3}? ?)?\d{10}$').hasMatch(cleanPhone)) {
      return 'Teléfono inválido';
    }
    
    return null;
  }

  void _submitForm() {
    if (_isSubmitting) return;
    
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      final datosPersona = Persona()
        ..nombre = _nameController.text.trim()
        ..apellidos = _lastNameController.text.trim()
        ..fechaNacimiento = _birthDateController.text
        ..genero = _genderValue
        ..telefono = _phoneController.text.replaceAll(RegExp(r'[^\d+]'), '');
      
      Navigator.pushNamed(
        context,
        'RegisterScreen2',
        arguments: datosPersona,
      ).then((_) => setState(() => _isSubmitting = false));
    }
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
              SignUpTextField(
                label: 'Nombres',
                controller: _nameController,
                validator: _validateName,
              ),
              const SizedBox(height: 20),
              SignUpTextField(
                label: 'Apellidos',
                controller: _lastNameController,
                validator: _validateLastName,
              ),
              const SizedBox(height: 20),
              SignUpTextField(
                label: 'Fecha de nacimiento',
                controller: _birthDateController,
                isDate: true,
                validator: _validateBirthDate,
              ),
              const SizedBox(height: 20),
              SignUpDropdown(
                label: 'Género',
                items: const ['Masculino', 'Femenino'],
                onChanged: (value) => setState(() => _genderValue = value ?? ''),
                validator: _validateGender,
              ),
              const SizedBox(height: 20),
              SignUpTextField(
                label: 'Teléfono',
                controller: _phoneController,
                validator: _validatePhone,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}