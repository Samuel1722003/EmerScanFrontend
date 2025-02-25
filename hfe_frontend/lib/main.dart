import 'package:flutter/material.dart';
import 'package:hfe_frontend/routes/app_routes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HF',
      // INICIALIZAMOS LAS RUTAS CON LA GOBLALIZACION DE SI MISMAS
      initialRoute: AppRoute.inicialRoute,
      routes: AppRoute.getMenuRoutes(),
      onGenerateRoute: AppRoute.onGenerateRoute,
    );
  }
}
