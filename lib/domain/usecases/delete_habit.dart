import 'package:disciplina_visual/domain/repositories/habit_repository.dart';

class DeleteHabit {
  final HabitRepository repository;

  DeleteHabit(this.repository);

  Future<int> call(int id) {
    return repository.deleteHabit(id);
  }
}
