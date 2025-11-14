import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}



class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  final firestore = FirebaseFirestore.instance;

  

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? "";
  }

  Future<void> _saveChanges() async {
    try {
      await user?.updateDisplayName(_nameController.text);
      await user?.reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  // ☁️ Subir copia de seguridad
  Future<void> subirBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Ejemplo: datos locales que podrías tener
      final nombre = _nameController.text;
      final tarea = prefs.getString('tarea') ?? '';
      final duracion = prefs.getInt('duracion') ?? 0;

      await firestore
          .collection('usuarios')
          .doc(user!.uid)
          .collection('backup')
          .doc('ultimo')
          .set({
        'fecha': FieldValue.serverTimestamp(),
        'datos': {
          'nombre': nombre,
          'tarea': tarea,
          'duracion': duracion,
        },
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copia de seguridad subida ☁️')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir copia: $e')),
      );
    }
  }

  // 🔄 Restaurar copia de seguridad
  Future<void> restaurarBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final doc = await firestore
          .collection('usuarios')
          .doc(user!.uid)
          .collection('backup')
          .doc('ultimo')
          .get();

      if (doc.exists) {
        final data = doc['datos'];

        // Restaurar a SharedPreferences
        await prefs.setString('tarea', data['tarea']);
        await prefs.setInt('duracion', data['duracion']);

        // Restaurar nombre del usuario
        await user?.updateDisplayName(data['nombre']);
        _nameController.text = data['nombre'];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copia restaurada correctamente 🔄')),
        );

        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay copia disponible 😕')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar copia: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : const AssetImage('assets/profile_placeholder.png')
                        as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                user?.email ?? "Correo no disponible",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Nombre",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "Escribe tu nombre",
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text("Guardar cambios"),
              ),
            ),
            const Divider(height: 40),
            const Text(
              "Copia de seguridad",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: subirBackup,
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Subir copia de seguridad"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: restaurarBackup,
              icon: const Icon(Icons.cloud_download),
              label: const Text("Restaurar copia de seguridad"),
            ),
          ],
        ),
      ),
    );
  }
}


