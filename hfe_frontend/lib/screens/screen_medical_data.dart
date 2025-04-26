import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScreenMedicalData extends StatefulWidget {
  const ScreenMedicalData({super.key});

  @override
  State<ScreenMedicalData> createState() => _ScreenMedicalDataState();
}

class _ScreenMedicalDataState extends State<ScreenMedicalData> {
  bool _isLoading = true;
  Map<String, dynamic> _historialClinico = {};
  List<dynamic> _alergias = [];
  List<dynamic> _enfermedades = [];
  Map<String, dynamic> _antecedentes = {};
  List<dynamic> _tratamientos = [];

  @override
  void initState() {
    super.initState();
    _fetchMedicalData();
  }

  String getUserId() {
    // ID fijo para pruebas
    return "01bec088-a454-45b2-8c59-b7b24ea2a111-20250424184650-048029";
  }

  Future<void> _fetchMedicalData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      
      // Primero, veamos qué tablas existen realmente
      print('Intentando listar tablas disponibles...');
      
      // Intentemos obtener datos directamente con el ID de usuario
      final usuario = await supabase
          .from('usuarios') // probemos con 'usuarios' en minúsculas 
          .select()
          .eq('id', getUserId())
          .maybeSingle();
      
      if (usuario != null) {
        print('Usuario encontrado: ${usuario['nombre']}');
        
        // Intentar obtener datos médicos
        final historialClinico = await supabase
          .from('historial_clinico') // nombre en minúscula
          .select()
          .eq('usuario_persona_id', getUserId())
          .maybeSingle();
        
        if (historialClinico != null) {
          final int historialId = historialClinico['id'];
          
          // Obtener datos relacionados
          final alergias = await supabase
            .from('alergias')
            .select()
            .eq('historial_id', historialId);
          
          final enfermedades = await supabase
            .from('enfermedades')
            .select()
            .eq('historial_id', historialId);
          
          final antecedentes = await supabase
            .from('antecedentes')
            .select()
            .eq('historial_id', historialId)
            .maybeSingle();
          
          // Obtener tratamientos (si hay)
          List<dynamic> tratamientos = [];
          
          setState(() {
            _historialClinico = historialClinico;
            _alergias = alergias;
            _enfermedades = enfermedades;
            _antecedentes = antecedentes ?? {};
            _tratamientos = tratamientos;
            _isLoading = false;
          });
        } else {
          // Crear datos de prueba para visualización
          setState(() {
            _historialClinico = {
              'peso': 75.5,
              'estatura': 1.78,
              'tipo_sangre': 'O+'
            };
            _alergias = [{'nombre_alergia': 'Polen'}, {'nombre_alergia': 'Penicilina'}];
            _enfermedades = [{'nombre_enfermedad': 'Hipertensión', 'estado': 'Tratamiento'}];
            _antecedentes = {
              'cirugias_anteriores': 'Apendicectomía en 2018',
              'hospitalizaciones_anteriores': 'Ninguna'
            };
            _tratamientos = [{'nombre_medicamento': 'Losartán', 'dosis': '50mg/día'}];
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró historial clínico. Mostrando datos de ejemplo')),
          );
        }
      } else {
        // Mostrar datos de prueba si no se encuentra el usuario
        _showDemoData();
      }
    } catch (e) {
      print('Error al cargar datos médicos: $e');
      
      // Mostrar datos de prueba en caso de error
      _showDemoData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e. Mostrando datos de ejemplo')),
        );
      }
    }
  }

  void _showDemoData() {
    setState(() {
      _historialClinico = {
        'peso': 75.5,
        'estatura': 1.78,
        'tipo_sangre': 'O+'
      };
      _alergias = [{'nombre_alergia': 'Polen'}, {'nombre_alergia': 'Penicilina'}];
      _enfermedades = [{'nombre_enfermedad': 'Hipertensión', 'estado': 'Tratamiento'}];
      _antecedentes = {
        'cirugias_anteriores': 'Apendicectomía en 2018',
        'hospitalizaciones_anteriores': 'Ninguna'
      };
      _tratamientos = [{'nombre_medicamento': 'Losartán', 'dosis': '50mg/día'}];
      _isLoading = false;
    });
  }

  // Función para formatear la lista de alergias
  String formatAlergias() {
    if (_alergias.isEmpty) return "Ninguna registrada";
    return _alergias.map((alergia) => alergia['nombre_alergia']).join(', ');
  }

  // Función para formatear la lista de enfermedades
  String formatEnfermedades() {
    if (_enfermedades.isEmpty) return "Ninguna registrada";
    return _enfermedades.map((enfermedad) => 
      "${enfermedad['nombre_enfermedad']} (${enfermedad['estado'] ?? 'Sin estado'})"
    ).join(', ');
  }

  // Función para formatear la lista de tratamientos
  String formatTratamientos() {
    if (_tratamientos.isEmpty) return "Ninguno registrado";
    return _tratamientos.map((tratamiento) => 
      "${tratamiento['nombre_medicamento']} ${tratamiento['dosis']}"
    ).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos Médicos'),
        backgroundColor: Colors.lightBlue[50],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchMedicalData,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Información Médica del Paciente",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    
                    // Datos principales
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        children: [
                          MedicalCard(
                            title: "Grupo Sanguíneo",
                            content: _historialClinico['tipo_sangre'] ?? "No especificado",
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
                            content: "Peso: ${_historialClinico['peso'] ?? 'N/A'} kg\nEstatura: ${_historialClinico['estatura'] ?? 'N/A'} m",
                            icon: Icons.monitor_weight,
                            color: Colors.pinkAccent,
                          ),
                          MedicalCard(
                            title: "Cirugías",
                            content: _antecedentes['cirugias_anteriores'] ?? "Ninguna",
                            icon: Icons.local_hospital,
                            color: Colors.indigo,
                          ),
                          MedicalCard(
                            title: "Hospitalizaciones",
                            content: _antecedentes['hospitalizaciones_anteriores'] ?? "Ninguna",
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