import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/widgets.dart';

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
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Dos columnas
                  crossAxisSpacing: 16.0, // Espacio entre columnas
                  mainAxisSpacing: 16.0, // Espacio entre filas
                ),
                itemCount: 7, // Número total de elementos
                itemBuilder: (context, index) {
                  // Creación de los MedicalCard según el índice
                  List<Widget> medicalCards = const [
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
                  ];

                  return medicalCards[index];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}