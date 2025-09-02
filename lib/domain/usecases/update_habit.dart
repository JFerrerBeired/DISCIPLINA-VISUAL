import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/domain/repositories/habit_repository.dart';

class UpdateHabit {
  final HabitRepository repository;

  UpdateHabit(this.repository);

  Future<int> call(Habit habit) {
    return repository.updateHabit(habit);
  }
}
