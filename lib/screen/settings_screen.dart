import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // 👇 El flujo vuelve automáticamente a LoginScreen por main.dart
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text(
          "Configuraciones",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Perfil"),
            subtitle: const Text("Editar datos personales"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notificaciones"),
            subtitle: const Text("Configurar recordatorios"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text("Tema"),
            subtitle: const Text("Oscuro / Claro"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("Acerca de"),
            subtitle: const Text("Versión 1.0.0"),
            onTap: () {},
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Cerrar sesión"),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}


