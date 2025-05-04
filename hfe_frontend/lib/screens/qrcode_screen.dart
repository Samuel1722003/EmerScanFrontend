import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:hfe_frontend/screens/screen.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  String? userId;
  bool isLoading = true;
  String qrUrlData = ''; // URL del JSON
  String? userName;
  final GlobalKey qrKey = GlobalKey(); // Clave global para capturar el QR

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
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

  Future<void> _fetchUserQR() async {
    if (userId == null) return;

    try {
      final supabase = Supabase.instance.client;

      final userData = await supabase
          .from('usuario_persona')
          .select('nombre, apellido_paterno, codigo_qr')
          .eq('id', userId!)
          .single();

      setState(() {
        userName = '${userData['nombre']} ${userData['apellido_paterno']}';

        try {
          final Map<String, dynamic> qrDataMap = jsonDecode(userData['codigo_qr']);
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
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _shareQRCode() async {
    try {
      if (qrUrlData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No hay código QR para compartir'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Mostrar un indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          );
        },
      );

      // Capturar la imagen del QR
      final RenderRepaintBoundary boundary = qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        Navigator.of(context).pop(); // Cerrar el diálogo de carga
        throw Exception('No se pudo capturar la imagen del QR');
      }
      
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      
      // Cerrar el diálogo de carga
      Navigator.of(context).pop();
      
      // Compartir directamente los bytes como XFile sin guardar en disco
      final result = await Share.shareXFiles(
        [XFile.fromData(pngBytes, mimeType: 'image/png', name: 'qr_code.png')],
        text: 'Información médica de ${userName ?? "Usuario"}',
        subject: 'Código QR médico',
      );
      
      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Código QR compartido exitosamente!'),
            backgroundColor: AppTheme.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error al compartir el QR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir el QR: ${e.toString()}'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _copyBase64ToClipboard() async {
    await Clipboard.setData(ClipboardData(text: qrUrlData));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Código QR copiado al portapapeles'),
          backgroundColor: AppTheme.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Código QR Médico',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserIdAndFetchQR,
            tooltip: 'Recargar QR',
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Cargando código QR...",
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserIdAndFetchQR,
              color: AppTheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        children: [
                          Text(
                            'Información médica de ${userName ?? "Usuario"}',
                            style: AppTheme.heading,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Este código permite acceso a tu información médica esencial en caso de emergencia.',
                            textAlign: TextAlign.center,
                            style: AppTheme.cardContent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.qr_code_2,
                            size: 40,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tu Código QR',
                            style: AppTheme.subheading,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          qrUrlData.isEmpty
                              ? Container(
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'QR no disponible',
                                      style: TextStyle(color: AppTheme.textSecondary),
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        spreadRadius: 2,
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: RepaintBoundary(
                                    key: qrKey,
                                    child: QrImageView(
                                      data: qrUrlData,
                                      version: QrVersions.auto,
                                      size: 250.0,
                                      backgroundColor: Colors.white,
                                      errorStateBuilder: (context, error) {
                                        return Center(
                                          child: Text(
                                            'Error al generar QR',
                                            style: TextStyle(color: Colors.red[700]),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _shareQRCode,
                                icon: const Icon(Icons.share),
                                label: const Text('Compartir'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: _copyBase64ToClipboard,
                                icon: const Icon(Icons.copy),
                                label: const Text('Copiar Código'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: AppTheme.primary),
                              const SizedBox(width: 10),
                              Text('¿Cómo utilizar este QR?', style: AppTheme.subheading),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInstructionStep(
                            icon: Icons.qr_code_scanner,
                            text: 'Escanea el código QR con la cámara de tu dispositivo.',
                          ),
                          const SizedBox(height: 12),
                          _buildInstructionStep(
                            icon: Icons.medical_information,
                            text: 'Accede a tu información médica rápidamente.',
                          ),
                          const SizedBox(height: 12),
                          _buildInstructionStep(
                            icon: Icons.emergency,
                            text: 'Úsalo solo en caso de emergencia o cuando un profesional médico lo solicite.',
                          ),
                          const SizedBox(height: 12),
                          _buildInstructionStep(
                            icon: Icons.privacy_tip,
                            text: 'Tu información está segura y protegida.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInstructionStep({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppTheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTheme.cardContent,
          ),
        ),
      ],
    );
  }
}