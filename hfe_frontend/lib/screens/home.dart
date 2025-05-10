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
  String userId = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('user_id');
      final storedUserName = prefs.getString('user_name');

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      // Primero intentamos obtener datos desde Supabase Auth si está disponible
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
            userId = user.id;
            isLoading = false;
          });
        }
      }
      // Si no hay usuario autenticado con Auth, usamos SharedPreferences
      else if (storedUserId != null && storedUserName != null) {
        if (mounted) {
          setState(() {
            userName = storedUserName;
            userId = storedUserId;
            isLoading = false;
          });
        }
      }
      // Si no hay datos en SharedPreferences, usamos un valor por defecto
      else {
        if (mounted) {
          setState(() {
            userName = 'Usuario';
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Hola, $userName!',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 23),
            ),
          ],
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, 'NotificationsScreen');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, 'SettingsScreen');
            },
          ),
        ],
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 55,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),

          // Opciones de menú
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                // Opción Datos personales
                _buildDrawerItem(
                  icon: Icons.person,
                  title: 'Datos personales',
                  color: AppTheme.primary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'PersonalDataScreen');
                  },
                ),

                // Opción Datos médicos
                _buildDrawerItem(
                  icon: Icons.medical_services,
                  title: 'Datos médicos',
                  color: AppTheme.secondary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'MedicalDataScreen');
                  },
                ),

                const Divider(height: 30, thickness: 1),

                // Opción Código QR
                _buildDrawerItem(
                  icon: Icons.qr_code,
                  title: 'Código QR',
                  color: AppTheme.accent,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'QRCodeScreen');
                  },
                ),

                const Divider(height: 30, thickness: 1),

                // Opción Ajustes
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Ajustes',
                  color: AppTheme.textSecondary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'SettingsScreen');
                  },
                ),

                // Opción Salir
                _buildDrawerItem(
                  icon: Icons.exit_to_app,
                  title: 'Salir',
                  color: Colors.redAccent,
                  onTap: () async {
                    // Cerrar sesión
                    final supabase = Supabase.instance.client;
                    await supabase.auth.signOut();

                    // Limpiar preferencias
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('user_id');
                    await prefs.remove('user_name');
                    await prefs.remove('user_email');

                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, 'LoginScreen');
                  },
                ),
              ],
            ),
          ),

          // Versión al final del drawer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                const Divider(thickness: 0.5),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método auxiliar para construir items del drawer
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.textSecondary,
          size: 16,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: Colors.transparent,
        hoverColor: color.withOpacity(0.05),
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 4),
              blurRadius: 15,
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTheme.cardTitle.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: AppTheme.cardContent.copyWith(fontSize: 12, height: 1.3),
            ),
            const Spacer(),
            // Botón de "Ver más" con flecha
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Ver más",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, color: color, size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
