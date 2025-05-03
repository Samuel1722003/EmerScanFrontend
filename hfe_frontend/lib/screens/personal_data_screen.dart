import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hfe_frontend/screens/home.dart';

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
  String? _userId; // <-- Aquí guardamos el ID del usuario

  // Valores para el Dropdown de relación
  final List<String> relaciones = [
    'Padre',
    'Madre',
    'Pareja',
    'Hermano',
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

    // Consulta de datos personales
    final userResponse =
        await supabase
            .from('usuario_persona')
            .select()
            .eq('id', _userId!)
            .maybeSingle();

    // Consulta de contacto de emergencia
    final contactoResponse =
        await supabase
            .from('contacto_emergencia')
            .select()
            .eq('usuario_persona_id', _userId!)
            .maybeSingle();

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

    setState(() {});
  }

  Future<void> _updateUserData() async {
    if (_userId == null) return;

    if (!_validateDate(_birthDateController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fecha de nacimiento no válida (formato: AAAA-MM-DD).'),
        ),
      );
      return;
    }

    if (!_validatePhoneNumber(_emergencyPhoneController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número de teléfono no válido.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    String apellidoPaterno = '';
    String apellidoMaterno = '';
    final apellidos = _lastNameController.text.trim().split(' ');
    if (apellidos.isNotEmpty) apellidoPaterno = apellidos[0];
    if (apellidos.length > 1) apellidoMaterno = apellidos.sublist(1).join(' ');

    final response = await supabase
        .from('usuario_persona')
        .update({
          'nombre': _firstNameController.text.trim(),
          'apellido_paterno': apellidoPaterno,
          'apellido_materno': apellidoMaterno,
          'fecha_nacimiento': _birthDateController.text.trim(),
          'genero': _selectedGender,
        })
        .eq('id', _userId!);

    // Verifica si ya hay un contacto de emergencia para este usuario
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
        'relacion':
            _selectedRelacion ??
            'Padre', // Por defecto 'padre' si no hay selección
      });
    }

    // Primero recargar los datos
    await _loadUserData();

    if (!mounted) return;

    // Ahora cambiamos el estado de edición y carga
    setState(() {
      _isEditing = false;
      _isLoading = false;
    });

    // Mostrar mensaje
    if (response.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: ${response.error!.message}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos actualizados correctamente.')),
      );
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: true, // Esto controla el botón de retroceso
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Regresar a HomeScreen cuando se presione el ícono de regreso
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Datos personales',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.grey[400]),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Nombres',
              controller: _firstNameController,
              isEditable: _isEditing,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: 'Apellidos',
              controller: _lastNameController,
              isEditable: _isEditing,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: 'Fecha de nacimiento',
              controller: _birthDateController,
              isEditable: _isEditing,
            ),
            const SizedBox(height: 15),
            _isEditing
                ? GenderDropdownWidget(
                  selectedGender: _selectedGender,
                  onChanged: (newValue) {
                    if (_isEditing) {
                      setState(() {
                        _selectedGender = newValue!;
                      });
                    }
                  },
                  isEditable: _isEditing,
                )
                : CustomTextField(
                  label: 'Género',
                  controller: TextEditingController(text: _selectedGender),
                  isEditable: false,
                ),
            const SizedBox(height: 15),
            CustomTextField(
              label: 'Nombre contacto de emergencia',
              controller: _emergencyNameController,
              isEditable: _isEditing,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: 'Número contacto de emergencia',
              controller: _emergencyPhoneController,
              isEditable: _isEditing,
            ),
            const SizedBox(height: 15),
            _isEditing
                ? DropdownButtonFormField<String>(
                  value: _selectedRelacion,
                  items:
                      relaciones.map((relacion) {
                        return DropdownMenuItem(
                          value: relacion,
                          child: Text(relacion),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRelacion = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Relación con el contacto',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona la relación';
                    }
                    return null;
                  },
                )
                : CustomTextField(
                  label: 'Relación',
                  controller: TextEditingController(text: _selectedRelacion),
                  isEditable: false,
                ),
            const SizedBox(height: 30),
            _isEditing
                ? Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isLoading
                                ? null
                                : () async {
                                  await _updateUserData();
                                },
                        icon:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.check, color: Colors.white),
                        label: Text(
                          _isLoading ? 'Guardando...' : 'Guardar',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _cancelEdit();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
                : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Editar datos personales',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
