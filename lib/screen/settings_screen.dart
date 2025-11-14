import 'package:casamo/screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  Future<void> _logout() async {
    try {
      // 1️⃣ Borrar datos locales (SharedPreferences, etc.)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 2️⃣ Cerrar sesión de Firebase
      await FirebaseAuth.instance.signOut();

      // 3️⃣ Volver al login y limpiar rutas
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }

      // 4️⃣ Confirmación visual
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión cerrada correctamente 👋')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notificaciones"),
            subtitle: const Text("Configurar recordatorios"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Notificaciones"),
                  content: const Text("Próximamente podrás configurar tus recordatorios aquí."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cerrar"),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text("Tema"),
            subtitle: const Text("Oscuro / Claro"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  bool isDark = Theme.of(context).brightness == Brightness.dark;
                  return AlertDialog(
                    title: const Text("Seleccionar tema"),
                    content: SwitchListTile(
                      title: const Text("Modo oscuro"),
                      value: isDark,
                      onChanged: (value) {
                        // 🔧 Aquí luego puedes usar Provider para cambiar el tema global
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cerrar"),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("Acerca de"),
            subtitle: const Text("Versión 1.0.0"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "CASAMO",
                applicationVersion: "1.0.0",
                applicationIcon: const Icon(Icons.school, color: Colors.deepPurple),
                children: [
                  const Text("Aplicación Pomodoro para estudiantes desarrollada con Flutter."),
                  const SizedBox(height: 8),
                  const Text("Desarrollador: José Caycho"),
                ],
              );
            },
          ),
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


