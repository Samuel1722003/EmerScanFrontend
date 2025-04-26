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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final response = await supabase.from('usuario_persona').select().limit(1).maybeSingle();

    if (response != null) {
      _firstNameController.text = response['nombre'] ?? '';
      _lastNameController.text =
          "${response['apellido_paterno'] ?? ''} ${response['apellido_materno'] ?? ''}".trim();
      _birthDateController.text = response['fecha_nacimiento'] ?? '';
      _selectedGender = response['genero'] ?? 'Femenino';
      //_emergencyNameController.text = response['nombre_contacto_emergencia'] ?? '';
      //_emergencyPhoneController.text = response['telefono_contacto_emergencia'] ?? '';
      setState(() {});
    }
  }

  Future<void> _updateUserData() async {
    String apellidoPaterno = '';
    String apellidoMaterno = '';
    final apellidos = _lastNameController.text.trim().split(' ');
    if (apellidos.isNotEmpty) apellidoPaterno = apellidos[0];
    if (apellidos.length > 1) apellidoMaterno = apellidos.sublist(1).join(' ');

    final response = await supabase.from('usuario_persona').update({
      'nombre': _firstNameController.text.trim(),
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
      'fecha_nacimiento': _birthDateController.text.trim(),
      'genero': _selectedGender,
      //'nombre_contacto_emergencia': _emergencyNameController.text.trim(),
      //'telefono_contacto_emergencia': _emergencyPhoneController.text.trim(),
    }).eq('id','01bec088-a454-45b2-8c59-b7b24ea2a111-20250424184650-048029'); // Ajusta aquí el ID o condición según tu tabla

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
