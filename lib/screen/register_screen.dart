import 'package:casamo/screen/casamo_title.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => isLoading = true);

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registro exitoso ✅")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Error al registrarse")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          return "Ingresa una contraseña";
                        }
                        if (value.length < 6) {
                          return "Mínimo 6 caracteres";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Confirmar contraseña
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Confirmar contraseña",
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Confirma tu contraseña";
                        }
                        if (value != passwordController.text) {
                          return "Las contraseñas no coinciden";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // 🔹 Botón de registro
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Registrarse"),
                          ),

                    const SizedBox(height: 16),

                    // 🔹 Botón para volver al login
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "¿Ya tienes cuenta? Inicia sesión aquí",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
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




