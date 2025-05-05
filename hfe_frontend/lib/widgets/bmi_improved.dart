import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/screen.dart';

// Indicador de IMC para pantalla de datos médicos
class BMIIndicator extends StatelessWidget {
  final double bmi;

  const BMIIndicator({super.key, required this.bmi});

  String _getBmiCategory() {
    if (bmi < 18.5) return 'Bajo peso';
    if (bmi < 25) return 'Peso normal';
    if (bmi < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  Color _getBmiColor() {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final category = _getBmiCategory();
    final color = _getBmiColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_weight_outlined, color: color),
              const SizedBox(width: 8),
              Text('Índice de Masa Corporal (IMC)', style: AppTheme.cardTitle),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu IMC es ${bmi.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    bmi.toStringAsFixed(1),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: bmi / 40,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bajo',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              Text(
                'Normal',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              Text(
                'Sobrepeso',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              Text(
                'Obesidad',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
