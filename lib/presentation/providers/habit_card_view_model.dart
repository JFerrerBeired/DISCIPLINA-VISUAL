import 'package:flutter/material.dart';
import 'package:disciplina_visual/data/models/completion.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/domain/usecases/add_completion.dart';
import 'package:disciplina_visual/domain/usecases/calculate_streak.dart';
import 'package:disciplina_visual/domain/usecases/get_completions.dart';
import 'package:disciplina_visual/domain/usecases/remove_completion.dart';
import 'package:disciplina_visual/presentation/utils/date_provider.dart';

class HabitCardViewModel extends ChangeNotifier {
  final Habit habit;
  final GetCompletions getCompletions;
  final AddCompletion addCompletion;
  final RemoveCompletion removeCompletion;
  final CalculateStreak calculateStreak;
  final DateProvider dateProvider;

  HabitCardViewModel({
    required this.habit,
    required this.getCompletions,
    required this.addCompletion,
    required this.removeCompletion,
    required this.calculateStreak,
    required this.dateProvider,
  }) {
    dateProvider.addListener(loadCompletionData);
    loadCompletionData();
  }

  bool _isCompletedToday = false;
  bool get isCompletedToday => _isCompletedToday;

  int _currentStreak = 0;
  int get currentStreak => _currentStreak;

  List<Completion> _recentCompletions = [];
  List<Completion> get recentCompletions => _recentCompletions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    dateProvider.removeListener(loadCompletionData);
    super.dispose();
  }

  Future<void> loadCompletionData() async {
    _isLoading = true;
    notifyListeners();

    final allCompletions = await getCompletions(habit.id!);
    final today = dateProvider.simulatedToday;

    _isCompletedToday = allCompletions.any(
      (c) =>
          c.date.year == today.year &&
          c.date.month == today.month &&
          c.date.day == today.day,
    );
    _recentCompletions = _getRecentCompletions(allCompletions, today);
    _currentStreak = calculateStreak(allCompletions, today).current;

    _isLoading = false;
    notifyListeners();
  }

  List<Completion> _getRecentCompletions(
      List<Completion> allCompletions, DateTime today) {
    final List<Completion> recent = [];
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final completionForDay = allCompletions.firstWhere(
        (c) =>
            c.date.year == date.year &&
            c.date.month == date.month &&
            c.date.day == date.day,
        orElse: () => Completion(habitId: habit.id!, date: date),
      );
      recent.add(completionForDay);
    }
    return recent;
  }

  Future<void> toggleCompletion() async {
    final today = dateProvider.simulatedToday;
    if (_isCompletedToday) {
      await removeCompletion(habit.id!, today);
    } else {
      await addCompletion(habit.id!, today);
    }
    await loadCompletionData();
  }

  Future<void> toggleCompletionForDate(
      DateTime date, bool isCurrentlyCompleted) async {
    if (isCurrentlyCompleted) {
      await removeCompletion(habit.id!, date);
    } else {
      await addCompletion(habit.id!, date);
    }
    await loadCompletionData();
  }
}
