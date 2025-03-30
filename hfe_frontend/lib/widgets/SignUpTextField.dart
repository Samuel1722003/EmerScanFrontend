import 'package:flutter/material.dart';

class SignUpTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final bool isDate;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const SignUpTextField({
    super.key,
    required this.label,
    this.hint,
    this.isDate = false,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        suffixIcon: isDate ? const Icon(Icons.calendar_today) : null,
      ),
      readOnly: isDate,
      onTap: isDate
          ? () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null && controller != null) {
                controller!.text =
                    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
              }
            }
          : null,
      validator: validator,
    );
  }
}