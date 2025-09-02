import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/domain/repositories/habit_repository.dart';

class GetAllHabits {
  final HabitRepository repository;

  GetAllHabits(this.repository);

  Future<List<Habit>> call() {
    return repository.getAllHabits();
  }
}
