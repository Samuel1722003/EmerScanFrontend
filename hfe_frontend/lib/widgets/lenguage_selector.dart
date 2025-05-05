import 'package:flutter/material.dart';
import 'package:hfe_frontend/themes/app_theme.dart';

// Para selección de idioma
class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String selectedLanguage = 'Español';
  final List<String> languages = ['Español', 'English', 'Français', 'Deutsch'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Idioma', style: AppTheme.cardTitle),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedLanguage,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => selectedLanguage = newValue);
              }
            },
            items:
                languages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
