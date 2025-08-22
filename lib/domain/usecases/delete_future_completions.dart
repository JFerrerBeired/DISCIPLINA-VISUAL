import 'package:disciplina_visual/domain/repositories/habit_repository.dart';

class DeleteFutureCompletions {
  final HabitRepository repository;

  DeleteFutureCompletions(this.repository);

  Future<void> call(DateTime cutoffDate) {
    return repository.deleteFutureCompletions(cutoffDate);
  }
}
