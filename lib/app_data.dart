import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background/flutter_background.dart';

// Instancia global de notificaciones
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class AppData extends ChangeNotifier {
  // Datos generales
  int tareasPendientes = 0;
  double promedioGeneral = 0.0;
  int pomodorosCompletados = 0;
  int sesionesActivas = 0;

  // -------------------
  // Pomodoro
  int pomodoroSegundos = 0;
  bool pomodoroActivo = false;
  Timer? _pomodoroTimer;

  // Configuración Pomodoro
  int workDuration = 25; // min
  int shortBreak = 5; // min
  int longBreak = 15; // min
  int sessionsBeforeLongBreak = 4;
  bool isWorking = true;
  int completedSessions = 0;

  // Tareas
  List<String> tasks = [];
  Set<String> completedTasks = {};

  // -------------------
  // Tareas
  void addTask(String task) {
    tasks.add(task);
    notifyListeners();
  }

  void editTask(int index, String newTask) {
    tasks[index] = newTask;
    notifyListeners();
  }

  void deleteTask(int index) {
    completedTasks.remove(tasks[index]);
    tasks.removeAt(index);
    notifyListeners();
  }

  void toggleTaskCompletion(String task) {
    completedTasks.contains(task)
        ? completedTasks.remove(task)
        : completedTasks.add(task);
    notifyListeners();
  }

  // -------------------
  // Configuración Pomodoro
  void updatePomodoroSettings(
      {int? work, int? shortBreak, int? longBreak, int? sessionsBeforeLongBreak}) {
    if (work != null) workDuration = work;
    if (shortBreak != null) this.shortBreak = shortBreak;
    if (longBreak != null) this.longBreak = longBreak;
    if (sessionsBeforeLongBreak != null)
      this.sessionsBeforeLongBreak = sessionsBeforeLongBreak;

    reiniciarPomodoro();
  }

  // -------------------
  // Pomodoro
  Future<void> iniciarPomodoro() async {
    if (pomodoroActivo) return;

    await FlutterBackground.enableBackgroundExecution();
    pomodoroActivo = true;

    if (pomodoroSegundos == 0) {
      pomodoroSegundos = isWorking ? workDuration * 60 : shortBreak * 60;
    }

    _pomodoroTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (pomodoroSegundos > 0) {
        pomodoroSegundos--;
      } else {
        _pomodoroTimer?.cancel();
        _triggerEndNotification(); // 🔔 Solo ahora suena y vibra
        _nextSession();
      }
      _actualizarNotificacion(silent: true); // 🔕 Silenciosa mientras corre
      notifyListeners();
    });

    _actualizarNotificacion(silent: true);
    notifyListeners();
  }

  void pausarPomodoro() async {
    _pomodoroTimer?.cancel();
    pomodoroActivo = false;
    notifyListeners();
    await FlutterBackground.disableBackgroundExecution();
    detenerNotificacion();
  }

  void reiniciarPomodoro() async {
    _pomodoroTimer?.cancel();
    pomodoroSegundos = isWorking ? workDuration * 60 : shortBreak * 60;
    pomodoroActivo = false;
    notifyListeners();
    await FlutterBackground.disableBackgroundExecution();
    detenerNotificacion();
  }

  void _nextSession() {
    if (isWorking) {
      completedSessions++;
      pomodorosCompletados++;
      // Alterna a descanso
      isWorking = completedSessions % sessionsBeforeLongBreak == 0 ? false : false;
      pomodoroSegundos =
          (completedSessions % sessionsBeforeLongBreak == 0 ? longBreak : shortBreak) * 60;
    } else {
      // Terminado descanso -> nuevo trabajo
      isWorking = true;
      pomodoroSegundos = workDuration * 60;
    }
    pomodoroActivo = false; // Se detiene hasta iniciar manualmente
    notifyListeners();
  }

  // -------------------
  // Notificaciones
  Future<void> _actualizarNotificacion({bool silent = true}) async {
    final channelId = silent ? 'pomodoro_channel_silent' : 'pomodoro_channel_end';
    final androidDetails = AndroidNotificationDetails(
      channelId,
      silent ? 'Pomodoro silencioso' : 'Pomodoro terminado',
      channelDescription: silent
          ? 'Pomodoro en curso, sin sonido ni vibración'
          : 'Pomodoro finalizado con sonido y vibración',
      importance: silent ? Importance.low : Importance.max,
      priority: silent ? Priority.low : Priority.high,
      ongoing: silent,
      playSound: !silent,
      enableVibration: !silent,
      showWhen: false,
    );

    final details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      silent ? 0 : 1,
      silent ? 'Pomodoro ${isWorking ? "Trabajo" : "Descanso"} 🍅' : '¡Tiempo terminado! ⏰',
      silent
          ? _formatTime(pomodoroSegundos)
          : (isWorking ? 'Termina tu descanso, a trabajar 🍅' : 'Tiempo de descanso finalizado!'),
      details,
    );
  }

  Future<void> _triggerEndNotification() async {
    await _actualizarNotificacion(silent: false);
  }

  Future<void> detenerNotificacion() async =>
      flutterLocalNotificationsPlugin.cancelAll();

  // -------------------
  // Datos generales
  void actualizarTareas(int nuevasTareas) {
    tareasPendientes = nuevasTareas;
    notifyListeners();
  }

  void actualizarPromedio(double nuevoPromedio) {
    promedioGeneral = nuevoPromedio;
    notifyListeners();
  }

  void actualizarPomodoros(int nuevosPomodoros) {
    pomodorosCompletados = nuevosPomodoros;
    notifyListeners();
  }

  void actualizarSesiones(int nuevasSesiones) {
    sesionesActivas = nuevasSesiones;
    notifyListeners();
  }

  // -------------------
  // Formato de tiempo
  String _formatTime(int segundos) {
    int min = segundos ~/ 60;
    int sec = segundos % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }
}
