import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hfe_frontend/screens/screen.dart';

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
      // ignore: avoid_print
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          '¡Hola, $userName!',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primary,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Cargando información...",
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
              : _buildBody(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Encabezado con imagen y nombre
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            width: double.infinity,
            color: AppTheme.primary,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
          ),

          // Opciones de menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Opción Datos personales
                ListTile(
                  leading: const Icon(Icons.person, color: AppTheme.primary),
                  title: const Text(
                    'Datos personales',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'PersonalDataScreen');
                  },
                ),

                // Opción Datos médicos
                ListTile(
                  leading: const Icon(
                    Icons.medical_services,
                    color: AppTheme.secondary,
                  ),
                  title: const Text(
                    'Datos médicos',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'MedicalDataScreen');
                  },
                ),

                const Divider(),

                // Opción Código QR
                ListTile(
                  leading: const Icon(Icons.qr_code, color: AppTheme.accent),
                  title: const Text(
                    'Código QR',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'QRCodeScreen');
                  },
                ),

                const Divider(),

                // Opción Ajustes
                ListTile(
                  leading: Icon(Icons.settings, color: AppTheme.textSecondary),
                  title: Text(
                    'Ajustes',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'SettingsScreen');
                  },
                ),

                // Opción Salir
                ListTile(
                  leading: const Icon(
                    Icons.exit_to_app,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Salir',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.redAccent,
                    ),
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

          // Versión al final del drawer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'v1.0.0',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Encabezado con saludo
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bienvenido/a de nuevo", style: AppTheme.heading),
                Text(
                  "¿Qué te gustaría hacer hoy?",
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                ),
              ],
            ),
          ),
        ),

        // Tarjetas de acceso rápido (sin la tarjeta de Citas)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.9,
            children: [
              _buildFeatureCard(
                context: context,
                icon: Icons.person,
                title: "Datos personales",
                description: "Gestiona tu información de contacto y personal",
                color: AppTheme.primary,
                route: 'PersonalDataScreen',
              ),
              _buildFeatureCard(
                context: context,
                icon: Icons.medical_services_outlined,
                title: "Datos médicos",
                description: "Consulta y actualiza tu historial médico",
                color: AppTheme.diseases,
                route: 'MedicalDataScreen',
              ),
              _buildFeatureCard(
                context: context,
                icon: Icons.qr_code,
                title: "Mi Código QR",
                description: "Accede rápido a tu información",
                color: AppTheme.accent,
                route: 'QRCodeScreen',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTheme.cardTitle),
            const SizedBox(height: 8),
            Text(description, style: AppTheme.cardContent),
          ],
        ),
      ),
    );
  }
}
