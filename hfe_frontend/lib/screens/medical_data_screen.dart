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
  bool hasMedicalData = false;
  bool isRegistering = false;
  String? userId;

  Map<String, dynamic> historialClinico0 = {};
  List<dynamic> alergias0 = [];
  List<dynamic> enfermedades0 = [];
  Map<String, dynamic> antecedentes0 = {};
  List<dynamic> tratamientos0 = [];

  final _pesoController = TextEditingController();
  final _estaturaController = TextEditingController();
  final _tipoSangreController = TextEditingController();
  final _alergiasController = TextEditingController();
  final _enfermedadesController = TextEditingController();
  final _cirugiasController = TextEditingController();
  final _hospitalizacionesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserIdAndCheckMedicalData();
  }

  Future<void> loadUserIdAndCheckMedicalData() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');

    if (id != null) {
      setState(() => userId = id);
      await checkMedicalData();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener tu información de usuario. Por favor intenta iniciar sesión nuevamente.'),
          ),
        );
      }
    }
  }

  Future<void> checkMedicalData() async {
    try {
      final supabase = Supabase.instance.client;
      final historial = await supabase
          .from('historial_clinico')
          .select()
          .eq('usuario_persona_id', userId!)
          .maybeSingle();

      setState(() => hasMedicalData = historial != null);

      if (hasMedicalData) {
        await fetchMedicalData();
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocurrió un problema al revisar tus datos médicos. Intenta más tarde.')),
        );
      }
    }
  }

  Future<void> fetchMedicalData() async {
    setState(() => isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      final historialClinico = await supabase
          .from('historial_clinico')
          .select()
          .eq('usuario_persona_id', userId!)
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

      final antecedentes = await supabase
          .from('antecedentes')
          .select()
          .eq('historial_id', historialId)
          .maybeSingle();

      setState(() {
        historialClinico0 = historialClinico;
        alergias0 = alergias;
        enfermedades0 = enfermedades;
        antecedentes0 = antecedentes ?? {};
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudieron cargar tus datos médicos. Revisa tu conexión e intenta nuevamente.')),
        );
      }
    }
  }

  Future<void> registerMedicalData() async {
    if (_pesoController.text.isEmpty ||
        _estaturaController.text.isEmpty ||
        _tipoSangreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa los campos obligatorios: peso, estatura y tipo de sangre.'),
        ),
      );
      return;
    }

    double? peso;
    double? estatura;

    try {
      peso = double.parse(_pesoController.text);
      estatura = double.parse(_estaturaController.text);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peso y estatura deben ser números válidos. Ej: 70.5'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      final historialResponse = await supabase
          .from('historial_clinico')
          .insert({
            'usuario_persona_id': userId!,
            'peso': peso,
            'estatura': estatura,
            'tipo_sangre': _tipoSangreController.text.trim().toUpperCase(),
          })
          .select('id')
          .single();

      final historialId = historialResponse['id'];

      if (_alergiasController.text.isNotEmpty) {
        final alergiasList = _alergiasController.text
            .split(',')
            .map((a) => a.trim())
            .where((a) => a.isNotEmpty)
            .toList();

        await supabase.from('alergias').insert(
          alergiasList
              .map((alergia) => {
                    'historial_id': historialId,
                    'nombre_alergia': alergia,
                  })
              .toList(),
        );
      }

      if (_enfermedadesController.text.isNotEmpty) {
        final enfermedadesList = _enfermedadesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        await supabase.from('enfermedades').insert(
          enfermedadesList
              .map((enfermedad) => {
                    'historial_id': historialId,
                    'nombre_enfermedad': enfermedad,
                    'fecha_de_diagnostico': DateTime.now().toIso8601String(),
                    'estado': 'Tratamiento',
                  })
              .toList(),
        );
      }

      await supabase.from('antecedentes').insert({
        'historial_id': historialId,
        'cirugias_anteriores': _cirugiasController.text.trim(),
        'hospitalizaciones_anteriores': _hospitalizacionesController.text.trim(),
      });

      setState(() {
        hasMedicalData = true;
        isRegistering = false;
      });

      await fetchMedicalData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos médicos guardados correctamente.')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocurrió un error al guardar los datos. Verifica la información e intenta de nuevo.')),
        );
      }
    }
  }

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Registro de Datos Médicos Iniciales',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _pesoController,
            decoration: const InputDecoration(
              labelText: 'Peso (kg)',
              border: OutlineInputBorder(),
              hintText: 'Ej. 68.5',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _estaturaController,
            decoration: const InputDecoration(
              labelText: 'Estatura (m)',
              border: OutlineInputBorder(),
              hintText: 'Ej. 1.75',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _tipoSangreController,
            decoration: const InputDecoration(
              labelText: 'Tipo de sangre',
              border: OutlineInputBorder(),
              hintText: 'Ej. O+',
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _alergiasController,
            decoration: const InputDecoration(
              labelText: 'Alergias (separadas por comas)',
              border: OutlineInputBorder(),
              hintText: 'Ej. Penicilina, Polen',
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _enfermedadesController,
            decoration: const InputDecoration(
              labelText: 'Enfermedades (separadas por comas)',
              border: OutlineInputBorder(),
              hintText: 'Ej. Diabetes, Hipertensión',
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _cirugiasController,
            decoration: const InputDecoration(
              labelText: 'Cirugías previas',
              border: OutlineInputBorder(),
              hintText: 'Ej. Apendicectomía en 2018',
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _hospitalizacionesController,
            decoration: const InputDecoration(
              labelText: 'Hospitalizaciones previas',
              border: OutlineInputBorder(),
              hintText: 'Ej. Ninguna',
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: isLoading ? null : registerMedicalData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child:
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                      'Guardar Datos Médicos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed:
                isLoading ? null : () => setState(() => isRegistering = false),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!hasMedicalData && !isRegistering) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Datos Médicos'),
          backgroundColor: Colors.lightBlue[50],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No se encontraron datos médicos registrados',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() => isRegistering = true),
                child: const Text('Registrar Datos Médicos'),
              ),
            ],
          ),
        ),
      );
    }

    if (isRegistering) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Registro Médico'),
          backgroundColor: Colors.lightBlue[50],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => isRegistering = false),
          ),
        ),
        body: _buildRegistrationForm(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos Médicos'),
        backgroundColor: Colors.lightBlue[50],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchMedicalData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchMedicalData,
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
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  children: [
                    MedicalCard(
                      title: "Grupo Sanguíneo",
                      content:
                          historialClinico0['tipo_sangre'] ?? "No especificado",
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
                      title: "Medidas",
                      content:
                          "Peso: ${historialClinico0['peso'] ?? 'N/A'} kg\nEstatura: ${historialClinico0['estatura'] ?? 'N/A'} m",
                      icon: Icons.monitor_weight,
                      color: Colors.pinkAccent,
                    ),
                    MedicalCard(
                      title: "Cirugías",
                      content:
                          antecedentes0['cirugias_anteriores'] ?? "Ninguna",
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
