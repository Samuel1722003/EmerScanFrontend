import 'package:flutter/material.dart';
import 'package:hfe_frontend/widgets/MenuButton.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        // Tu menú aquí si lo necesitas
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            
            // Texto de bienvenida
            Text(
              '¡Hola, Cristina!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            // Línea divisoria gris debajo del título
            SizedBox(height: 10),
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.grey[400],
            ),

            SizedBox(height: 40),

            // Primer botón: Datos personales
            MenuButton(
              icon: Icons.person,
              text: 'Datos personales',
              onTap: () {
                // Acción del botón
              },
            ),

            SizedBox(height: 30),

            // Segundo botón: Datos médicos
            MenuButton(
              icon: Icons.medical_services,
              text: 'Datos médicos',
              onTap: () {
                // Acción del botón
              },
            ),
          ],
        ),
      ),
    );
  }
}