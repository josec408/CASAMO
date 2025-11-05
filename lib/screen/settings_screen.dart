import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart'; // 🔹 Instancia global de notificaciones

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

  Future<void> _mostrarNotificacionPrueba() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'prueba_channel', // ID del canal
      'Prueba Notificación', // Nombre visible
      channelDescription: 'Notificación de prueba',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails generalDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      '¡Hola!',
      'Esta es una notificación de prueba',
      generalDetails,
    );
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

          // 🔹 Botón de prueba de notificación
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.notifications_active),
              label: const Text("Probar notificación"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E24AA),
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: _mostrarNotificacionPrueba,
            ),
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


