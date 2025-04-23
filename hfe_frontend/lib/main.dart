import 'package:flutter/material.dart';
import 'package:hfe_frontend/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://dmvgtocktnzamzaqvybr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRtdmd0b2NrdG56YW16YXF2eWJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwMzU5ODMsImV4cCI6MjA1OTYxMTk4M30.D2CRrHdpdtprSRBbrCsaP26wDt5z1NS5GsjRkt1UxqE',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HFE Frontend',
      initialRoute:
          AppRoute.initialRoute, // ← La ruta inicial, la cual es 'home'
      routes: AppRoute.getMenuRoutes(), // ← Aquí van todas las rutas del menú
      onGenerateRoute:
          AppRoute.onGenerateRoute, // ← Si se va por una ruta que no existe
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
