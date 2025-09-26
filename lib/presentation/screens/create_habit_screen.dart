import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/presentation/providers/create_habit_view_model.dart';

class CreateHabitScreen extends StatefulWidget {
  final Habit? habit;

  const CreateHabitScreen({super.key, this.habit});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _selectedColor = Color(widget.habit!.color);
    }
  }

  void _saveHabit() async {
    if (!mounted) return;
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre del hábito no puede estar vacío.'),
        ),
      );
      return;
    }

    final viewModel = Provider.of<CreateHabitViewModel>(context, listen: false);
    final success = await viewModel.saveHabit(
      habit: widget.habit,
      name: name,
      color: _selectedColor.value,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el hábito: ${viewModel.error}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.habit == null ? 'Crear Nuevo Hábito' : 'Editar Hábito',
        ),
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
                    Color color = Colors.blue;
                    switch (colorName) {
                      case 'blue':
                        color = Colors.blue;
                        break;
                      case 'green':
                        color = Colors.green;
                        break;
                      case 'red':
                        color = Colors.red;
                        break;
                      case 'purple':
                        color = Colors.purple;
                        break;
                      case 'orange':
                        color = Colors.orange;
                        break;
                      case 'teal':
                        color = Colors.teal;
                        break;
                    }
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == color
                                ? Colors.black
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
            const SizedBox(height: 30),
            Center(
              child: Consumer<CreateHabitViewModel>(
                builder: (context, viewModel, child) {
                  return ElevatedButton(
                    onPressed: viewModel.isLoading ? null : _saveHabit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: viewModel.isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Guardar Hábito',
                            style: TextStyle(fontSize: 18),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
