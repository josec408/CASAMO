import 'dart:async';
import 'package:casamo/app_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  int workDuration = 25;
  int shortBreak = 5;
  int longBreak = 15;
  int sessionsBeforeLongBreak = 4;

  int remainingSeconds = 0;
  int completedSessions = 0;
  bool isWorking = true;
  bool isRunning = false;
  Timer? _timer;

  List<String> tasks = ['Estudiar'];
  Set<String> completedTasks = {};

  @override
  void initState() {
    super.initState();
    remainingSeconds = workDuration * 60;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        _timer?.cancel();
        _nextSession();
      }
    });
    setState(() => isRunning = true);
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
      remainingSeconds = isWorking ? workDuration * 60 : shortBreak * 60;
    });
  }

  void _nextSession() {
    setState(() {
      if (isWorking) {
        completedSessions++;

        // ✅ Actualiza el contador global en Provider
        Provider.of<AppData>(context, listen: false).actualizarPomodoros(
          Provider.of<AppData>(context, listen: false).pomodorosCompletados + 1
        );

        if (completedSessions % sessionsBeforeLongBreak == 0) {
          isWorking = false;
          remainingSeconds = longBreak * 60;
        } else {
          isWorking = false;
          remainingSeconds = shortBreak * 60;
        }
      } else {
        isWorking = true;
        remainingSeconds = workDuration * 60;
      }
      isRunning = false;
    });
  }


  void _openSettings() {
    final workCtrl = TextEditingController(text: workDuration.toString());
    final shortCtrl = TextEditingController(text: shortBreak.toString());
    final longCtrl = TextEditingController(text: longBreak.toString());
    final sessionsCtrl = TextEditingController(text: sessionsBeforeLongBreak.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Configuración de Pomodoro"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: workCtrl,
              decoration: const InputDecoration(labelText: "Trabajo (min)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: shortCtrl,
              decoration: const InputDecoration(labelText: "Descanso corto (min)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: longCtrl,
              decoration: const InputDecoration(labelText: "Descanso largo (min)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: sessionsCtrl,
              decoration: const InputDecoration(labelText: "Sesiones antes de largo"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                workDuration = int.tryParse(workCtrl.text) ?? workDuration;
                shortBreak = int.tryParse(shortCtrl.text) ?? shortBreak;
                longBreak = int.tryParse(longCtrl.text) ?? longBreak;
                sessionsBeforeLongBreak = int.tryParse(sessionsCtrl.text) ?? sessionsBeforeLongBreak;
                remainingSeconds = workDuration * 60;
                isWorking = true;
                isRunning = false;
                _timer?.cancel();
              });
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _addTaskDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nueva tarea"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Nombre de la tarea"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => tasks.add(controller.text.trim()));
              }
              Navigator.pop(context);
            },
            child: const Text("Agregar"),
          ),
        ],
      ),
    );
  }

  void _editTask(int index) {
    final controller = TextEditingController(text: tasks[index]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar tarea"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => tasks[index] = controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _deleteTask(int index) {
    setState(() {
      completedTasks.remove(tasks[index]);
      tasks.removeAt(index);
    });
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
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
            onPressed: _openSettings,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskDialog,
        backgroundColor: purple,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            _buildTimer(purple),
            const SizedBox(height: 20),
            Expanded(child: _buildTaskList(purple)),
            const SizedBox(height: 10),
            _buildControls(purple),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer(Color color) {
    double totalSeconds = isWorking
        ? workDuration * 60
        : (completedSessions % sessionsBeforeLongBreak == 0 ? longBreak * 60 : shortBreak * 60);
    double progress = 1 - (remainingSeconds / totalSeconds);

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
            Text(isWorking ? "Trabajo" : "Descanso", style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 8),
            Text(_formatTime(remainingSeconds),
                style: TextStyle(fontSize: 38, color: color, fontWeight: FontWeight.w300)),
            const SizedBox(height: 8),
            Text("#${completedSessions + 1}", style: const TextStyle(color: Colors.black45)),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskList(Color purple) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tareas", style: TextStyle(color: Colors.black87, fontSize: 18)),
          const SizedBox(height: 8),
          ...tasks.asMap().entries.map((entry) {
            int i = entry.key;
            String task = entry.value;

            return ListTile(
              leading: Icon(
                completedTasks.contains(task) ? Icons.check_circle : Icons.circle_outlined,
                color: completedTasks.contains(task) ? purple : Colors.grey,
              ),
              title: Text(
                task,
                style: TextStyle(
                  color: Colors.black87,
                  decoration: completedTasks.contains(task) ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') _editTask(i);
                  if (value == 'delete') _deleteTask(i);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
              onTap: () {
                setState(() {
                  if (completedTasks.contains(task)) {
                    completedTasks.remove(task);
                  } else {
                    completedTasks.add(task);
                  }
                });
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildControls(Color purple) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton(
          onPressed: isRunning ? _pauseTimer : _startTimer,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: purple),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
          child: Text(isRunning ? "⏸️ Pausar" : "▶️ Iniciar", style: TextStyle(color: purple)),
        ),
        OutlinedButton(
          onPressed: _resetTimer,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: purple),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
          child: Text("⏹️ Finalizar", style: TextStyle(color: purple)),
        ),
      ],
    );
  }
  
}










