import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/domain/repositories/habit_repository.dart';

class AddHabit {
  final HabitRepository repository;

  AddHabit(this.repository);

  Future<int> call(Habit habit) {
    return repository.createHabit(habit);
  }
}
