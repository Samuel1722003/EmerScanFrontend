import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class QRCodeScreen extends StatelessWidget {
  const QRCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    // Verificar si el usuario está autenticado
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Codigo QR')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No has iniciado sesión',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('Inicia sesión para acceder a tu código QR'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Codigo QR')),
      body: FutureBuilder(
        future:
            supabase
                .from('usuario_persona')
                .select('codigo_qr_base64')
                .eq('id', user.id) // Ya verificamos que user no es null
                .single(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Error al cargar el código QR'));
          }

          final data = snapshot.data as Map<String, dynamic>;

          if (data['codigo_qr_base64'] == null) {
            return const Center(child: Text('No se encontró el código QR.'));
          }

          final base64Qr = data['codigo_qr_base64'];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Escanea este código en caso de emergencia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Image.memory(base64Decode(base64Qr), width: 250, height: 250),
              ],
            ),
          );
        },
      ),
    );
  }
}
