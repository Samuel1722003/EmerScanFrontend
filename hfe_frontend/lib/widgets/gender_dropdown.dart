import 'package:flutter/material.dart';

class GenderDropdownWidget extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String?> onChanged;
  final bool isEditable;

  const GenderDropdownWidget({
    super.key,
    required this.selectedGender,
    required this.onChanged,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child:
          isEditable
              ? DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedGender,
                  items:
                      ['Femenino', 'Masculino', 'Otro'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: onChanged,
                ),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  selectedGender,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
              ),
    );
  }
}
