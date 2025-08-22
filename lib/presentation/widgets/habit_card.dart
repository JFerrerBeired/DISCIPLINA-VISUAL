import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/presentation/providers/habit_card_view_model.dart';
import 'package:disciplina_visual/data/models/completion.dart';

class HabitCard extends StatelessWidget {
  final HabitCardViewModel viewModel;
  final VoidCallback? onTap;

  const HabitCard({super.key, required this.viewModel, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: GestureDetector(
          onTap: viewModel.toggleCompletion,
          child: Icon(
            viewModel.isCompletedToday
                ? Icons.check_circle
                : Icons.check_circle_outline,
            color:
                viewModel.isCompletedToday ? Color(viewModel.habit.color) : Colors.grey,
            size: 30,
          ),
        ),
        title: Text(
          viewModel.habit.name,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Color(viewModel.habit.color)),
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              color: Color(viewModel.habit.color),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(viewModel.currentStreak.toString()),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: viewModel.recentCompletions.map((completion) {
            final isCompleted = completion.id != null;
            return GestureDetector(
              onLongPress: () =>
                  _handleRecentCompletionLongPress(context, completion, viewModel),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Color(viewModel.habit.color)
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _handleRecentCompletionLongPress(
      BuildContext context, Completion completion, HabitCardViewModel viewModel) async {
    final isCompleted = completion.id != null;
    final action = isCompleted ? "desmarcar" : "marcar";

    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Editar ${viewModel.habit.name}"),
          content: Text(
              "¿Deseas $action este hábito para el día ${completion.date.day}/${completion.date.month}?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(action == "desmarcar" ? "Desmarcar" : "Marcar"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await viewModel.toggleCompletionForDate(completion.date, isCompleted);
    }
  }
}