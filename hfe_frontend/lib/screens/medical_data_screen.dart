import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicalDataScreen extends StatefulWidget {
  const MedicalDataScreen({super.key});

  @override
  State<MedicalDataScreen> createState() => _MedicalDataScreenState();
}

class _MedicalDataScreenState extends State<MedicalDataScreen> {
  bool isLoading = true;
  String? userId;
  Map<String, dynamic> historialClinico0 = {};
  List<dynamic> alergias0 = [];
  List<dynamic> enfermedades0 = [];
  Map<String, dynamic> antecedentes0 = {};
  List<dynamic> tratamientos0 = [];

  @override
  void initState() {
    super.initState();
    loadUserIdAndFetchMedicalData();
  }

  Future<void> loadUserIdAndFetchMedicalData() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');

    if (id != null) {
      setState(() {
        userId = id;
      });
      fetchMedicalData();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se encontró el ID de usuario'),
          ),
        );
      }
    }
  }

  Future<void> fetchMedicalData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final supabase = Supabase.instance.client;
      final userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final usuario =
          await supabase
              .from('usuario_persona')
              .select()
              .eq('id', userId)
              .maybeSingle();

      if (usuario == null) {
        throw Exception('Usuario no encontrado');
      }

      final historialClinico =
          await supabase
              .from('historial_clinico')
              .select()
              .eq('usuario_persona_id', userId)
              .maybeSingle();

      if (historialClinico == null) {
        throw Exception('Historial clínico no encontrado');
      }

      final int historialId = historialClinico['id'];

      final alergias = await supabase
          .from('alergias')
          .select()
          .eq('historial_id', historialId);

      final enfermedades = await supabase
          .from('enfermedades')
          .select()
          .eq('historial_id', historialId);

      final antecedentes =
          await supabase
              .from('antecedentes')
              .select()
              .eq('historial_id', historialId)
              .maybeSingle();

      // Aquí igual agregamos validación
      setState(() {
        historialClinico0 = historialClinico;
        alergias0 = alergias ?? [];
        enfermedades0 = enfermedades ?? [];
        antecedentes0 = antecedentes ?? {};
        tratamientos0 = []; // Puedes agregar tratamientos aquí después
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos médicos: $e');
      showDemoData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al cargar datos: $e. Mostrando datos de ejemplo',
            ),
          ),
        );
      }
    }
  }

  void showDemoData() {
    setState(() {
      historialClinico0 = {'peso': 75.5, 'estatura': 1.78, 'tipo_sangre': 'O+'};
      alergias0 = [
        {'nombre_alergia': 'Polen'},
        {'nombre_alergia': 'Penicilina'},
      ];
      enfermedades0 = [
        {'nombre_enfermedad': 'Hipertensión', 'estado': 'Tratamiento'},
      ];
      antecedentes0 = {
        'cirugias_anteriores': 'Apendicectomía en 2018',
        'hospitalizaciones_anteriores': 'Ninguna',
      };
      tratamientos0 = [
        {'nombre_medicamento': 'Losartán', 'dosis': '50mg/día'},
      ];
      isLoading = false;
    });
  }

  String formatAlergias() {
    if (alergias0.isEmpty) return "Ninguna registrada";
    return alergias0.map((a) => a['nombre_alergia']).join(', ');
  }

  String formatEnfermedades() {
    if (enfermedades0.isEmpty) return "Ninguna registrada";
    return enfermedades0
        .map(
          (e) => "${e['nombre_enfermedad']} (${e['estado'] ?? 'Sin estado'})",
        )
        .join(', ');
  }

  String formatTratamientos() {
    if (tratamientos0.isEmpty || tratamientos0.any((t) => t == null)) {
      return "Ninguno registrado";
    }
    return tratamientos0
        .map(
          (t) =>
              "${t['nombre_medicamento'] ?? 'Desconocido'} ${t['dosis'] ?? ''}",
        )
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos Médicos'),
        backgroundColor: Colors.lightBlue[50],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: fetchMedicalData,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Información Médica del Paciente",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          children: [
                            MedicalCard(
                              title: "Grupo Sanguíneo",
                              content:
                                  historialClinico0['tipo_sangre'] ??
                                  "No especificado",
                              icon: Icons.bloodtype,
                              color: Colors.redAccent,
                            ),
                            MedicalCard(
                              title: "Alergias",
                              content: formatAlergias(),
                              icon: Icons.warning,
                              color: Colors.orangeAccent,
                            ),
                            MedicalCard(
                              title: "Enfermedades",
                              content: formatEnfermedades(),
                              icon: Icons.sick,
                              color: Colors.deepPurpleAccent,
                            ),
                            MedicalCard(
                              title: "Medicamentos",
                              content: formatTratamientos(),
                              icon: Icons.medical_services,
                              color: Colors.green,
                            ),
                            MedicalCard(
                              title: "Medidas",
                              content:
                                  "Peso: ${historialClinico0['peso'] ?? 'N/A'} kg\nEstatura: ${historialClinico0['estatura'] ?? 'N/A'} m",
                              icon: Icons.monitor_weight,
                              color: Colors.pinkAccent,
                            ),
                            MedicalCard(
                              title: "Cirugías",
                              content:
                                  antecedentes0['cirugias_anteriores'] ??
                                  "Ninguna",
                              icon: Icons.local_hospital,
                              color: Colors.indigo,
                            ),
                            MedicalCard(
                              title: "Hospitalizaciones",
                              content:
                                  antecedentes0['hospitalizaciones_anteriores'] ??
                                  "Ninguna",
                              icon: Icons.local_hospital_outlined,
                              color: Colors.teal,
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
}
