import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importar las otras pantallas
import 'calendar_screen.dart';
import 'tasks_screen.dart';
import 'stats_screen.dart';
import 'pomodoro_screen.dart';
import 'settings_screen.dart'; // 👈 nueva

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final User? user = FirebaseAuth.instance.currentUser;

  // Lista de pantallas
  late final List<Widget> _pages = [
    _dashboard(), // Pantalla de inicio personalizada
    const CalendarScreen(),
    const TasksScreen(),
    const StatsScreen(),
    const PomodoroScreen(),
    const SettingsScreen(), // 👈 Configuraciones
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 139, 4, 163),
        centerTitle: true,
        title: const Text(
          "📚 CASAMO ⏱️",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color.fromARGB(255, 139, 4, 163),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendario"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: "Tareas"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Estadísticas"),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: "Pomodoro"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Config."),
        ],
      ),
    );
  }

  // 🔹 Pantalla de inicio mejorada
  Widget _dashboard() {
    final frases = [
      "💪 La disciplina vence al talento.",
      "📘 Estudia hoy, brilla mañana.",
      "🔥 Cada pequeño avance cuenta.",
      "🚀 La constancia es el camino al éxito.",
      "🧠 Aprende algo nuevo cada día.",
    ];
    frases.shuffle();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🏠 Bienvenida
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const Icon(Icons.home, size: 70, color: Color.fromARGB(255, 139, 4, 163)),
                  const SizedBox(height: 10),
                  const Text(
                    "¡Bienvenido a CASAMO! 🎉",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 139, 4, 163),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Hola, ${user?.email ?? "Usuario"} 👋",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🌟 Frase motivacional
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 243, 229, 255),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              frases.first,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Color.fromARGB(255, 100, 3, 143),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // 📊 Resumen rápido
          const Text(
            "Resumen de Actividad 📅",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 139, 4, 163),
            ),
          ),
          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoCard("Tareas", "3", Icons.check_circle, Colors.blue),
              _infoCard("Cursos", "4", Icons.school, Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoCard("Pomodoro", "2h 45m", Icons.timer, Colors.orange),
              _infoCard("Notas", "Prom. 14.6", Icons.bar_chart, Colors.purple),
            ],
          ),

          const SizedBox(height: 30),

          // 💜 Mensaje final motivador
          const Text(
            "💜 ¡Sigue avanzando, estás haciendo un gran trabajo!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // 🔹 Widget auxiliar para las tarjetas de resumen
  Widget _infoCard(String titulo, String valor, IconData icono, Color color) {
    return Expanded(
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 35, color: color),
              const SizedBox(height: 10),
              Text(
                valor,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                titulo,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






