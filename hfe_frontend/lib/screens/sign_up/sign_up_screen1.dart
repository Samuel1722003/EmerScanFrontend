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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Registro (1/4)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomProgressBar(progress: 0.25),
              const SizedBox(height: 24),
              const Text(
                'Datos personales',
                style: AppTheme.heading,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              const Text(
                'Por favor completa la siguiente información para crear tu cuenta',
                style: AppTheme.cardContent,
              ),
              const SizedBox(height: 32),
              _buildTextField(
                label: 'Nombres', 
                hint: 'Ingresa tu nombre', 
                controller: _nameController,
                icon: Icons.person_outline,
                validator: _validateName,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Apellidos', 
                hint: 'Ingresa tus apellidos', 
                controller: _lastNameController,
                icon: Icons.person_outline,
                validator: _validateLastName,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Fecha de nacimiento', 
                hint: 'DD/MM/AAAA',
                controller: _birthDateController,
                icon: Icons.calendar_today,
                isDate: true,
                validator: _validateBirthDate,
              ),
              const SizedBox(height: 20),
              _buildDropdown(
                label: 'Género',
                hint: 'Selecciona tu género',
                icon: Icons.wc,
                items: const ['Masculino', 'Femenino', 'Prefiero no decir'],
                onChanged: (value) => setState(() => _genderValue = value ?? ''),
                validator: _validateGender,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Teléfono', 
                hint: 'Ej: 5512345678', 
                controller: _phoneController,
                icon: Icons.phone,
                validator: _validatePhone,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: AppTheme.primaryButtonStyle,
                  child: _isSubmitting
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isDate = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: AppTheme.inputDecoration(label, hint, icon: icon),
          style: const TextStyle(fontSize: 16),
          validator: validator,
          readOnly: isDate,
          onTap: isDate ? () async {
            FocusScope.of(context).requestFocus(FocusNode());
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppTheme.primary,
                      onPrimary: Colors.white,
                      onSurface: AppTheme.textPrimary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              controller.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
            }
          } : null,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: AppTheme.inputDecoration(label, hint, icon: icon),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade500),
          ),
          dropdownColor: Colors.white,
        ),
      ],
    );
  }
}