import 'package:flutter/material.dart';

class InputText extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final String title;
  const InputText({
    super.key,
    required this.title,
  });
  @override
  State<InputText> createState() => InputTextState();
}

class InputTextState extends State<InputText> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: widget.title,
      ),
    );
  }
}
