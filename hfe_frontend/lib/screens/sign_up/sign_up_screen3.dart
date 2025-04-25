import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';
import 'package:hfe_frontend/screens/screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hfe_frontend/models/persona.dart';

class SignUpScreen3 extends StatefulWidget {
  const SignUpScreen3({super.key});
  @override
  State<SignUpScreen3> createState() => _SignUpScreen3State();
}

class _SignUpScreen3State extends State<SignUpScreen3> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
            SignUpTextField(label: 'Correo'),
            const SizedBox(height: 20),
            SignUpTextField(label: 'Contraseña'),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _crearCuenta,
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

  Future<void> _crearCuenta() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final signUpData = ModalRoute.of(context)!.settings.arguments as Persona;
      final supabase = Supabase.instance.client;

      // Código de diagnóstico
      print('URL de Supabase: ${'https://dmvgtocktnzamzaqvybr.supabase.co'}');
      print('Verificando conexión a Supabase...');

      try {
        // Intenta listar las tablas disponibles
        final tablesResponse = await supabase.rpc('list_tables');
        print('Tablas disponibles: $tablesResponse');
      } catch (e) {
        print('Error al listar tablas: $e');
      }

      try {
        // Intenta una consulta simple
        final testResponse = await supabase
            .from('usuario_persona')
            .select('id')
            .limit(1);
        print('Consulta de prueba exitosa: $testResponse');
      } catch (e) {
        print('Error en consulta de prueba: $e');
      }

      // Reformatear la fecha para que sea compatible con PostgreSQL
      // Asumiendo que signUpData.fechaNacimiento está en formato "DD/MM/YYYY"
      String formattedDate;

      try {
        // Parsear la fecha original
        final dateParts = signUpData.fechaNacimiento.split('/');
        if (dateParts.length == 3) {
          // Reformatear a 'YYYY-MM-DD'
          formattedDate = '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';
        } else {
          formattedDate =
              signUpData
                  .fechaNacimiento; // Usar el original si no podemos parsear
        }
      } catch (e) {
        // Si hay un error al parsear, intentamos usar un formato estándar
        formattedDate = signUpData.fechaNacimiento;
      }

      print('Fecha original: ${signUpData.fechaNacimiento}');
      print('Fecha formateada: $formattedDate');

      // Insertar en la tabla Usuario_Persona con la fecha correctamente formateada
      await supabase.from('Usuario_Persona').insert({
        'correo': signUpData.correo,
        'contrasena': signUpData.contrasena,
        'nombre': signUpData.nombre,
        'apellido_paterno': signUpData.apellidos.split(' ').first,
        'apellido_materno':
            signUpData.apellidos.split(' ').length > 1
                ? signUpData.apellidos.split(' ').last
                : '',
        'fecha_nacimiento': formattedDate, // Usar la fecha formateada
        'genero': signUpData.genero,
        'telefono': signUpData.telefono,
      });

      if (!mounted) return;

      Navigator.pushNamed(context, 'RegisterScreen4');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear cuenta: ${e.toString()}'),
            duration: Duration(seconds: 5),
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
