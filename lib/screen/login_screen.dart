import 'package:casamo/screen/casamo_title.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // 🔹 Iniciar sesión
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => isLoading = true);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Error al iniciar sesión")),
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




