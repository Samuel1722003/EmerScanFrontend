import 'package:flutter/material.dart';
import 'package:hfe_frontend/models/menu_options.dart';
import 'package:hfe_frontend/screens/login_screen.dart';
import 'package:hfe_frontend/screens/screen.dart';

class AppRoute {
  static const initialRoute = 'home';

  static final List<MenuOptions> menuOptions = [
    MenuOptions(
      route: 'HomeScreen',
      title: 'Inicio',
      screen: const HomeScreen(),
      icon: Icons.home,
    ),
    MenuOptions(
      route: 'RegisterScreen',
      title: 'Registro',
      screen: const SignUpScreen1(),
      icon: Icons.person_add,
    ),
    MenuOptions(
      route: 'LoginScreen',
      title: 'Iniciar Sesión',
      screen: const LoginScreen(),
      icon: Icons.login,
    ),
    MenuOptions(
      route: 'PersonalDataScreen',
      title: 'Datos Personales',
      screen: const PersonalDataScreen(),
      icon: Icons.person,
    ),
    MenuOptions(
      route: 'MedicalDataScreen',
      title: 'Datos Médicos',
      screen: const ScreenMedicalData(),
      icon: Icons.local_hospital,
    ),
    MenuOptions(
      route: 'SettingsScreen',
      title: 'Ajustes',
      screen: const SettingsScreen(),
      icon: Icons.settings,
    ),
  ];

  static Map<String, Widget Function(BuildContext)> getMenuRoutes() {
    Map<String, Widget Function(BuildContext)> appRoutes = {};
    appRoutes.addAll({'home': (BuildContext context) => const HomeScreen()});
    for (final options in menuOptions) {
      appRoutes[options.route] = (BuildContext context) => options.screen;
    }
    return appRoutes;
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const ErrorScreen());
  }
}