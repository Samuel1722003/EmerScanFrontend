import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';
import 'package:hfe_frontend/screens/screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';

class SignUpScreen3 extends StatefulWidget {
  const SignUpScreen3({super.key});
  @override
  State<SignUpScreen3> createState() => _SignUpScreen3State();
}

class _SignUpScreen3State extends State<SignUpScreen3> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo electrónico';
    }
    
    final personaData = ModalRoute.of(context)!.settings.arguments as Persona;
    if (value != personaData.correo) {
      return 'El correo no coincide con el ingresado anteriormente';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    
    final personaData = ModalRoute.of(context)!.settings.arguments as Persona;
    if (value != personaData.contrasena) {
      return 'La contraseña no coincide con la ingresada anteriormente';
    }
    return null;
  }

  Future<void> _crearCuenta(Persona signUpData) async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isSubmitting = true;
        });

        final supabase = Supabase.instance.client;

        // Verificar si el correo ya existe
        final existingUsers = await supabase
            .from('usuario_persona')
            .select('correo')
            .eq('correo', signUpData.correo);

        if (existingUsers.isNotEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Este correo electrónico ya está registrado. Por favor, utiliza otro.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isSubmitting = false;
          });
          return;
        }

        // Formatear fecha de nacimiento
        final dateParts = signUpData.fechaNacimiento.split('/');
        final formattedDate =
            '${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}';

        //Encriptar contraseña
        final hashedPassword = BCrypt.hashpw(
          signUpData.contrasena,
          BCrypt.gensalt(),
        );

        // Insertar el nuevo usuario
        final insertResponse =
            await supabase
                .from('usuario_persona')
                .insert({
                  'correo': signUpData.correo,
                  'contrasena': hashedPassword,
                  'nombre': signUpData.nombre,
                  'apellido_paterno': signUpData.apellidos.split(' ').first,
                  'apellido_materno':
                      signUpData.apellidos.split(' ').length > 1
                          ? signUpData.apellidos.split(' ').last
                          : '',
                  'fecha_nacimiento': formattedDate,
                  'genero': signUpData.genero,
                  'telefono': signUpData.telefono,
                })
                .select('id')
                .single();

        final usuarioId = insertResponse['id'];

        // Generar URL para el QR (usa tu dominio de Firebase Hosting real)
        final qrUrl = 'https://emerscan-38fb8.web.app/#MedicalDataScreen/$usuarioId';

        // Generar datos del QR incluyendo la URL
        final qrData = jsonEncode({
          'url': qrUrl,
          'usuarioId': usuarioId,
          'tipo': 'identificacion_medica',
          'fechaGeneracion': DateTime.now().toIso8601String(),
        });

        // Guardar los datos del QR en la base de datos
        await supabase
            .from('usuario_persona')
            .update({'codigo_qr': qrData})
            .eq('id', usuarioId);

        if (!mounted) return;
        Navigator.pushNamed(context, 'RegisterScreen4');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear cuenta: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        print('Error detallado: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final personaData = ModalRoute.of(context)!.settings.arguments as Persona;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Registro (3/4)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomProgressBar(progress: 0.75),
              const SizedBox(height: 24),
              const Text(
                'Confirma tus datos',
                style: AppTheme.heading,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              const Text(
                'Por favor confirma tu correo y contraseña para completar el registro',
                style: AppTheme.cardContent,
              ),
              const SizedBox(height: 32),
              _buildTextField(
                label: 'Confirma tu correo electrónico',
                hint: 'ejemplo@correo.com',
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: 'Confirma tu contraseña',
                hint: 'Ingresa tu contraseña',
                controller: _passwordController,
                obscureText: _obscurePassword,
                toggleObscureText: () => setState(() => _obscurePassword = !_obscurePassword),
                validator: _validatePassword,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _crearCuenta(personaData),
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
                          'Crear cuenta',
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
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 16),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleObscureText,
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
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primary),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.primary,
              ),
              onPressed: toggleObscureText,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300, width: 1),
            ),
            labelStyle: TextStyle(color: Colors.grey.shade600),
          ),
          style: const TextStyle(fontSize: 16),
          validator: validator,
        ),
      ],
    );
  }
}