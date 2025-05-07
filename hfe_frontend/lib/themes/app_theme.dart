import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores principal
  static const Color primary = Color.fromARGB(
    255,
    63,
    157,
    181,
  ); // Color principal
  static const Color secondary = Color(0xFF2196F3); // Azul secundario
  static const Color accent = Color(0xFFE91E63); // Rosa acento
  static const Color background = Color(0xFFF5F7FA); // Fondo claro
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF212121); // Texto oscuro
  static const Color textSecondary = Color(0xFF757575); // Texto secundario

  // Colores para categorías médicas (más armoniosos)
  static const Color bloodType = Color(0xFFE57373); // Rojo suave
  static const Color allergies = Color(0xFFFFB74D); // Naranja suave
  static const Color diseases = Color(0xFF9575CD); // Púrpura suave
  static const Color measures = Color(0xFF4FC3F7); // Azul claro
  static const Color surgeries = Color(0xFF7986CB); // Indigo suave
  static const Color hospitalizations = Color(0xFF4DB6AC); // Verde azulado
  static const Color familyHistory = Color(0xFF81C784); // Verde suave
  static const Color treatments = Color(0xFFA1887F); // Marrón suave

  // Estilos de texto
  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle cardContent = TextStyle(
    fontSize: 14,
    color: textSecondary,
    height: 1.4,
  );

  // Decoraciones para widgets
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        offset: const Offset(0, 4),
        blurRadius: 10,
      ),
    ],
  );

  static InputDecoration inputDecoration(
    String label,
    String hint, {
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: primary) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade600),
    );
  }

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
  );
}
