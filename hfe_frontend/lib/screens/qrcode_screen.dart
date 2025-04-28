import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
    });
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Código QR')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Código QR')),
      body: FutureBuilder(
        future:
            supabase
                .from('usuario_persona')
                .select('codigo_qr_base64')
                .eq('id', userId!)
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