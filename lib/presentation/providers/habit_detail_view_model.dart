import 'package:flutter/material.dart';
import 'package:disciplina_visual/data/models/completion.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/domain/usecases/add_completion.dart';
import 'package:disciplina_visual/domain/usecases/calculate_streak.dart';
import 'package:disciplina_visual/domain/usecases/delete_habit.dart';
import 'package:disciplina_visual/domain/usecases/get_completions.dart';
import 'package:disciplina_visual/domain/usecases/remove_completion.dart';
import 'package:disciplina_visual/presentation/utils/date_provider.dart';

class HabitDetailViewModel extends ChangeNotifier {
  final GetCompletions getCompletions;
  final AddCompletion addCompletion;
  final RemoveCompletion removeCompletion;
  final DeleteHabit deleteHabit;
  final CalculateStreak calculateStreak;
  final DateProvider dateProvider;

  HabitDetailViewModel({
    required this.getCompletions,
    required this.addCompletion,
    required this.removeCompletion,
    required this.deleteHabit,
    required this.calculateStreak,
    required this.dateProvider,
  });

  List<Completion> _completions = [];
  List<Completion> get completions => _completions;

  Streak? _streak;
  Streak? get streak => _streak;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadCompletions(int habitId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _completions = await getCompletions(habitId);
      _streak = calculateStreak(_completions, dateProvider.simulatedToday);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCompletionForHabit(int habitId, DateTime date) async {
    await addCompletion(habitId, date);
    await loadCompletions(habitId);
  }

  Future<void> removeCompletionForHabit(int habitId, DateTime date) async {
    await removeCompletion(habitId, date);
    await loadCompletions(habitId);
  }

  Future<void> deleteHabitById(int habitId) async {
    await deleteHabit(habitId);
  }
}
