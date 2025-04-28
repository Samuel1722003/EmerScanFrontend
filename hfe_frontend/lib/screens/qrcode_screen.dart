import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
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
  String qrData = '';
  String qrUrl = '';
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndGenerateQR();
  }

  Future<void> _loadUserIdAndGenerateQR() async {
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
      
      await _generateMedicalQR();
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _generateMedicalQR() async {
    if (userId == null) return;
    
    try {
      final supabase = Supabase.instance.client;
      
      // Obtener datos del usuario
      final userData = await supabase
          .from('usuario_persona')
          .select('nombre, apellido_paterno')
          .eq('id', userId!)
          .single();
      
      // Guardar nombre para mostrar en la UI
      setState(() {
        userName = '${userData['nombre']} ${userData['apellido_paterno']}';
      });
      
      // Generar un token temporal (válido por 24 horas)
      final timestamp = DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch.toString();
      final hmacKey = 'clave_secreta_app_medica'; // En producción, usar una clave segura
      
      final hmac = Hmac(sha256, utf8.encode(hmacKey));
      final digest = hmac.convert(utf8.encode('$userId-$timestamp'));
      final token = base64Url.encode(utf8.encode('$userId:$timestamp:${digest.toString()}'));
      
      // Guardar el token en Supabase para validación
      await supabase.from('medical_tokens').upsert(
        {
          'user_id': userId,
          'token': token,
          'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
        },
        onConflict: 'user_id',
      );
      
      // Construir la URL para el QR (ajusta con tu dominio real)
      final qrUrl = 'https://tuapp.web.app/medical-view?token=$token';
      
      setState(() {
        qrData = token;
        this.qrUrl = qrUrl;
      });
    } catch (e) {
      print('Error al generar QR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar QR: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _shareQRCode() async {
    // Esta función se implementaría con un plugin como share_plus
    // para compartir el QR o su enlace
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de compartir no implementada')),
    );
  }

  Future<void> _copyLinkToClipboard() async {
    await Clipboard.setData(ClipboardData(text: qrUrl));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enlace copiado al portapapeles')),
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
            onPressed: _loadUserIdAndGenerateQR,
            tooltip: 'Regenerar QR',
          ),
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Información médica de ${userName ?? "Usuario"}',
                      style: const TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Este código permite acceso a tu información médica esencial en caso de emergencia',
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
                          qrData.isEmpty
                              ? const SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: Center(child: Text('Error al generar QR')),
                                )
                              : QrImageView(
                                  data: qrUrl,
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
                          const SizedBox(height: 15),
                          Chip(
                            label: const Text('Válido por 24 horas'),
                            avatar: const Icon(Icons.access_time, size: 16),
                            backgroundColor: Colors.blue[50],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Instrucciones:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          Text('1. Escanea este código QR con cualquier lector de códigos QR'),
                          SizedBox(height: 5),
                          Text('2. Se abrirá una página web con tus datos médicos esenciales'),
                          SizedBox(height: 5),
                          Text('3. El personal médico podrá acceder a información crítica en caso de emergencia'),
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
                          onPressed: _copyLinkToClipboard,
                          icon: const Icon(Icons.copy),
                          label: const Text('Copiar enlace'),
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
            ),
    );
  }
}