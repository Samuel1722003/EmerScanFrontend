import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hfe_frontend/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Cargar las variables de entorno antes de inicializar Supabase
  await dotenv.load();
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EmerScan',
      initialRoute: AppRoute.initialRoute,
      routes: AppRoute.getMenuRoutes(),
      onGenerateRoute: AppRoute.onGenerateRoute,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}