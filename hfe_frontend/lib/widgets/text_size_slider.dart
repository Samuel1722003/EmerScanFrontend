import 'package:flutter/material.dart';

class TextSizeSlider extends StatefulWidget {
  const TextSizeSlider({super.key});

  @override
  _TextSizeSliderState createState() => _TextSizeSliderState();
}

class _TextSizeSliderState extends State<TextSizeSlider> {
  double textSize = 16;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Texto:"),
        Row(
          children: [
            const Text("Aa"),
            Expanded(
              child: Slider(
                value: textSize,
                min: 12,
                max: 24,
                onChanged: (value) {
                  setState(() {
                    textSize = value;
                  });
                },
              ),
            ),
            Text(
              "Aa",
              style: TextStyle(fontSize: textSize),
            ),
          ],
        ),
      ],
    );
  }
}