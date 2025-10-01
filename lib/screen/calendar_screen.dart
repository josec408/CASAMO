import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<String, Map<String, String>> _schedule = {};

  final List<String> _days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];

  List<String> get _hours {
    return List.generate(17, (index) {
      final hour = index + 7;
      final formatted = hour.toString().padLeft(2, '0');
      return '$formatted:00';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final scheduleString = prefs.getString('schedule');
    if (scheduleString != null) {
      final Map<String, dynamic> decoded = jsonDecode(scheduleString);
      setState(() {
        _schedule = decoded.map((day, hoursMap) {
          final hours = Map<String, String>.from(hoursMap);
          return MapEntry(day, hours);
        });
      });
    }
  }

  Future<void> _saveSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_schedule);
    await prefs.setString('schedule', encoded);
  }

  void _addSubject(String day, String hour) {
    final TextEditingController controller = TextEditingController(text: _schedule[day]?[hour]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Añadir clase - $day a las $hour'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre de la clase o actividad',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Guardar'),
            onPressed: () {
              setState(() {
                if (controller.text.trim().isEmpty) {
                  // Si el texto está vacío, eliminar la entrada
                  _schedule[day]?.remove(hour);
                  if (_schedule[day]?.isEmpty ?? true) {
                    _schedule.remove(day);
                  }
                } else {
                  _schedule[day] ??= {};
                  _schedule[day]![hour] = controller.text.trim();
                }
              });
              _saveSchedule();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String day, String hour) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar clase'),
        content: Text('¿Quieres eliminar la clase de $day a las $hour?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Eliminar'),
            onPressed: () {
              setState(() {
                _schedule[day]?.remove(hour);
                if (_schedule[day]?.isEmpty ?? true) {
                  _schedule.remove(day);
                }
              });
              _saveSchedule();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Table(
        border: TableBorder.all(color: Colors.black26),
        defaultColumnWidth: const FlexColumnWidth(),
        columnWidths: {
          0: FlexColumnWidth(1.5),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(color: Colors.black12),
            children: [
              const TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Hora',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ..._days.map(
                (day) => TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      day,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          ..._hours.map(
            (hour) => TableRow(
              children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      hour,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                ..._days.map(
                  (day) => TableCell(
                    child: InkWell(
                      onTap: () => _addSubject(day, hour),
                      onLongPress: () {
                        if (_schedule[day]?[hour] != null) {
                          _confirmDelete(day, hour);
                        }
                      },
                      child: Container(
                        height: 60,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          _schedule[day]?[hour] ?? '+',
                          style: TextStyle(
                            color: _schedule[day]?[hour] != null ? Colors.black : Colors.grey,
                            fontWeight: _schedule[day]?[hour] != null ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Calendario y Horario'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: Colors.redAccent),
                defaultTextStyle: TextStyle(color: Colors.black87),
              ),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekendStyle: TextStyle(color: Colors.redAccent),
                weekdayStyle: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedDay != null)
              Text(
                'Seleccionaste: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 30),
            const Text(
              'Horario semanal:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: _buildScheduleTable(),
            ),
          ],
        ),
      ),
    );
  }
}






