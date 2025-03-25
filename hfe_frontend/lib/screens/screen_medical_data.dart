import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/screen.dart';

class ScreenMedicalData extends StatelessWidget {
  const ScreenMedicalData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos Médicos'),
        backgroundColor: Colors.lightBlue[50],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Información Médica del Paciente",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Contenedor para mostrar los cuadros de información
            Expanded(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: const [
                  MedicalCard(
                    title: "Grupo Sanguíneo",
                    content: "O+",
                    icon: Icons.bloodtype,
                    color: Colors.redAccent,
                  ),
                  MedicalCard(
                    title: "Alergias",
                    content: "Polen, Penicilina",
                    icon: Icons.warning,
                    color: Colors.orangeAccent,
                  ),
                  MedicalCard(
                    title: "Condiciones Médicas",
                    content: "Hipertensión, Diabetes tipo 2",
                    icon: Icons.health_and_safety,
                    color: Colors.blueAccent,
                  ),
                  MedicalCard(
                    title: "Medicamentos",
                    content: "Metformina, Losartán",
                    icon: Icons.medical_services,
                    color: Colors.green,
                  ),
                  MedicalCard(
                    title: "Peso",
                    content: "75 kg",
                    icon: Icons.monitor_weight,
                    color: Colors.pinkAccent,
                  ),
                  MedicalCard(
                    title: "Enfermedades",
                    content: "Asma, Insuficiencia Renal",
                    icon: Icons.sick,
                    color: Colors.deepPurpleAccent,
                  ),
                  MedicalCard(
                    title: "Cirugías",
                    content: "Apendicectomía en 2018",
                    icon: Icons.local_hospital,
                    color: Colors.indigo,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}