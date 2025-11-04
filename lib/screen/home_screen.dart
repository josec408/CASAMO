import 'package:casamo/app_data.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

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
    return Consumer<AppData>(
      builder: (context, appData, child) {
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
                  const Text(
                    "¡Bienvenido a CASAMO! 🎉",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 139, 4, 163),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Hola, ${user?.email ?? "Usuario"} 👋",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  // 🔹 Tarjetas de resumen
                  _buildResumenTile(Icons.check_circle, "Tareas pendientes", "${appData.tareasPendientes}"),
                  _buildResumenTile(Icons.bar_chart, "Promedio general", appData.promedioGeneral.toStringAsFixed(2)),
                  _buildResumenTile(Icons.timer, "Pomodoros completados", "${appData.pomodorosCompletados}"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

Widget _buildResumenTile(IconData icon, String titulo, String valor) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: const Color.fromARGB(255, 160, 2, 240)),
        const SizedBox(width: 10),
        Text("$titulo: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        Text(valor, style: const TextStyle(fontSize: 16)),
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






