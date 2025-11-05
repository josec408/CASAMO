import 'dart:convert';
import 'package:casamo/app_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<CursoModel> cursos = [];

  @override
  void initState() {
    super.initState();
    cargarCursos();
  }

  // ======================
  // 🔹 Cargar desde memoria
  // ======================
  Future<void> cargarCursos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cursos');

    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      setState(() {
        cursos = jsonList.map((j) => CursoModel.fromJson(j)).toList();
      });
    }
  }

  // ======================
  // 🔹 Guardar en memoria
  // ======================
  Future<void> guardarCursos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(cursos.map((c) => c.toJson()).toList());
    await prefs.setString('cursos', data);
  }

  void agregarCurso() {
    setState(() {
      cursos.add(CursoModel(nombre: "Nuevo curso"));
    });
    guardarCursos();
  }

  void eliminarCurso(int index) {
    setState(() {
      cursos.removeAt(index);
    });
    guardarCursos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "📊 Calculadora de Notas Universitarias",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < cursos.length; i++)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CursoCard(
                    curso: cursos[i],
                    onDelete: () => eliminarCurso(i),
                    onChanged: guardarCursos,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: agregarCurso,
              icon: const Icon(Icons.add),
              label: const Text("Añadir curso"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
}

// =============================
// 🧾 MODELO DE CURSO
// =============================
class CursoModel {
  String nombre;
  final p1 = TextEditingController();
  final ep = TextEditingController();
  final p2 = TextEditingController();
  final ef = TextEditingController();
  final w1 = TextEditingController(text: "20");
  final w2 = TextEditingController(text: "30");
  final w3 = TextEditingController(text: "20");
  final w4 = TextEditingController(text: "30");
  double notaFinal = 0.0;
  String mensaje = "";

  CursoModel({required this.nombre});

  // 🔹 Convertir a JSON
  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'p1': p1.text,
        'ep': ep.text,
        'p2': p2.text,
        'ef': ef.text,
        'w1': w1.text,
        'w2': w2.text,
        'w3': w3.text,
        'w4': w4.text,
        'notaFinal': notaFinal,
        'mensaje': mensaje,
      };

  // 🔹 Reconstruir desde JSON
  factory CursoModel.fromJson(Map<String, dynamic> json) {
    final c = CursoModel(nombre: json['nombre']);
    c.p1.text = json['p1'];
    c.ep.text = json['ep'];
    c.p2.text = json['p2'];
    c.ef.text = json['ef'];
    c.w1.text = json['w1'];
    c.w2.text = json['w2'];
    c.w3.text = json['w3'];
    c.w4.text = json['w4'];
    c.notaFinal = json['notaFinal'] ?? 0.0;
    c.mensaje = json['mensaje'] ?? "";
    return c;
  }
}

// =============================
// 🧮 CARD DE CURSO
// =============================
class CursoCard extends StatefulWidget {
  final CursoModel curso;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const CursoCard({
    super.key,
    required this.curso,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<CursoCard> createState() => _CursoCardState();
}

class _CursoCardState extends State<CursoCard> {
  final nombreCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    nombreCtrl.text = widget.curso.nombre;
  }

void calcularNota() {
  final c = widget.curso;

  final p1 = double.tryParse(c.p1.text) ?? 0;
  final ep = double.tryParse(c.ep.text) ?? 0;
  final p2 = double.tryParse(c.p2.text) ?? 0;
  final ef = double.tryParse(c.ef.text) ?? 0;

  final w1 = (double.tryParse(c.w1.text) ?? 0) / 100;
  final w2 = (double.tryParse(c.w2.text) ?? 0) / 100;
  final w3 = (double.tryParse(c.w3.text) ?? 0) / 100;
  final w4 = (double.tryParse(c.w4.text) ?? 0) / 100;

  final totalPeso = w1 + w2 + w3 + w4;

  setState(() {
    if (totalPeso != 1.0) {
      c.mensaje = "⚠️ Los porcentajes deben sumar 100%.";
    } else {
      c.notaFinal = (p1 * w1) + (ep * w2) + (p2 * w3) + (ef * w4);
      c.mensaje = c.notaFinal >= 11
          ? "✅ Aprobado con ${c.notaFinal.toStringAsFixed(2)}"
          : "❌ Desaprobado con ${c.notaFinal.toStringAsFixed(2)}";

      // 🔽 Aquí agregas la actualización del provider
      Provider.of<AppData>(context, listen: false)
          .actualizarPromedio(c.notaFinal);
    }
  });

  widget.onChanged(); // guardar automáticamente
}



  @override
  Widget build(BuildContext context) {
    final c = widget.curso;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(
                  labelText: "Nombre del curso",
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  c.nombre = val;
                  widget.onChanged();
                },
              ),
            ),
            IconButton(
              onPressed: widget.onDelete,
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: "Eliminar curso",
            ),
          ],
        ),
        const SizedBox(height: 10),
        filaCampo("Práctica 1", c.p1, c.w1),
        filaCampo("Examen Parcial", c.ep, c.w2),
        filaCampo("Práctica 2", c.p2, c.w3),
        filaCampo("Examen Final", c.ef, c.w4),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: calcularNota,
          child: const Text("Calcular nota final"),
        ),
        const SizedBox(height: 8),
        Text(
          c.mensaje,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: c.mensaje.contains("Aprobado")
                ? Colors.green
                : c.mensaje.contains("Desaprobado")
                    ? Colors.red
                    : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget filaCampo(String titulo, TextEditingController notaCtrl, TextEditingController pesoCtrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: notaCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "$titulo (nota)",
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => widget.onChanged(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: TextField(
              controller: pesoCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "%",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => widget.onChanged(),
            ),
          ),
        ],
      ),
    );
  }
}
