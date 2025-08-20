import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/database_helper.dart';
import '../models/completion.dart';

/// Un widget que muestra una única tarjeta de hábito.
///
/// Es un widget con estado que recibe un objeto [Habit] y lo muestra
/// con el diseño que definimos (Card, ListTile, etc.), permitiendo
/// la interacción para marcar/desmarcar el hábito del día.
class HabitCard extends StatefulWidget {
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool _isCompletedToday = false;
  int _currentStreak = 0;
  List<Completion> _recentCompletions = [];

  @override
  void initState() {
    super.initState();
    _loadCompletionData();
  }

  /// Carga todos los datos de completado y racha para el hábito.
  Future<void> _loadCompletionData() async {
    final allCompletions = await DatabaseHelper.instance.getCompletionsForHabit(widget.habit.id!);
    final today = DateTime.now();

    setState(() {
      _isCompletedToday = allCompletions.any(
        (c) => c.date.year == today.year &&
               c.date.month == today.month &&
               c.date.day == today.day,
      );
      _recentCompletions = _getRecentCompletions(allCompletions, today);
      _currentStreak = _calculateStreak(allCompletions, today);
    });
  }

  /// Obtiene los completados de los últimos 7 días (incluyendo hoy).
  List<Completion> _getRecentCompletions(List<Completion> allCompletions, DateTime today) {
    final List<Completion> recent = [];
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final completionForDay = allCompletions.firstWhere(
        (c) => c.date.year == date.year &&
               c.date.month == date.month &&
               c.date.day == date.day,
        orElse: () => Completion(habitId: widget.habit.id!, date: date), // Placeholder para días no completados
      );
      recent.add(completionForDay);
    }
    return recent.reversed.toList(); // Para que el día más antiguo esté primero
  }

  /// Calcula la racha actual (simplificado para este checkpoint).
  int _calculateStreak(List<Completion> allCompletions, DateTime today) {
    int streak = 0;
    DateTime checkDate = today;

    // Ordenar las completaciones por fecha descendente para un cálculo eficiente
    allCompletions.sort((a, b) => b.date.compareTo(a.date));

    for (int i = 0; i < allCompletions.length; i++) {
      final completionDate = allCompletions[i].date;
      // Normalizar fechas para comparar solo día, mes y año
      final normalizedCompletionDate = DateTime(completionDate.year, completionDate.month, completionDate.day);
      final normalizedCheckDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

      if (normalizedCompletionDate.isAtSameMomentAs(normalizedCheckDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (normalizedCompletionDate.isBefore(normalizedCheckDate)) {
        // Si la completación es anterior a la fecha que estamos buscando,
        // y no es el día anterior, la racha se rompe.
        if (normalizedCheckDate.difference(normalizedCompletionDate).inDays > 1) {
          break;
        }
      }
    }
    return streak;
  }

  /// Maneja el tap en el icono principal para marcar/desmarcar el hábito.
  Future<void> _toggleCompletion() async {
    final today = DateTime.now();
    if (_isCompletedToday) {
      await DatabaseHelper.instance.removeCompletion(widget.habit.id!, today);
    } else {
      await DatabaseHelper.instance.addCompletion(widget.habit.id!, today);
    }
    // Después de la acción, volvemos a cargar los datos.
    await _loadCompletionData();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: GestureDetector(
          onTap: _toggleCompletion,
          child: Icon(
            _isCompletedToday ? Icons.check_circle : Icons.check_circle_outline,
            color: _isCompletedToday ? Color(widget.habit.color) : Colors.grey,
            size: 30,
          ),
        ),
        title: Text(
          widget.habit.name,
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(widget.habit.color)),
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              color: Color(widget.habit.color),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(_currentStreak.toString()),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: _recentCompletions.map((completion) {
            final isCompleted = completion.id != null; // Si tiene ID, es un completado real
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0), // Aumentado el padding
              child: Container(
                width: 12, // Aumentado el tamaño
                height: 12, // Aumentado el tamaño
                decoration: BoxDecoration(
                  color: isCompleted ? Color(widget.habit.color) : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }).toList(),
        ),
        onTap: () {
          // Navega a la pantalla de detalles pasando el hábito.
          // La lógica de pasar datos se implementará más adelante.
          Navigator.pushNamed(context, '/details');
        },
      ),
    );
  }
}
