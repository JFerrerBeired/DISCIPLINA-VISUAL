import 'package:disciplina_visual/data/models/completion.dart';
import 'package:disciplina_visual/data/models/habit.dart';

abstract class HabitRepository {
  Future<List<Habit>> getAllHabits();
  Future<int> createHabit(Habit habit);
  Future<int> updateHabit(Habit habit);
  Future<int> deleteHabit(int id);
  Future<void> addCompletion(int habitId, DateTime date);
  Future<void> removeCompletion(int habitId, DateTime date);
  Future<List<Completion>> getCompletionsForHabit(int habitId);
  Future<void> deleteFutureCompletions(DateTime cutoffDate);
}
