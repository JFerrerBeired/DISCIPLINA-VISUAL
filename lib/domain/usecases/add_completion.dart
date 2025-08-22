import 'package:disciplina_visual/domain/repositories/habit_repository.dart';

class AddCompletion {
  final HabitRepository repository;

  AddCompletion(this.repository);

  Future<void> call(int habitId, DateTime date) {
    return repository.addCompletion(habitId, date);
  }
}
