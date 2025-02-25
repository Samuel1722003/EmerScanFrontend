import 'package:flutter/material.dart';

class MenuOptions {
  final String route;
  final IconData icon;
  final String title;
  final Widget screen;

  MenuOptions({
    required this.route,
    required this.icon,
    required this.title,
    required this.screen,
  });
}
