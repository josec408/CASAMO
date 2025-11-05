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
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título superior
            const Text(
              "¡Bienvenido a CASAMO! 🎉",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8E24AA),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Hola, ${user?.email ?? "Usuario"} 👋",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 25),

            // 🟪 Rejilla de cuadros de información
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  _buildInfoCard(
                    icon: Icons.check_circle,
                    title: "Tareas pendientes",
                    value: "${appData.tareasPendientes}",
                    color: const Color(0xFFD1C4E9),
                  ),
                  _buildInfoCard(
                    icon: Icons.bar_chart,
                    title: "Promedio general",
                    value: appData.promedioGeneral.toStringAsFixed(2),
                    color: const Color(0xFFC5CAE9),
                  ),
                  _buildInfoCard(
                    icon: Icons.timer,
                    title: "Pomodoros completados",
                    value: "${appData.pomodorosCompletados}",
                    color: const Color(0xFFFFE0B2),
                  ),
                  _buildInfoCard(
                    icon: Icons.favorite,
                    title: "Sesiones activas",
                    value: "${appData.sesionesActivas}",
                    color: const Color(0xFFB2DFDB),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

// 💎 Widget de cada cuadrito
Widget _buildInfoCard({
  required IconData icon,
  required String title,
  required String value,
  required Color color,
}) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 4,
    color: color,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: const Color(0xFF6A1B9A)),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ),
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






