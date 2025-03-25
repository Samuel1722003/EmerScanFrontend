import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/screen.dart';

class ScreenMedicalData extends StatelessWidget {
  const ScreenMedicalData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightBlue),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Inicio'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Datos médicos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
              height: 20,
              indent: 50,
              endIndent: 50,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2,
                children: const [
                  MedicalCard(
                    color: Colors.pinkAccent,
                    icon: Icons.bloodtype,
                    title: 'ORH+',
                  ),
                  MedicalCard(
                    color: Colors.amber,
                    icon: Icons.monitor_weight,
                    title: '60 kg',
                  ),
                  MedicalCard(
                    color: Colors.purpleAccent,
                    icon: Icons.speaker,
                    title: 'Alergias',
                  ),
                  MedicalCard(
                    color: Colors.tealAccent,
                    icon: Icons.local_hospital,
                    title: 'Enfermedades',
                  ),
                  MedicalCard(
                    color: Colors.pink,
                    icon: Icons.healing,
                    title: 'Cirugías',
                  ),
                  MedicalCard(
                    color: Colors.orangeAccent,
                    icon: Icons.medical_services,
                    title: 'Medicación',
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