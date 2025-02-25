import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
            ElevatedButton(onPressed: () {}, child: Text("Holiwis")),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () {}, child: Text("Holiwis")),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () {}, child: Text("Holiwis")),
          ],
        ),
      ),
    );
  }
}
