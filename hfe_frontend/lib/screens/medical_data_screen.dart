import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicalDataScreen extends StatefulWidget {
  final String? userId;
  const MedicalDataScreen({super.key, this.userId});

  @override
  State<MedicalDataScreen> createState() => _MedicalDataScreenState();
}

class _MedicalDataScreenState extends State<MedicalDataScreen> {
  bool isLoading = true;
  bool hasMedicalData = false;
  bool isRegistering = false;

  String? userId;

  // Información del paciente
  String? nombrePaciente;
  double? pesoPaciente;
  double? estaturaPaciente;

  // Contacto de emergencia
  String? contactoNombre;
  String? contactoTelefono;
  String? contactoRelacion;

  // Información médica
  Map<String, dynamic> historialClinico0 = {};
  List<dynamic> alergias0 = [];
  List<dynamic> enfermedades0 = [];
  Map<String, dynamic> antecedentes0 = {};
  List<dynamic> tratamientos0 = [];

  // Controladores para formulario
  final _pesoController = TextEditingController();
  final _estaturaController = TextEditingController();
  final _tipoSangreController = TextEditingController();
  final _alergiasController = TextEditingController();
  final _enfermedadesController = TextEditingController();
  final _cirugiasController = TextEditingController();
  final _hospitalizacionesController = TextEditingController();
  final _antecedentesFamiliaresController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserIdAndCheckMedicalData();
  }

  Future<void> loadUserIdAndCheckMedicalData() async {
    String? id;
    if (widget.userId != null) {
      id = widget.userId;
    } else {
      dynamic prefs = await SharedPreferences.getInstance();
      id = prefs.getString('user_id');
    }

    if (id != null) {
      setState(() => userId = id);
      await checkMedicalData();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo obtener tu información de usuario. Por favor intenta iniciar sesión nuevamente.',
            ),
          ),
        );
      }
    }
  }

  Future<void> checkMedicalData() async {
    try {
      final supabase = Supabase.instance.client;
      final historial =
          await supabase
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
          SnackBar(
            content: Text(
              'Ocurrió un problema al revisar tus datos médicos. Intenta más tarde.',
            ),
          ),
        );
      }
    }
  }

  Future<void> fetchMedicalData() async {
    setState(() => isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // 1. Obtener el historial clínico primero
      final historialClinico =
          await supabase
              .from('historial_clinico')
              .select()
              .eq('usuario_persona_id', userId!)
              .maybeSingle();

      if (historialClinico == null) {
        throw Exception('Historial clínico no encontrado');
      }

      final int historialId = historialClinico['id'];

      // 2. Guardar el historialClínico primero para que esté disponible en fetchPacienteInfo
      setState(() {
        historialClinico0 = historialClinico;
        // Actualizar el peso y estatura directamente
        pesoPaciente = historialClinico['peso']?.toDouble();
        estaturaPaciente = historialClinico['estatura']?.toDouble();
      });

      // 3. Obtener la información del paciente y contacto de emergencia
      await fetchPacienteInfo();

      // 4. Realizar las consultas en paralelo para mejor rendimiento
      final futures = await Future.wait<dynamic>([
        supabase.from('alergias').select().eq('historial_id', historialId),
        supabase.from('enfermedades').select().eq('historial_id', historialId),
        supabase
            .from('antecedentes')
            .select()
            .eq('historial_id', historialId)
            .maybeSingle(),
        supabase
            .from('tratamiento')
            .select('*, tratamiento_enfermedad!inner(enfermedad_id)')
            .eq('tratamiento_enfermedad.enfermedad_id', historialId),
      ]);

      if (mounted) {
        setState(() {
          alergias0 = futures[0];
          enfermedades0 = futures[1];
          antecedentes0 = (futures[2] ?? {}) as Map<String, dynamic>;
          tratamientos0 = futures[3] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error en fetchMedicalData: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudieron cargar tus datos médicos. Revisa tu conexión e intenta nuevamente.',
            ),
          ),
        );
      }
    }
  }

  Future<void> fetchPacienteInfo() async {
    try {
      final supabase = Supabase.instance.client;

      // Obtener información del usuario y contacto de emergencia en paralelo
      final futures = await Future.wait<dynamic>([
        supabase
            .from('usuario_persona')
            .select()
            .eq('id', userId!)
            .maybeSingle(),
        supabase
            .from('contacto_emergencia')
            .select()
            .eq('usuario_persona_id', userId!)
            .maybeSingle(),
      ]);

      final usuario = futures[0];
      final contacto = futures[1];

      if (mounted) {
        setState(() {
          // El nombre completo según tu esquema de base de datos
          nombrePaciente =
              usuario != null
                  ? "${usuario['nombre']} ${usuario['apellido_paterno']} ${usuario['apellido_materno']}"
                  : "No disponible";

          pesoPaciente = historialClinico0['peso']?.toDouble();
          estaturaPaciente = historialClinico0['estatura']?.toDouble();

          // Los nombres de los campos según tu esquema de base de datos
          contactoNombre = contacto?['nombre'] ?? "No disponible";
          contactoTelefono = contacto?['telefono'] ?? "No disponible";
          contactoRelacion = contacto?['relacion'] ?? "No disponible";
        });
      }
    } catch (e) {
      print('Error al obtener información del paciente: $e');
      if (mounted) {
        setState(() {
          nombrePaciente = "Error al cargar";
          contactoNombre = "Error al cargar";
          contactoTelefono = "Error al cargar";
          contactoRelacion = "Error al cargar";
        });
      }
    }
  }

  Future<void> registerMedicalData() async {
    // Validar datos requeridos
    if (_pesoController.text.isEmpty ||
        _estaturaController.text.isEmpty ||
        _tipoSangreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor completa los campos obligatorios: peso, estatura y tipo de sangre.',
          ),
        ),
      );
      return;
    }

    // Validar que peso y estatura sean números válidos
    double? peso;
    double? estatura;

    try {
      peso = double.parse(_pesoController.text);
      estatura = double.parse(_estaturaController.text);

      // Validaciones adicionales
      if (peso <= 0 || peso > 300) {
        throw FormatException('El peso debe estar entre 1 y 300 kg');
      }
      if (estatura <= 0 || estatura > 3) {
        throw FormatException('La estatura debe estar entre 0.1 y 3 metros');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is FormatException
                ? e.message
                : 'Peso y estatura deben ser números válidos. Ej: 70.5',
          ),
        ),
      );
      return;
    }

    // Validar tipo de sangre
    final tipoSangre = _tipoSangreController.text.trim().toUpperCase();
    final tiposSangreValidos = [
      'A+',
      'A-',
      'B+',
      'B-',
      'O+',
      'O-',
      'AB+',
      'AB-',
    ];
    if (!tiposSangreValidos.contains(tipoSangre)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tipo de sangre no válido. Debe ser uno de los siguientes: ${tiposSangreValidos.join(', ')}',
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // 1. Insertar historial clínico
      final historialResponse =
          await supabase
              .from('historial_clinico')
              .insert({
                'usuario_persona_id': userId!,
                'peso': peso,
                'estatura': estatura,
                'tipo_sangre': tipoSangre,
              })
              .select('id')
              .single();

      final historialId = historialResponse['id'];

      // 2. Insertar alergias si existen
      if (_alergiasController.text.isNotEmpty) {
        final alergiasList =
            _alergiasController.text
                .split(',')
                .map((a) => a.trim())
                .where((a) => a.isNotEmpty)
                .toList();

        if (alergiasList.isNotEmpty) {
          await supabase
              .from('alergias')
              .insert(
                alergiasList
                    .map(
                      (alergia) => {
                        'historial_id': historialId,
                        'nombre_alergia': alergia,
                      },
                    )
                    .toList(),
              );
        }
      }

      // 3. Insertar enfermedades si existen
      if (_enfermedadesController.text.isNotEmpty) {
        final enfermedadesList =
            _enfermedadesController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();

        if (enfermedadesList.isNotEmpty) {
          await supabase
              .from('enfermedades')
              .insert(
                enfermedadesList
                    .map(
                      (enfermedad) => {
                        'historial_id': historialId,
                        'nombre_enfermedad': enfermedad,
                        'fecha_de_diagnostico':
                            DateTime.now().toIso8601String(),
                        'estado': 'Tratamiento',
                      },
                    )
                    .toList(),
              );
        }
      }

      // 4. Insertar antecedentes
      await supabase.from('antecedentes').insert({
        'historial_id': historialId,
        'cirugias_anteriores': _cirugiasController.text.trim(),
        'hospitalizaciones_anteriores':
            _hospitalizacionesController.text.trim(),
        'antecedentes_familiares':
            _antecedentesFamiliaresController.text.trim(),
      });

      setState(() {
        hasMedicalData = true;
        isRegistering = false;
      });

      await fetchMedicalData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos médicos guardados correctamente.'),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ocurrió un error al guardar los datos. Verifica la información e intenta de nuevo. Error: $e',
            ),
          ),
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

          // Sección de datos físicos
          const Text(
            "Datos Físicos",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _pesoController,
            decoration: const InputDecoration(
              labelText: 'Peso (kg) *',
              border: OutlineInputBorder(),
              hintText: 'Ej. 68.5',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),

          TextField(
            controller: _estaturaController,
            decoration: const InputDecoration(
              labelText: 'Estatura (m) *',
              border: OutlineInputBorder(),
              hintText: 'Ej. 1.75',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),

          TextField(
            controller: _tipoSangreController,
            decoration: const InputDecoration(
              labelText: 'Tipo de sangre *',
              border: OutlineInputBorder(),
              hintText: 'Ej. O+',
              helperText: 'Valores válidos: A+, A-, B+, B-, O+, O-, AB+, AB-',
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 25),

          // Sección de condiciones médicas
          const Text(
            "Condiciones Médicas",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

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
          const SizedBox(height: 25),

          // Sección de antecedentes
          const Text(
            "Antecedentes",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _cirugiasController,
            decoration: const InputDecoration(
              labelText: 'Cirugías previas',
              border: OutlineInputBorder(),
              hintText: 'Ej. Apendicectomía en 2018',
            ),
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 15),

          TextField(
            controller: _hospitalizacionesController,
            decoration: const InputDecoration(
              labelText: 'Hospitalizaciones previas',
              border: OutlineInputBorder(),
              hintText: 'Ej. Hospitalización por fractura en 2019',
            ),
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 15),

          TextField(
            controller: _antecedentesFamiliaresController,
            decoration: const InputDecoration(
              labelText: 'Antecedentes familiares',
              border: OutlineInputBorder(),
              hintText: 'Ej. Diabetes tipo 2 (padre), Hipertensión (abuela)',
            ),
            minLines: 2,
            maxLines: 4,
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

  String formatTratamientos() {
    if (tratamientos0.isEmpty) return "Ninguno registrado";
    return tratamientos0
        .map(
          (t) =>
              "${t['nombre_medicamento']}: ${t['dosis']} cada ${t['frecuencia']}",
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
        child: CustomScrollView(
          slivers: [
            if (userId != null)
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.lightBlue.shade100,
                automaticallyImplyLeading: false,
                expandedHeight: 175,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nombre: ${nombrePaciente ?? 'Cargando...'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Peso: ${pesoPaciente != null ? pesoPaciente!.toStringAsFixed(2) : 'No registrado'} kg",
                        ),
                        Text(
                          "Estatura: ${estaturaPaciente != null ? estaturaPaciente!.toStringAsFixed(2) : 'No registrada'} m",
                        ),

                        if (pesoPaciente != null &&
                            estaturaPaciente != null &&
                            estaturaPaciente! > 0)
                          Text(
                            "IMC: ${(pesoPaciente! / (estaturaPaciente! * estaturaPaciente!)).toStringAsFixed(2)}",
                          ),

                        const SizedBox(height: 12),
                        const Text(
                          "Contacto de emergencia:",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text("Nombre: ${contactoNombre ?? 'No registrado'}"),
                        Text(
                          "Teléfono: ${contactoTelefono ?? 'No registrado'}",
                        ),
                        if (contactoRelacion != null)
                          Text("Relación: $contactoRelacion"),
                      ],
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Información Médica del Paciente",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid.count(
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
                        "Peso: ${pesoPaciente?.toStringAsFixed(2) ?? 'N/A'} kg\nEstatura: ${estaturaPaciente?.toStringAsFixed(2) ?? 'N/A'} m",
                    icon: Icons.monitor_weight,
                    color: Colors.pinkAccent,
                  ),
                  MedicalCard(
                    title: "Cirugías",
                    content: antecedentes0['cirugias_anteriores'] ?? "Ninguna",
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
                  MedicalCard(
                    title: "Antecedentes Familiares",
                    content:
                        antecedentes0['antecedentes_familiares'] ??
                        "Ninguno registrado",
                    icon: Icons.family_restroom,
                    color: Colors.blueAccent,
                  ),
                  MedicalCard(
                    title: "Tratamientos",
                    content: formatTratamientos(),
                    icon: Icons.medication,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Actualizar datos médicos"),
                    onPressed: () => setState(() => isRegistering = true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
