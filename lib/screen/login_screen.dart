import 'package:casamo/screen/casamo_title.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // 🔹 Iniciar sesión con verificación de copia de seguridad
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => isLoading = true);

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = credential.user;
      final firestore = FirebaseFirestore.instance;

      // 🔸 Verificar si existe una copia de seguridad
      final doc = await firestore
          .collection('usuarios')
          .doc(user!.uid)
          .collection('backup')
          .doc('ultimo')
          .get();

      if (doc.exists) {
        final shouldRestore = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Restaurar copia de seguridad"),
            content: const Text(
              "Se encontró una copia de seguridad en tu cuenta.\n¿Deseas restaurarla?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("No"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Sí, restaurar"),
              ),
            ],
          ),
        );

        if (shouldRestore == true) {
          final prefs = await SharedPreferences.getInstance();
          final data = doc['datos'];

          // Restaurar datos a local
          await prefs.setString('tarea', data['tarea'] ?? '');
          await prefs.setInt('duracion', data['duracion'] ?? 0);

          // Actualizar nombre del perfil en FirebaseAuth
          await user.updateDisplayName(data['nombre']);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copia restaurada correctamente ✅')),
            );
          }
        }
      }

      // 🔸 Ir al Home
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Error al iniciar sesión")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 🔹 Recuperar contraseña
  Future<void> resetPassword() async {
    String email = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Recuperar contraseña"),
        content: TextField(
          onChanged: (value) => email = value.trim(),
          decoration: const InputDecoration(
            labelText: "Correo electrónico",
            prefixIcon: Icon(Icons.email),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (email.isNotEmpty) {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: email);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Correo de recuperación enviado ✅"),
                      ),
                    );
                  }
                }
              } on FirebaseAuthException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.message ?? "Error")),
                );
              }
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CasamoTitle(fontSize: 36),
                    const SizedBox(height: 20),

                    // 🔹 Campo de email
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Correo",
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Ingresa tu correo";
                        }
                        final emailRegex =
                            RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return "Correo no válido";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Campo de contraseña
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Ingresa tu contraseña";
                        }
                        if (value.length < 6) {
                          return "Mínimo 6 caracteres";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // 🔹 Botón login
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Iniciar sesión"),
                          ),

                    const SizedBox(height: 12),

                    // 🔹 Recuperar contraseña
                    TextButton(
                      onPressed: resetPassword,
                      child: const Text("¿Olvidaste tu contraseña?"),
                    ),

                    // 🔹 Ir a registro
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text("¿No tienes cuenta? Regístrate aquí"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}





