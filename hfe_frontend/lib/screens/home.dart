import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        final userData =
            await supabase
                .from('usuario_persona')
                .select('nombre, apellido_paterno')
                .eq('id', user.id)
                .single();

        if (mounted) {
          setState(() {
            userName =
                '${userData['nombre'] ?? ''} ${userData['apellido_paterno'] ?? ''}';
            isLoading = false;
          });
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        final storedUserName = prefs.getString('user_name');
        if (mounted) {
          setState(() {
            userName = storedUserName ?? 'Usuario';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
      if (mounted) {
        setState(() {
          userName = 'Usuario';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('¡Hola, $userName!'),
        backgroundColor: Colors.lightBlue[50],
      ),
      drawer: _buildDrawer(context),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Encabezado con imagen y nombre
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.lightBlue[50]),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.grey),
            ),
            accountName: Text(
              userName,
              style: const TextStyle(
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
                  leading: const Icon(Icons.person, color: Colors.blueGrey),
                  title: const Text(
                    'Datos personales',
                    style: TextStyle(color: Colors.black87),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, 'PersonalDataScreen');
                  },
                ),

                // Opción Datos médicos
                ListTile(
                  leading: const Icon(
                    Icons.medical_services,
                    color: Colors.blueGrey,
                  ),
                  title: const Text(
                    'Datos médicos',
                    style: TextStyle(color: Colors.black87),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, 'MedicalDataScreen');
                  },
                ),

                const Divider(),

                // Opción Código QR
                ListTile(
                  leading: const Icon(Icons.qr_code, color: Colors.blueGrey),
                  title: const Text(
                    'Codigo QR',
                    style: TextStyle(color: Colors.black87),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, 'QRCodeScreen');
                  },
                ),

                const Divider(),

                // Opción Ajustes
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.grey[700]),
                  title: Text(
                    'Ajustes',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, 'SettingsScreen');
                  },
                ),

                // Opción Salir
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.grey[700]),
                  title: Text(
                    'Salir',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  onTap: () async {
                    // Cerrar sesión
                    final supabase = Supabase.instance.client;
                    await supabase.auth.signOut();

                    // Limpiar preferencias
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('user_name');

                    if (!mounted) return;
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
          const SizedBox(height: 30),

          // Línea horizontal decorativa
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 50),
            height: 1,
            color: Colors.grey[400],
          ),

          const SizedBox(height: 30),

          // Botón Datos personales
          _buildHomeButton(
            context,
            icon: Icons.person,
            label: 'Datos personales',
            onTap: () {
              Navigator.pushNamed(context, 'PersonalDataScreen');
            },
          ),

          const SizedBox(height: 20),

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
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
