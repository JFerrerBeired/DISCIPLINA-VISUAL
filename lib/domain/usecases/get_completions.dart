import 'package:disciplina_visual/data/models/completion.dart';
import 'package:disciplina_visual/domain/repositories/habit_repository.dart';

class GetCompletions {
  final HabitRepository repository;

  GetCompletions(this.repository);

  Future<List<Completion>> call(int habitId) {
    return repository.getCompletionsForHabit(habitId);
  }
}
