import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController _nameController = TextEditingController();

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
      setState(() {}); // refresca la vista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
          ],
        ),
      ),
    );
  }
}

