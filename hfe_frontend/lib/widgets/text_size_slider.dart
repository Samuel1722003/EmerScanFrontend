import 'package:flutter/material.dart';
import 'package:hfe_frontend/themes/app_theme.dart';

// Para ajustar el tamaño del texto
class TextSizeSlider extends StatefulWidget {
  const TextSizeSlider({super.key});

  @override
  State<TextSizeSlider> createState() => _TextSizeSliderState();
}

class _TextSizeSliderState extends State<TextSizeSlider> {
  double textSize = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tamaño del texto', style: AppTheme.cardTitle),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Slider(
                  value: textSize,
                  min: 0.8,
                  max: 1.3,
                  divisions: 5,
                  activeColor: AppTheme.primary,
                  inactiveColor: Colors.grey.shade300,
                  onChanged: (value) {
                    setState(() => textSize = value);
                  },
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 22)),
            ],
          ),
        ],
      ),
    );
  }
}
