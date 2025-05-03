import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';
import 'package:hfe_frontend/screens/screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hfe_frontend/models/persona.dart';
import 'package:bcrypt/bcrypt.dart';

class SignUpScreen3 extends StatefulWidget {
  const SignUpScreen3({super.key});
  @override
  State<SignUpScreen3> createState() => _SignUpScreen3State();
}

class _SignUpScreen3State extends State<SignUpScreen3> {
  bool _isLoading = false;
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
    final signUpData = ModalRoute.of(context)!.settings.arguments as Persona;

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
            SignUpTextField(
              label: 'Confirma tu correo',
              controller: _emailController,
            ),
            const SizedBox(height: 20),
            SignUpTextField(
              label: 'Confirma tu contraseña',
              controller: _passwordController,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _crearCuenta(signUpData),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Crear cuenta'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _crearCuenta(Persona signUpData) async {
    if (_emailController.text != signUpData.correo ||
        _passwordController.text != signUpData.contrasena) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El correo o contraseña no coinciden con los datos ingresados anteriormente.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
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
          _isLoading = false;
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
      final qrUrl = 'https://emerscan-3b3b9.web.app/#MedicalDataScreen/$usuarioId';

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
            duration: const Duration(seconds: 5),
          ),
        );
      }
      print('Error detallado: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
