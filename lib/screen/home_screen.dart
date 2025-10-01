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
    _dashboard(), // Tu diseño actual de bienvenida
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
          "📚CASAMO ⏱️",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        // ❌ quitamos el botón de logout
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
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Config."), // 👈 nuevo
        ],
      ),
    );
  }

  // 🔹 Mantiene tu diseño original como widget
  Widget _dashboard() {
    return Center(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.home, size: 70, color: Color.fromARGB(255, 160, 2, 240)),
              const SizedBox(height: 20),
              Text(
                "¡Bienvenido a CASAMO! 🎉",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 139, 4, 163),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                "Hola, ${user?.email ?? "Usuario"} 👋",
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}





