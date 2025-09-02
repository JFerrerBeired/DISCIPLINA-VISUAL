import 'package:disciplina_visual/domain/repositories/habit_repository.dart';

class RemoveCompletion {
  final HabitRepository repository;

  RemoveCompletion(this.repository);

  Future<void> call(int habitId, DateTime date) {
    return repository.removeCompletion(habitId, date);
  }
}
