import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hfe_frontend/screens/screen.dart';

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

  void _showDetailDialog(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: AppTheme.primary),
              const SizedBox(width: 10),
              Text(title),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(content, style: const TextStyle(fontSize: 16)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

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
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
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
                "Cargando información médica...",
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (!hasMedicalData && !isRegistering) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Datos Médicos'),
          backgroundColor: AppTheme.primary,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.medical_information,
                  size: 80,
                  color: AppTheme.primary,
                ),
                const SizedBox(height: 24),
                const Text(
                  'No se encontraron datos médicos registrados',
                  style: AppTheme.subheading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Para recibir una mejor atención médica, te recomendamos registrar tu información médica básica.',
                  style: TextStyle(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => setState(() => isRegistering = true),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Registrar Datos Médicos'),
                  style: AppTheme.primaryButtonStyle,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (isRegistering) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Registro Médico'),
          backgroundColor: AppTheme.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => isRegistering = false),
          ),
        ),
        body: _buildRegistrationForm(),
      );
    }

    final hasBmi =
        pesoPaciente != null &&
        estaturaPaciente != null &&
        estaturaPaciente! > 0;
    final bmi =
        hasBmi ? pesoPaciente! / (estaturaPaciente! * estaturaPaciente!) : null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Datos Médicos',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar datos',
            onPressed: () {
              fetchMedicalData().then((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Datos actualizados correctamente'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              });
            },
          ),
          if (widget.userId ==
              null) // Only show edit button for logged-in users
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar datos',
              onPressed: () => setState(() => isRegistering = true),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchMedicalData,
        color: AppTheme.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: MedicalProfileHeader(
                nombre: nombrePaciente,
                peso: pesoPaciente,
                estatura: estaturaPaciente,
                contactoNombre: contactoNombre,
                contactoTelefono: contactoTelefono,
                contactoRelacion: contactoRelacion,
              ),
            ),
            if (bmi != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BMIIndicator(bmi: bmi),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Información Médica", style: AppTheme.heading),
                    SizedBox(height: 4),
                    Text(
                      "Resumen de tu historial clínico y condiciones médicas",
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.1,
                children: [
                  MedicalCard(
                    title: "Grupo Sanguíneo",
                    content:
                        historialClinico0['tipo_sangre'] ?? "No especificado",
                    icon: Icons.bloodtype,
                    color: AppTheme.bloodType,
                    onTap:
                        () => _showDetailDialog(
                          context,
                          "Grupo Sanguíneo",
                          historialClinico0['tipo_sangre'] ?? "No especificado",
                          Icons.bloodtype,
                        ),
                  ),
                  MedicalCard(
                    title: "Alergias",
                    content: formatAlergias(),
                    icon: Icons.warning_amber_rounded,
                    color: AppTheme.allergies,
                    onTap:
                        () => _showDetailDialog(
                          context,
                          "Alergias",
                          formatAlergias(),
                          Icons.warning_amber_rounded,
                        ),
                  ),
                  MedicalCard(
                    title: "Enfermedades",
                    content: formatEnfermedades(),
                    icon: Icons.medical_services_outlined,
                    color: AppTheme.diseases,
                    onTap:
                        () => _showDetailDialog(
                          context,
                          "Enfermedades",
                          formatEnfermedades(),
                          Icons.medical_services_outlined,
                        ),
                  ),
                  MedicalCard(
                    title: "Medidas",
                    content:
                        "Peso: ${pesoPaciente?.toStringAsFixed(2) ?? 'N/A'} kg\nEstatura: ${estaturaPaciente?.toStringAsFixed(2) ?? 'N/A'} m",
                    icon: Icons.monitor_weight,
                    color: Colors.pinkAccent,
                    onTap:
                        () => _showDetailDialog(
                          context,
                          "Medidas",
                          "Peso: ${pesoPaciente?.toStringAsFixed(2) ?? 'N/A'} kg\nEstatura: ${estaturaPaciente?.toStringAsFixed(2) ?? 'N/A'} m",
                          Icons.monitor_weight,
                        ),
                  ),
                  MedicalCard(
                    title: "Cirugías",
                    content: antecedentes0['cirugias_anteriores'] ?? "Ninguna",
                    icon: Icons.local_hospital,
                    color: Colors.indigo,
                    onTap:
                        () => _showDetailDialog(
                          context,
                          "Cirugías",
                          antecedentes0['cirugias_anteriores'] ?? "Ninguna",
                          Icons.local_hospital,
                        ),
                  ),
                  MedicalCard(
                    title: "Hospitalizaciones",
                    content:
                        antecedentes0['hospitalizaciones_anteriores'] ??
                        "Ninguna",
                    icon: Icons.local_hospital_outlined,
                    color: Colors.teal,
                    onTap:
                        () => _showDetailDialog(
                          context,
                          "Hospitalizaciones",
                          antecedentes0['hospitalizaciones_anteriores'] ??
                              "Ninguna",
                          Icons.local_hospital_outlined,
                        ),
                  ),
                  MedicalCard(
                    title: "Antecedentes Familiares",
                    content:
                        antecedentes0['antecedentes_familiares'] ??
                        "Ninguno registrado",
                    icon: Icons.family_restroom,
                    color: Colors.blueAccent,
                    onTap:
                        () => _showDetailDialog(
                          context,
                          "Antecedentes Familiares",
                          antecedentes0['antecedentes_familiares'] ??
                              "Ninguno registrado",
                          Icons.family_restroom,
                        ),
                  ),
                  MedicalCard(
                    title: "Tratamientos",
                    content: formatTratamientos(),
                    icon: Icons.medication,
                    color: Colors.green,
                    onTap:
                        () => _showDetailDialog(
                          context,
                          "Tratamientos",
                          formatTratamientos(),
                          Icons.medication,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}