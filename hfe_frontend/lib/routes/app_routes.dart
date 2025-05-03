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
      route: 'LoginScreen',
      title: 'Iniciar Sesión',
      screen: const LoginScreen(),
      icon: Icons.login,
    ),
    MenuOptions(
      route: 'RegisterScreen',
      title: 'Registro',
      screen: const SignUpScreen1(),
      icon: Icons.person_add,
    ),
    MenuOptions(
      route: 'RegisterScreen2',
      title: 'Registro2',
      screen: const SignUpScreen2(),
      icon: Icons.person_add,
    ),
    MenuOptions(
      route: 'RegisterScreen3',
      title: 'Registro3',
      screen: const SignUpScreen3(),
      icon: Icons.person_add,
    ),
    MenuOptions(
      route: 'RegisterScreen4',
      title: 'Registro4',
      screen: const SignUpScreen4(),
      icon: Icons.person_add,
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
      screen: const MedicalDataScreen(),
      icon: Icons.local_hospital,
    ),
    MenuOptions(
      route: 'QRCodeScreen',
      title: 'Codigo QR',
      screen: const QRCodeScreen(),
      icon: Icons.qr_code,
    ),
    MenuOptions(
      route: 'SettingsScreen',
      title: 'Ajustes',
      screen: const SettingsScreen(),
      icon: Icons.settings,
    ),
    MenuOptions(
      route: 'PersonalizationScreen',
      title: 'Personalizacion',
      screen: const PersonalizationScreen(),
      icon: Icons.settings,
    ),
    MenuOptions(
      route: 'NotificationsScreen',
      title: 'Notificaciones',
      screen: const NotificationsScreen(),
      icon: Icons.settings,
    ),
    MenuOptions(
      route: 'SecurityScreen',
      title: 'Seguridad',
      screen: const SecurityScreen(),
      icon: Icons.settings,
    ),
    MenuOptions(
      route: 'SupportScreen',
      title: 'Soporte',
      screen: const SupportScreen(),
      icon: Icons.settings,
    ),
    MenuOptions(
      route: 'ErrorScreen',
      title: 'Error',
      screen: const ErrorScreen(),
      icon: Icons.error,
    ),
  ];

  static Map<String, Widget Function(BuildContext)> getMenuRoutes() {
    Map<String, Widget Function(BuildContext)> appRoutes = {};
    appRoutes.addAll({'home': (BuildContext context) => const LoginScreen()});
    for (final options in menuOptions) {
      appRoutes[options.route] = (BuildContext context) => options.screen;
    }
    return appRoutes;
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const ErrorScreen());
  }
}