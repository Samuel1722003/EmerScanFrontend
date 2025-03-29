import 'package:flutter/material.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String selectedLanguage = "Español";

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Idioma:"),
      trailing: DropdownButton<String>(
        value: selectedLanguage,
        items: <String>['Español', 'Inglés', 'Francés']
            .map((String lang) => DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedLanguage = value!;
          });
        },
      ),
    );
  }
}