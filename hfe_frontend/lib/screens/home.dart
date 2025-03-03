import 'package:flutter/material.dart';
import 'package:hfe_frontend/routes/app_routes.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //Inicio del menu
      appBar: AppBar(title: Text(" ")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menú de Navegación',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ...AppRoute.menuOptions.map((option) => ListTile(
                  leading: Icon(option.icon),
                  title: Text(option.title),
                  onTap: () {
                    Navigator.pushNamed(context, option.route);
                  },
                )),
          ],
        ),
      ),

      //Final del Menu

      body: Center(
        child: Column(
          children: [
            SizedBox(height: 50),
            TextField(
              obscureText: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nombre(s)',
              ),
            ),
            TextField(
              obscureText: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Apellido(s)',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () {}, child: Text("Holiwis")),
            ElevatedButton(onPressed: () {}, child: Text("Serapio")),
            ElevatedButton(onPressed: () {}, child: Text("pachulin")),
            ElevatedButton(onPressed: () {}, child: Text("Belemchin")),
            ElevatedButton(onPressed: () {}, child: Text("Emiliachin")),
            
          ],
        ),
      ),
    );
  }
}
