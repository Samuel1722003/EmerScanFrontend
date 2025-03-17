import 'package:flutter/material.dart';
import 'package:hfe_frontend/models/menu_options.dart';
import 'package:hfe_frontend/screens/login.dart';
import 'package:hfe_frontend/screens/screen.dart';

class AppRoute {
  static const initialRoute = 'home';
  static final menuOptions = <MenuOptions>{
    MenuOptions(
      route: 'HomeScreen',
      title: 'HomeScreen',
      screen: const HomeScreen(),
      icon: Icons.home,
    ),
    MenuOptions(
      route: 'RegisterScreen',
      title: 'RegisterScreen',
      screen: const RegisterScreen(),
      icon: Icons.person_add,
    ),
    MenuOptions(
      route: 'LoginScreen',
      title: 'LoginScreen',
      screen: const LoginScreen(),
      icon: Icons.login,
    ),
    MenuOptions(
      route: 'PersonalDataScreen', // Nueva ruta para Datos personales
      title: 'Datos personales',
      screen: const PersonalDataScreen(),
      icon: Icons.person,
    ),
  };

  static Map<String, Widget Function(BuildContext)> getMenuRoutes() {
    Map<String, Widget Function(BuildContext)> appRoutes = {};
    appRoutes.addAll({'home': (BuildContext context) => const HomeScreen()});
    for (final options in menuOptions) {
      appRoutes.addAll({
        options.route: (BuildContext context) => options.screen,
      });
    }
    return appRoutes;
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const ErrorScreen());
  }
}
