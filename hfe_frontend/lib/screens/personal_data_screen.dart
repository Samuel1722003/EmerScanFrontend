import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String _selectedGender = "";
  bool _isEditing = false;
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserIdAndFetchData();
  }

  Future<void> loadUserIdAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');

    if (id != null) {
      setState(() {
        userId = id;
      });
      await fetchUserData();
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

  Future<void> fetchUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener datos personales del usuario
      final usuario = await supabase
          .from('usuario_persona')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (usuario == null) {
        throw Exception('Usuario no encontrado');
      }

      // Obtener contacto de emergencia
      final contactoEmergencia = await supabase
          .from('contacto_emergencia')
          .select()
          .eq('usuario_persona_id', userId)
          .maybeSingle();

      // Actualizar controladores con datos reales
      _firstNameController.text = usuario['nombre'] ?? '';
      _lastNameController.text = '${usuario['apellido_paterno'] ?? ''} ${usuario['apellido_materno'] ?? ''}';
      
      // Formatear fecha de nacimiento
      final fechaNacimiento = usuario['fecha_nacimiento'] != null 
          ? DateTime.parse(usuario['fecha_nacimiento'])
          : null;
      _birthDateController.text = fechaNacimiento != null
          ? '${fechaNacimiento.day}-${_getMonthName(fechaNacimiento.month)}-${fechaNacimiento.year}'
          : '';

      _selectedGender = usuario['genero'] ?? '';
      
      _emergencyNameController.text = contactoEmergencia?['nombre'] ?? '';
      _emergencyPhoneController.text = contactoEmergencia?['telefono'] ?? '';

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos personales: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
          ),
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      onPressed: () {
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
                            // Recargar datos originales
                            fetchUserData();
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
                        child: const Text('Cancelar', selectionColor: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}