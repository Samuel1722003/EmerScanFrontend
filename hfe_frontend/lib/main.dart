import 'package:flutter/material.dart';
import 'package:hfe_frontend/routes/app_routes.dart'; // ← Asegúrate de importar tu AppRoute

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HFE Frontend',
      initialRoute: AppRoute.initialRoute,// ← La ruta inicial, por ejemplo 'home'
      routes: AppRoute.getMenuRoutes(),    // ← Aquí van todas las rutas del menú
      onGenerateRoute: AppRoute.onGenerateRoute, // ← Si se va por una ruta que no existe
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}