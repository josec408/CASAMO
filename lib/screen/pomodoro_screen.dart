import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casamo/app_data.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  final TextEditingController workCtrl = TextEditingController();
  final TextEditingController shortCtrl = TextEditingController();
  final TextEditingController longCtrl = TextEditingController();
  final TextEditingController sessionsCtrl = TextEditingController();

  @override
  void dispose() {
    workCtrl.dispose();
    shortCtrl.dispose();
    longCtrl.dispose();
    sessionsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purple = Colors.purple;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Pomodoro", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTaskDialog(context),
        backgroundColor: purple,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Consumer<AppData>(
          builder: (context, data, _) {
            double totalSeconds = data.isWorking
                ? data.workDuration * 60
                : (data.completedSessions % data.sessionsBeforeLongBreak == 0
                    ? data.longBreak * 60
                    : data.shortBreak * 60);

            double progress = 1 - (data.pomodoroSegundos / totalSeconds);
            if (progress < 0) progress = 0;
            if (progress > 1) progress = 1;

            return Column(
              children: [
                _buildTimer(data, purple, progress, totalSeconds),
                const SizedBox(height: 20),
                Expanded(child: _buildTaskList(data, purple)),
                const SizedBox(height: 10),
                _buildControls(data, purple),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimer(AppData data, Color color, double progress, double totalSeconds) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(data.isWorking ? "Trabajo" : "Descanso",
                style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 8),
            Text(
              _formatTime(data.pomodoroSegundos),
              style: TextStyle(fontSize: 38, color: color, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 8),
            Text("#${data.completedSessions + 1}", style: const TextStyle(color: Colors.black45)),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskList(AppData data, Color purple) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tareas", style: TextStyle(color: Colors.black87, fontSize: 18)),
          const SizedBox(height: 8),
          ...data.tasks.asMap().entries.map((entry) {
            int i = entry.key;
            String task = entry.value;

            return ListTile(
              leading: Icon(
                data.completedTasks.contains(task) ? Icons.check_circle : Icons.circle_outlined,
                color: data.completedTasks.contains(task) ? purple : Colors.grey,
              ),
              title: Text(
                task,
                style: TextStyle(
                  color: Colors.black87,
                  decoration: data.completedTasks.contains(task) ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') _editTask(context, data, i);
                  if (value == 'delete') data.deleteTask(i);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
              onTap: () => data.toggleTaskCompletion(task),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildControls(AppData data, Color purple) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton(
          onPressed: data.pomodoroActivo ? data.pausarPomodoro : data.iniciarPomodoro,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: purple),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
          child: Text(
            data.pomodoroActivo ? "⏸️ Pausar" : "▶️ Iniciar",
            style: TextStyle(color: purple),
          ),
        ),
        OutlinedButton(
          onPressed: data.reiniciarPomodoro,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: purple),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
          child: Text("⏹️ Finalizar", style: TextStyle(color: purple)),
        ),
      ],
    );
  }

  void _openSettings(BuildContext context) {
    final data = Provider.of<AppData>(context, listen: false);
    workCtrl.text = data.workDuration.toString();
    shortCtrl.text = data.shortBreak.toString();
    longCtrl.text = data.longBreak.toString();
    sessionsCtrl.text = data.sessionsBeforeLongBreak.toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Configuración de Pomodoro"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: workCtrl, decoration: const InputDecoration(labelText: "Trabajo (min)"), keyboardType: TextInputType.number),
            TextField(controller: shortCtrl, decoration: const InputDecoration(labelText: "Descanso corto (min)"), keyboardType: TextInputType.number),
            TextField(controller: longCtrl, decoration: const InputDecoration(labelText: "Descanso largo (min)"), keyboardType: TextInputType.number),
            TextField(controller: sessionsCtrl, decoration: const InputDecoration(labelText: "Sesiones antes de largo"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              data.updatePomodoroSettings(
                work: int.tryParse(workCtrl.text),
                shortBreak: int.tryParse(shortCtrl.text),
                longBreak: int.tryParse(longCtrl.text),
                sessionsBeforeLongBreak: int.tryParse(sessionsCtrl.text),
              );
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _addTaskDialog(BuildContext context) {
    final controller = TextEditingController();
    final data = Provider.of<AppData>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nueva tarea"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Nombre de la tarea")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) data.addTask(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Agregar"),
          ),
        ],
      ),
    );
  }

  void _editTask(BuildContext context, AppData data, int index) {
    final controller = TextEditingController(text: data.tasks[index]);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar tarea"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) data.editTask(index, controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }
}
