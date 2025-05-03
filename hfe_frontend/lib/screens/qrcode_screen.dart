import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  String? userId;
  bool isLoading = true;
  String qrUrlData = ''; // ← Cambiado: ahora guarda la URL del JSON
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchQR();
  }

  Future<void> _loadUserIdAndFetchQR() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('user_id');

      if (id == null) {
        throw Exception('Usuario no autenticado');
      }

      setState(() {
        userId = id;
      });

      await _fetchUserQR();
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchUserQR() async {
    if (userId == null) return;

    try {
      final supabase = Supabase.instance.client;

      final userData =
          await supabase
              .from('usuario_persona')
              .select('nombre, apellido_paterno, codigo_qr')
              .eq('id', userId!)
              .single();

      setState(() {
        userName = '${userData['nombre']} ${userData['apellido_paterno']}';

        try {
          final Map<String, dynamic> qrDataMap = jsonDecode(
            userData['codigo_qr'],
          );
          qrUrlData = qrDataMap['url'] ?? '';
        } catch (e) {
          // Si el parseo falla, usar el string completo
          qrUrlData = userData['codigo_qr'] ?? '';
        }
      });
    } catch (e) {
      print('Error al obtener datos de usuario: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener datos de usuario: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _shareQRCode() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de compartir no implementada')),
    );
  }

  Future<void> _copyBase64ToClipboard() async {
    await Clipboard.setData(ClipboardData(text: qrUrlData));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código QR copiado al portapapeles')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Código QR Médico'),
        backgroundColor: Colors.lightBlue[50],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserIdAndFetchQR,
            tooltip: 'Recargar QR',
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Información médica de ${userName ?? "Usuario"}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Este código permite acceso a tu información médica esencial en caso de emergencia.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          qrUrlData.isEmpty
                              ? const SizedBox(
                                height: 200,
                                width: 200,
                                child: Center(child: Text('QR no disponible')),
                              )
                              : QrImageView(
                                data: qrUrlData, // ← Aquí se muestra la URL
                                version: QrVersions.auto,
                                size: 250.0,
                                backgroundColor: Colors.white,
                                errorStateBuilder: (context, error) {
                                  return const Center(
                                    child: Text(
                                      'Error al generar QR',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  );
                                },
                              ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      '¿Cómo utilizar este QR?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1. Escanea el código QR con la cámara de tu dispositivo.',
                          ),
                          SizedBox(height: 5),
                          Text(
                            '2. Accede a tu información médica rápidamente.',
                          ),
                          SizedBox(height: 5),
                          Text('3. Úsalo solo en caso de emergencia.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _shareQRCode,
                          icon: const Icon(Icons.share),
                          label: const Text('Compartir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _copyBase64ToClipboard,
                          icon: const Icon(Icons.copy),
                          label: const Text('Copiar Código'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
