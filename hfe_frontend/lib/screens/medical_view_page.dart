import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class MedicalViewPage extends StatefulWidget {
  const MedicalViewPage({super.key});

  @override
  State<MedicalViewPage> createState() => _MedicalViewPageState();
}

class _MedicalViewPageState extends State<MedicalViewPage> {
  bool isLoading = true;
  bool isValid = false;
  String errorMessage = '';
  Map<String, dynamic> userData = {};
  Map<String, dynamic> medicalData = {};
  Map<String, dynamic> allergiesData = {};
  Map<String, dynamic> diseasesData = {};
  String? contactoEmergencia;
  bool isEmergency = true;

  @override
  void initState() {
    super.initState();
    _validateTokenAndFetchData();
  }

  Future<void> _validateTokenAndFetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Obtener el token de la URL
      final uri = Uri.base;
      final token = uri.queryParameters['token'];

      if (token == null || token.isEmpty) {
        throw Exception('Token no proporcionado');
      }

      // Decodificar el token
      final decodedBytes = base64Url.decode(token);
      final decodedToken = utf8.decode(decodedBytes);
      final parts = decodedToken.split(':');

      if (parts.length != 3) {
        throw Exception('Formato de token inválido');
      }

      final userId = parts[0];
      final timestamp = int.parse(parts[1]);

      // Verificar si el token ha expirado
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().isAfter(expiryTime)) {
        throw Exception('El token ha expirado');
      }

      // Verificar el token en Supabase
      final supabase = Supabase.instance.client;
      final tokenRecord =
          await supabase
              .from('medical_tokens')
              .select()
              .eq('token', token)
              .maybeSingle();

      if (tokenRecord == null) {
        throw Exception('Token no encontrado o inválido');
      }

      // Obtener datos del usuario
      final userRecord =
          await supabase
              .from('usuario_persona')
              .select(
                'nombre, apellido_paterno, apellido_materno, fecha_nacimiento, genero, telefono',
              )
              .eq('id', userId)
              .single();

      // Obtener datos médicos
      final historialClinico =
          await supabase
              .from('historial_clinico')
              .select()
              .eq('usuario_persona_id', userId)
              .maybeSingle();

      if (historialClinico == null) {
        throw Exception('Datos médicos no encontrados');
      }

      final historialId = historialClinico['id'];

      // Obtener todos los datos médicos relacionados en paralelo
      final alergias = await supabase
          .from('alergias')
          .select()
          .eq('historial_id', historialId);
      final enfermedades = await supabase
          .from('enfermedades')
          .select()
          .eq('historial_id', historialId);
      final contactoEmergencia =
          await supabase
              .from('contactos_emergencia')
              .select()
              .eq('usuario_id', userId)
              .maybeSingle();

      setState(() {
        userData = userRecord;
        medicalData = historialClinico;
        allergiesData = {'items': alergias};
        diseasesData = {'items': enfermedades};
        this.contactoEmergencia = contactoEmergencia?['telefono'];
        isLoading = false;
        isValid = true;
      });
    } catch (e) {
      print('Error al validar token: $e');
      setState(() {
        isLoading = false;
        isValid = false;
        errorMessage = e.toString();
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'No disponible';

    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatFullName() {
    final nombre = userData['nombre'] ?? '';
    final apellidoPaterno = userData['apellido_paterno'] ?? '';
    final apellidoMaterno = userData['apellido_materno'] ?? '';

    return '$nombre $apellidoPaterno $apellidoMaterno'.trim();
  }

  Future<void> _makeEmergencyCall() async {
    if (contactoEmergencia == null || contactoEmergencia!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay número de emergencia disponible')),
      );
      return;
    }

    final url = Uri.parse('tel:$contactoEmergencia');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo iniciar la llamada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información Médica de Emergencia'),
        backgroundColor: isEmergency ? Colors.red[100] : Colors.blue[100],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : !isValid
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 70,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Acceso inválido',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No se pudo acceder a la información médica: $errorMessage',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner de emergencia
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.emergency,
                                color: Colors.red[700],
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'INFORMACIÓN MÉDICA DE EMERGENCIA',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Este registro contiene información médica crítica para situaciones de emergencia.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Información básica del paciente
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DATOS DEL PACIENTE',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildInfoRow(
                              'Nombre completo:',
                              _formatFullName(),
                            ),
                            _buildInfoRow(
                              'Fecha de nacimiento:',
                              _formatDate(userData['fecha_nacimiento']),
                            ),
                            _buildInfoRow(
                              'Género:',
                              userData['genero'] ?? 'No especificado',
                            ),
                            _buildInfoRow(
                              'Teléfono:',
                              userData['telefono'] ?? 'No disponible',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Información médica crítica
                    Card(
                      margin: EdgeInsets.zero,
                      color: Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.medical_information,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'INFORMACIÓN MÉDICA CRÍTICA',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _buildInfoRow(
                              'Tipo de sangre:',
                              medicalData['tipo_sangre'] ?? 'No especificado',
                              isHighlighted: true,
                            ),
                            _buildInfoRow(
                              'Alergias:',
                              _formatAlergias(),
                              isHighlighted: true,
                            ),
                            _buildInfoRow(
                              'Enfermedades crónicas:',
                              _formatEnfermedades(),
                              isHighlighted: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Datos antropométricos
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DATOS ANTROPOMÉTRICOS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildInfoRow(
                              'Peso:',
                              '${medicalData['peso'] ?? 'No registrado'} kg',
                            ),
                            _buildInfoRow(
                              'Estatura:',
                              '${medicalData['estatura'] ?? 'No registrado'} m',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Contacto de emergencia
                    if (contactoEmergencia != null &&
                        contactoEmergencia!.isNotEmpty)
                      Card(
                        margin: EdgeInsets.zero,
                        color: Colors.orange[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CONTACTO DE EMERGENCIA',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      contactoEmergencia!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _makeEmergencyCall,
                                    icon: const Icon(Icons.call),
                                    label: const Text('Llamar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    // Nota de privacidad
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Esta información se proporciona con fines médicos de emergencia. '
                        'Acceso temporal autorizado por el paciente mediante código QR.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isHighlighted ? Colors.red[700] : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? Colors.red[900] : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAlergias() {
    final alergias = allergiesData['items'] as List<dynamic>;
    if (alergias.isEmpty) return "Ninguna reportada";

    return alergias
        .map((a) => a['nombre_alergia'] ?? 'No especificada')
        .join(', ');
  }

  String _formatEnfermedades() {
    final enfermedades = diseasesData['items'] as List<dynamic>;
    if (enfermedades.isEmpty) return "Ninguna reportada";

    return enfermedades
        .map(
          (e) =>
              "${e['nombre_enfermedad'] ?? 'No especificada'} (${e['estado'] ?? 'Sin estado'})",
        )
        .join(', ');
  }
}
