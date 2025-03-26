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
      child: Column(
        children: [
          // Encabezado con imagen y nombre
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.lightBlue[50]),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.grey),
            ),
            accountName: Text(
              'Cristina',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            accountEmail: null,
          ),

          // Opciones de menú
          Expanded(
            child: Column(
              children: [
                // Opción Datos personales
                ListTile(
                  leading: Icon(Icons.person, color: Colors.blueGrey),
                  title: Text(
                    'Datos personales',
                    style: TextStyle(color: Colors.black87),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, 'PersonalDataScreen');
                  },
                ),

                // Opción Datos médicos
                ListTile(
                  leading: Icon(Icons.medical_services, color: Colors.blueGrey),
                  title: Text(
                    'Datos médicos',
                    style: TextStyle(color: Colors.black87),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, 'MedicalDataScreen');
                  },
                ),

                Divider(),

                ListTile(
                  leading: Icon(Icons.settings, color: Colors.grey[700]),
                  title: Text(
                    'Ajustes',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.grey[700]),
                  title: Text(
                    'Salir',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, 'LoginScreen');
                  },
                ),
              ],
            ),
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

  Widget _buildHomeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Function() onTap,
  }) {
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
            child: Icon(icon, size: 70, color: Colors.blueGrey),
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