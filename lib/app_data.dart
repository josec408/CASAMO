import 'package:flutter/material.dart';

class AppData extends ChangeNotifier {
  int tareasPendientes = 0;
  double promedioGeneral = 0.0;
  int pomodorosCompletados = 0;

  // Métodos para actualizar los valores
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
}