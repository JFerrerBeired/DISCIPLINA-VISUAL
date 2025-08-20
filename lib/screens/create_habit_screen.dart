import 'package:flutter/material.dart';
import 'package:disciplina_visual/models/habit.dart';
import 'package:disciplina_visual/services/database_helper.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedColor = Colors.blue.value; // Color por defecto

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Método para guardar el hábito.
  void _saveHabit() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      // Mostrar un mensaje de error o validación si el nombre está vacío.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre del hábito no puede estar vacío.')),
      );
      return;
    }

    final newHabit = Habit(
      name: name,
      color: _selectedColor,
      creationDate: DateTime.now(),
    );

    await DatabaseHelper.instance.createHabit(newHabit);

    // Volver a la pantalla anterior (Dashboard).
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Hábito'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Hábito',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Selecciona un color:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['blue', 'green', 'red', 'purple', 'orange', 'teal']
                  .map((colorName) {
                    Color color = Colors.blue; // Default
                    switch (colorName) {
                      case 'blue': color = Colors.blue; break;
                      case 'green': color = Colors.green; break;
                      case 'red': color = Colors.red; break;
                      case 'purple': color = Colors.purple; break;
                      case 'orange': color = Colors.orange; break;
                      case 'teal': color = Colors.teal; break;
                    }
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color.value;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == color.value
                                ? Colors.black
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _saveHabit, // Conectamos el botón al método _saveHabit
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Guardar Hábito', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}