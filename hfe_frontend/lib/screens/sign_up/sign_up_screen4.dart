import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';
import 'package:hfe_frontend/screens/screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen4 extends StatelessWidget {
  const SignUpScreen4({super.key});

  // Método para guardar información básica del usuario en SharedPreferences
  Future<void> _saveUserInfo(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'user_name',
      '${userData['nombre'] ?? ''} ${userData['apellido_paterno'] ?? ''}',
    );
  }

  // Método para preparar la navegación hacia el HomeScreen
  Future<void> _navigateToHome(BuildContext context) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      // Si tenemos un usuario autenticado, obtenemos su información básica
      if (user != null) {
        final userData =
            await supabase
                .from('usuario_persona')
                .select('nombre, apellido_paterno')
                .eq('id', user.id)
                .single();

        await _saveUserInfo(userData);
      }

      // Navegar a HomeScreen y limpiar el stack de navegación
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        'HomeScreen',
        (route) => false,
      );
    } catch (e) {
      // En caso de error, lo manejamos adecuadamente
      print('Error al navegar al HomeScreen: $e');

      // Si hay un error, aún así navegamos al HomeScreen
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        'HomeScreen',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Registro (4/4)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CustomProgressBar(progress: 1.0),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '¡Cuenta creada con éxito!',
              style: AppTheme.heading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tu registro ha sido completado correctamente. Ahora accederás a tu cuenta automáticamente.',
              style: AppTheme.cardContent,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToHome(context),
                style: AppTheme.primaryButtonStyle,
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
