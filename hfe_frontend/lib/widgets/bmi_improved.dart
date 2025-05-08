import 'package:flutter/material.dart';

// Indicador de IMC para pantalla de datos médicos
class BMIIndicator extends StatelessWidget {
  final double bmi;

  const BMIIndicator({super.key, required this.bmi});

  Color _getBmiColor() {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBmiCategory() {
    if (bmi < 18.5) return "Bajo peso";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Sobrepeso";
    return "Obesidad";
  }

  String _getBmiDescription() {
    if (bmi < 18.5)
      return "Podría indicar desnutrición o un metabolismo muy acelerado";
    if (bmi < 25) return "Tu peso es adecuado para tu estatura";
    if (bmi < 30)
      return "Recomendable vigilar dieta y aumentar actividad física";
    return "Se recomienda consultar con un profesional de la salud";
  }

  double _getIndicatorPosition() {
    // Limita el BMI entre 15 y 35 para el indicador visual
    final limitedBmi = bmi.clamp(15.0, 35.0);
    // Convierte a un valor entre 0.0 y 1.0
    return (limitedBmi - 15) / 20;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_weight, color: _getBmiColor(), size: 24),
              const SizedBox(width: 12),
              const Text(
                "Índice de Masa Corporal (IMC)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getBmiColor().withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: _getBmiColor(), width: 2),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        bmi.toStringAsFixed(1),
                        style: TextStyle(
                          color: _getBmiColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        "kg/m²",
                        style: TextStyle(color: _getBmiColor(), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getBmiCategory(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: _getBmiColor(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getBmiDescription(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Escala visual mejorada
          Container(
            height: 60,
            width: double.infinity,
            child: Stack(
              children: [
                // Fondo de la escala
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue,
                        Colors.green,
                        Colors.orange,
                        Colors.red,
                      ],
                    ),
                  ),
                ),

                // Indicador de posición
                Positioned(
                  left:
                      _getIndicatorPosition() *
                      (MediaQuery.of(context).size.width - 80),
                  child: Container(
                    height: 60,
                    width: 20,
                    child: Column(
                      children: [
                        Icon(
                          Icons.arrow_drop_down,
                          color: _getBmiColor(),
                          size: 30,
                        ),
                        Container(width: 4, height: 20, color: _getBmiColor()),
                      ],
                    ),
                  ),
                ),

                // Etiquetas
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "15",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        "18.5",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        "25",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        "30",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        "35+",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Leyenda
          Wrap(
            spacing: 12,
            children: [
              _buildLegendItem("Bajo peso", Colors.blue),
              _buildLegendItem("Normal", Colors.green),
              _buildLegendItem("Sobrepeso", Colors.orange),
              _buildLegendItem("Obesidad", Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }
}
