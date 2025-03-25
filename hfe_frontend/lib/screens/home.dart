import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('¡Hola, Cristina!'),
        backgroundColor: Colors.lightBlue[50],
      ),
      drawer: _buildDrawer(context), // Menú lateral
      body: _buildBody(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header del Drawer
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.lightBlue[50],
            ),
            child: Text(
              'Menú',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 24,
              ),
            ),
          ),

          // Opción Datos personales
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Datos personales'),
            onTap: () {
              Navigator.pushNamed(context, 'PersonalDataScreen');
            },
          ),

          // Opción Datos médicos
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('Datos médicos'),
            onTap: () {
              Navigator.pushNamed(context, 'MedicalDataScreen');
            },
          ),

          Divider(),

          // Cerrar sesión
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar sesión'),
            onTap: () {
              Navigator.pushReplacementNamed(context, 'LoginScreen');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 30),

          // Línea horizontal decorativa
          Container(
            margin: EdgeInsets.symmetric(horizontal: 50),
            height: 1,
            color: Colors.grey[400],
          ),

          SizedBox(height: 30),

          // Botón Datos personales
          _buildHomeButton(
            context,
            icon: Icons.person,
            label: 'Datos personales',
            onTap: () {
              Navigator.pushNamed(context, 'PersonalDataScreen');
            },
          ),

          SizedBox(height: 20),

          // Botón Datos médicos
          _buildHomeButton(
            context,
            icon: Icons.medical_services,
            label: 'Datos médicos',
            onTap: () {
              Navigator.pushNamed(context, 'MedicalDataScreen');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context, {required IconData icon, required String label, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 70,
              color: Colors.blueGrey,
            ),
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}