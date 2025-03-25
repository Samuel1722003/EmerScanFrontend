import 'package:flutter/material.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  // Controladores de texto para los campos
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

  // Valor seleccionado para el género
  String _selectedGender = "Femenino";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),

            // Título
            Text(
              'Datos personales',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            // Línea divisoria
            SizedBox(height: 10),
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.grey[400],
            ),

            SizedBox(height: 20),

            // Campo Nombres
            _buildTextField('Nombres', _firstNameController),

            SizedBox(height: 15),

            // Campo Apellidos
            _buildTextField('Apellidos', _lastNameController),

            SizedBox(height: 15),

            // Campo Fecha de nacimiento
            _buildTextField('Fecha de nacimiento', _birthDateController),

            SizedBox(height: 15),

            // Selector de Género
            _buildDropdownGender(),

            SizedBox(height: 15),

            // Nombre del contacto de emergencia
            _buildTextField(
              'Nombre contacto de emergencia',
              _emergencyNameController,
            ),

            SizedBox(height: 15),

            // Número de contacto de emergencia
            _buildTextField(
              'Número contacto de emergencia',
              _emergencyPhoneController,
            ),

            SizedBox(height: 30),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Acción de guardar los datos
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Datos guardados correctamente')),
                  );
                },
                icon: Icon(Icons.check),
                label: Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Color verde como en la imagen
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir un campo de texto
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        fillColor: Colors.grey[100],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
    );
  }

  // Widget para el Dropdown de género
  Widget _buildDropdownGender() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          items:
              ['Femenino', 'Masculino', 'Otro'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedGender = newValue!;
            });
          },
        ),
      ),
    );
  }
}
