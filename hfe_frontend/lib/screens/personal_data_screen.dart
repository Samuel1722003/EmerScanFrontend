import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hfe_frontend/screens/screen.dart';
import 'package:hfe_frontend/screens/widgets.dart';

final supabase = Supabase.instance.client;

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _emergencyNameController =
      TextEditingController();
  final TextEditingController _emergencyPhoneController =
      TextEditingController();

  String _selectedGender = "Femenino";
  bool _isEditing = false;
  bool _isLoading = false;
  String? _userId;

  // Valores para el Dropdown de relación
  final List<String> relaciones = [
    'Padre',
    'Madre',
    'Pareja',
    'Hermano',
    'Hermana',
    'Hijo',
    'Hija',
    'Amigo',
    'Amiga',
    'Otro',
  ];
  String? _selectedRelacion;

  @override
  void initState() {
    super.initState();
    loadUserIdAndCheckMedicalData();
  }

  Future<void> loadUserIdAndCheckMedicalData() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');

    if (id != null) {
      setState(() => _userId = id);
      await _loadUserData();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se encontró el ID de usuario'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _validatePhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), ''); // solo dígitos
    return cleaned.length >= 8 && cleaned.length <= 15;
  }

  bool _validateDate(String date) {
    try {
      DateTime.parse(date);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadUserData() async {
    if (_userId == null) return;

    setState(() => _isLoading = true);

    try {
      // Consultas en paralelo para mejor rendimiento
      final futures = await Future.wait<dynamic>([
        supabase
            .from('usuario_persona')
            .select()
            .eq('id', _userId!)
            .maybeSingle(),
        supabase
            .from('contacto_emergencia')
            .select()
            .eq('usuario_persona_id', _userId!)
            .maybeSingle(),
      ]);

      final userResponse = futures[0];
      final contactoResponse = futures[1];

      if (userResponse != null) {
        _firstNameController.text = userResponse['nombre'] ?? '';
        _lastNameController.text =
            "${userResponse['apellido_paterno'] ?? ''} ${userResponse['apellido_materno'] ?? ''}"
                .trim();
        _birthDateController.text = userResponse['fecha_nacimiento'] ?? '';
        _selectedGender = userResponse['genero'] ?? 'Femenino';
      }

      if (contactoResponse != null) {
        _emergencyNameController.text = contactoResponse['nombre'] ?? '';
        _emergencyPhoneController.text = contactoResponse['telefono'] ?? '';
        _selectedRelacion = contactoResponse['relacion'] ?? 'Otro';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateUserData() async {
    if (_userId == null) return;

    // Validaciones
    if (_firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre no puede estar vacío.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_validateDate(_birthDateController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fecha de nacimiento no válida (formato: AAAA-MM-DD).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_validatePhoneNumber(_emergencyPhoneController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Número de teléfono no válido.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String apellidoPaterno = '';
      String apellidoMaterno = '';
      final apellidos = _lastNameController.text.trim().split(' ');
      if (apellidos.isNotEmpty) apellidoPaterno = apellidos[0];
      if (apellidos.length > 1) {
        apellidoMaterno = apellidos.sublist(1).join(' ');
      }

      // Actualizar datos personales
      await supabase
          .from('usuario_persona')
          .update({
            'nombre': _firstNameController.text.trim(),
            'apellido_paterno': apellidoPaterno,
            'apellido_materno': apellidoMaterno,
            'fecha_nacimiento': _birthDateController.text.trim(),
            'genero': _selectedGender,
          })
          .eq('id', _userId!);

      // Verificar si ya hay un contacto de emergencia para este usuario
      final existingContact =
          await supabase
              .from('contacto_emergencia')
              .select('id')
              .eq('usuario_persona_id', _userId!)
              .maybeSingle();

      if (existingContact != null) {
        await supabase
            .from('contacto_emergencia')
            .update({
              'nombre': _emergencyNameController.text.trim(),
              'telefono': _emergencyPhoneController.text.trim(),
              'relacion': _selectedRelacion,
            })
            .eq('id', existingContact['id']);
      } else {
        await supabase.from('contacto_emergencia').insert({
          'nombre': _emergencyNameController.text.trim(),
          'telefono': _emergencyPhoneController.text.trim(),
          'usuario_persona_id': _userId!,
          'relacion': _selectedRelacion ?? 'Otro',
        });
      }

      // Primero recargar los datos
      await _loadUserData();

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos actualizados correctamente.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Función para cancelar la edición y restaurar los valores originales
  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _loadUserData(); // Restaurar los datos originales
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && !_isEditing) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text(
            'Datos Personales',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppTheme.primary,
          elevation: 0,
        ),
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
                "Cargando información personal...",
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Datos Personales',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar datos',
            onPressed: () {
              _loadUserData().then((_) {
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
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar datos',
            onPressed: () => setState(() => _isEditing = true),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de título
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.primary,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_firstNameController.text} ${_lastNameController.text}',
                          style: AppTheme.heading,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Información personal y contacto de emergencia',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text("Datos Personales", style: AppTheme.heading),
            const SizedBox(height: 8),
            Text(
              "Información básica de tu perfil",
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),

            // Datos personales
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomInputField(
                    label: 'Nombres',
                    controller: _firstNameController,
                    icon: Icons.person,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  CustomInputField(
                    label: 'Apellidos',
                    controller: _lastNameController,
                    icon: Icons.family_restroom,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  CustomInputField(
                    label: 'Fecha de nacimiento (AAAA-MM-DD)',
                    controller: _birthDateController,
                    icon: Icons.calendar_today,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  _isEditing
                      ? GenderDropdown(
                        selectedGender: _selectedGender,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedGender = value);
                          }
                        },
                      )
                      : CustomInputField(
                        label: 'Género',
                        controller: TextEditingController(
                          text: _selectedGender,
                        ),
                        icon: Icons.person_outline,
                        isEditing: false,
                      ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text("Contacto de Emergencia", style: AppTheme.heading),
            const SizedBox(height: 8),
            Text(
              "Información para casos de emergencia",
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),

            // Contacto de emergencia
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomInputField(
                    label: 'Nombre completo',
                    controller: _emergencyNameController,
                    icon: Icons.contact_emergency,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  CustomInputField(
                    label: 'Número de teléfono',
                    controller: _emergencyPhoneController,
                    icon: Icons.phone,
                    isEditing: _isEditing,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _isEditing
                      ? _buildRelationDropdown()
                      : CustomInputField(
                        label: 'Relación',
                        controller: TextEditingController(
                          text: _selectedRelacion ?? 'No especificado',
                        ),
                        icon: Icons.groups,
                        isEditing: false,
                      ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botones de acción
            _isEditing
                ? Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _updateUserData,
                        icon:
                            _isLoading
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.save),
                        label: Text(
                          _isLoading ? 'Guardando...' : 'Guardar Cambios',
                        ),
                        style: AppTheme.primaryButtonStyle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _cancelEdit,
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancelar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                )
                : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar Datos Personales'),
                    style: AppTheme.primaryButtonStyle,
                  ),
                ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRelacion,
      items:
          relaciones.map((relacion) {
            return DropdownMenuItem(value: relacion, child: Text(relacion));
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRelacion = value;
        });
      },
      decoration: AppTheme.inputDecoration(
        'Relación con el contacto',
        'Selecciona la relación',
        icon: Icons.groups,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecciona la relación';
        }
        return null;
      },
    );
  }
}
