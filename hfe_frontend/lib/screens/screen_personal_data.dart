import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final TextEditingController _firstNameController = TextEditingController(
    text: "Cristina Fernanda",
  );
  final TextEditingController _lastNameController = TextEditingController(
    text: "Contreras Soliz",
  );
  final TextEditingController _birthDateController = TextEditingController(
    text: "27-Julio-2003",
  );
  final TextEditingController _emergencyNameController = TextEditingController(
    text: "Cristina Soliz",
  );
  final TextEditingController _emergencyPhoneController = TextEditingController(
    text: "6677557004",
  );

  String _selectedGender = "Femenino";
  bool _isEditing = false;

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
                    });
                  },
                  child: const Text('Cancelar', selectionColor: Colors.white,),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
