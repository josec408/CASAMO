import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:casamo/app_data.dart';
import 'package:provider/provider.dart';

class Task {
  String courseName;
  String description;
  DateTime date;
  bool isDone;

  Task({
    required this.courseName,
    required this.description,
    required this.date,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() => {
        'courseName': courseName,
        'description': description,
        'date': date.toIso8601String(),
        'isDone': isDone,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        courseName: json['courseName'],
        description: json['description'],
        date: DateTime.parse(json['date']),
        isDone: json['isDone'],
      );
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<Task> _tasks = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _courseController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> taskList =
        _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', taskList);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? taskList = prefs.getStringList('tasks');

    if (taskList != null) {
      setState(() {
        _tasks.clear();
        _tasks.addAll(taskList
            .map((taskJson) => Task.fromJson(jsonDecode(taskJson)))
            .toList());
      });

      // ✅ Actualiza el contador global al cargar
      Provider.of<AppData>(context, listen: false)
          .actualizarTareas(_tasks.where((t) => !t.isDone).length);
    }
  }

  void _addTask() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() {
        _tasks.add(Task(
          courseName: _courseController.text,
          description: _descController.text,
          date: _selectedDate!,
        ));
      });

      // ✅ Actualiza tareas pendientes globalmente
      Provider.of<AppData>(context, listen: false)
          .actualizarTareas(_tasks.where((t) => !t.isDone).length);

      _saveTasks();
      Navigator.of(context).pop();
      _courseController.clear();
      _descController.clear();
      _selectedDate = null;
    }
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir nueva tarea'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _courseController,
                  decoration:
                      const InputDecoration(labelText: 'Nombre del curso'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el nombre del curso';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la descripción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'No hay fecha seleccionada'
                            : 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      ),
                    ),
                    TextButton(
                      onPressed: _pickDate,
                      child: const Text('Seleccionar fecha'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _courseController.clear();
              _descController.clear();
              _selectedDate = null;
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _addTask,
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(221, 255, 255, 255),
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _tasks.isEmpty
          ? _buildEmptyView()
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      task.courseName,
                      style: TextStyle(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.description,
                          style: TextStyle(
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : null,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fecha: ${task.date.day}/${task.date.month}/${task.date.year}',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : null,
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    trailing: Checkbox(
                      value: task.isDone,
                      onChanged: (val) {
                        setState(() {
                          task.isDone = val!;
                        });

                        // ✅ Actualizar número de tareas pendientes globalmente
                        Provider.of<AppData>(context, listen: false)
                            .actualizarTareas(
                                _tasks.where((t) => !t.isDone).length);

                        _saveTasks(); // guardar cambio
                      },
                      activeColor: Colors.black87,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: _tasks.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddTaskDialog,
              backgroundColor: Colors.black87,
              child: const Icon(Icons.add),
            )
          : null,
      backgroundColor: Colors.white,
    );
  }

  Widget _buildEmptyView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      color: Colors.white,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.checklist_rounded,
                  size: 120,
                  color: Colors.black87,
                ),
                SizedBox(height: 30),
                Text(
                  'Añadir la primera tarea',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            right: 30,
            child: Column(
              children: [
                Transform.rotate(
                  angle: -0.5,
                  child: const Icon(
                    Icons.arrow_downward,
                    size: 60,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _showAddTaskDialog,
                  backgroundColor: Colors.black87,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
