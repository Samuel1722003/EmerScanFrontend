import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final TextEditingController _emergencyNameController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();

  String _selectedGender = "Femenino";
  bool _isEditing = false;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String getUserId() {
    return "01bec088-a454-45b2-8c59-b7b24ea2a111-20250424184650-048029";
  }

  Future<void> _loadUserData() async {
  // Consulta de datos personales
  final userResponse = await supabase
      .from('usuario_persona')
      .select()
      .eq('id', getUserId())
      .maybeSingle();

  // Consulta de contacto de emergencia
  final contactoResponse = await supabase
      .from('contacto_emergencia')
      .select()
      .eq('usuario_persona_id', getUserId())
      .maybeSingle();

  if (userResponse != null) {
    _firstNameController.text = userResponse['nombre'] ?? '';
    _lastNameController.text =
        "${userResponse['apellido_paterno'] ?? ''} ${userResponse['apellido_materno'] ?? ''}".trim();
    _birthDateController.text = userResponse['fecha_nacimiento'] ?? '';
    _selectedGender = userResponse['genero'] ?? 'Femenino';
  }

  if (contactoResponse != null) {
    _emergencyNameController.text = contactoResponse['nombre'] ?? '';
    _emergencyPhoneController.text = contactoResponse['telefono'] ?? '';
  }

  setState(() {});
}

  Future<void> _updateUserData() async {
  String apellidoPaterno = '';
  String apellidoMaterno = '';
  final apellidos = _lastNameController.text.trim().split(' ');
  if (apellidos.isNotEmpty) apellidoPaterno = apellidos[0];
  if (apellidos.length > 1) apellidoMaterno = apellidos.sublist(1).join(' ');

  final userId = getUserId();

  // Actualiza datos personales
  final response = await supabase.from('usuario_persona').update({
    'nombre': _firstNameController.text.trim(),
    'apellido_paterno': apellidoPaterno,
    'apellido_materno': apellidoMaterno,
    'fecha_nacimiento': _birthDateController.text.trim(),
    'genero': _selectedGender,
  }).eq('id', userId);

  // Verifica si ya hay un contacto de emergencia para este usuario
  final existingContact = await supabase
      .from('contacto_emergencia')
      .select('id')
      .eq('usuario_persona_id', userId)
      .maybeSingle();

  if (existingContact != null) {
    // Si existe, lo actualiza
    await supabase.from('contacto_emergencia').update({
      'nombre': _emergencyNameController.text.trim(),
      'telefono': _emergencyPhoneController.text.trim(),
    }).eq('id', existingContact['id']);
  } else {
    // Si no existe, lo inserta (puedes ajustar la relación según el campo "relacion")
    await supabase.from('contacto_emergencia').insert({
      'nombre': _emergencyNameController.text.trim(),
      'telefono': _emergencyPhoneController.text.trim(),
      'usuario_persona_id': userId,
      'relacion': 'Familiar', // Aquí puedes ajustar según tu tipo enum o clave foránea
    });
  }

  if (!mounted) return;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_isEditing) {
                      await _updateUserData();
                      await _loadUserData();
                  }
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
                icon: Icon(
                  _isEditing ? Icons.check : Icons.edit,
                  color: Colors.white,
                ),
                label: Text(
                  _isEditing ? 'Guardar' : 'Editar datos',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEditing ? Colors.teal : Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
