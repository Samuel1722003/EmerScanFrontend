import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // Buscar el usuario en la base de datos
      final result = await supabase
          .from('usuario_persona')
          .select()
          .eq('correo', _emailController.text)
          .limit(1);

      if (result.isEmpty) {
        // Usuario no encontrado
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo o contraseña incorrectos'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final user = result[0];
      final passwordHash = user['contrasena'];

      if (!BCrypt.checkpw(_passwordController.text, passwordHash)) {
        // Contraseña incorrecta
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo o contraseña incorrectos'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final userData = result[0];
      final prefs = await SharedPreferences.getInstance();
      // Guardamos el nombre y el ID del usuario
      await prefs.setString('user_name', userData['nombre']);
      await prefs.setString('user_id', userData['id'].toString());

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('HomeScreen');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      print('Error al iniciar sesión: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: AppTheme.cardDecoration,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo y título
                  Image.asset('assets/images/Logo.png', height: 120),
                  const SizedBox(height: 16),
                  const Text(
                    'EmerScan',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Iniciar sesión',
                    style: AppTheme.heading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Campo de correo electrónico
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: AppTheme.inputDecoration(
                      'Correo electrónico',
                      'Ingresa tu correo electrónico',
                      icon: Icons.email,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo de contraseña
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'Ingresa tu contraseña',
                      prefixIcon: Icon(Icons.lock, color: AppTheme.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
                        borderSide: const BorderSide(
                          color: AppTheme.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.red.shade300,
                          width: 1,
                        ),
                      ),
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Enlace de olvidé mi contraseña
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Implementación de recuperar contraseña
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text(
                        'Olvidé mi contraseña',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de inicio de sesión
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: AppTheme.primaryButtonStyle,
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                              : const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Enlace para crear una cuenta
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes una cuenta?',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen1(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Crear cuenta',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
