import 'package:disciplina_visual/data/datasources/local/database_helper.dart';
import 'package:disciplina_visual/data/models/completion.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  final DatabaseHelper databaseHelper;

  HabitRepositoryImpl({required this.databaseHelper});

  @override
  Future<void> addCompletion(int habitId, DateTime date) {
    return databaseHelper.addCompletion(habitId, date);
  }

  @override
  Future<int> createHabit(Habit habit) {
    return databaseHelper.createHabit(habit);
  }

  @override
  Future<int> deleteHabit(int id) {
    return databaseHelper.deleteHabit(id);
  }

  @override
  Future<List<Habit>> getAllHabits() {
    return databaseHelper.getAllHabits();
  }

  @override
  Future<List<Completion>> getCompletionsForHabit(int habitId) {
    return databaseHelper.getCompletionsForHabit(habitId);
  }

  @override
  Future<void> removeCompletion(int habitId, DateTime date) {
    return databaseHelper.removeCompletion(habitId, date);
  }

  @override
  Future<int> updateHabit(Habit habit) {
    return databaseHelper.updateHabit(habit);
  }

  @override
  Future<void> deleteFutureCompletions(DateTime cutoffDate) {
    return databaseHelper.deleteFutureCompletions(cutoffDate);
  }
}
