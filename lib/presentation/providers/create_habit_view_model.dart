import 'package:flutter/material.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/domain/usecases/add_habit.dart';
import 'package:disciplina_visual/domain/usecases/update_habit.dart';

class CreateHabitViewModel extends ChangeNotifier {
  final AddHabit addHabit;
  final UpdateHabit updateHabit;

  CreateHabitViewModel({required this.addHabit, required this.updateHabit});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<bool> saveHabit({
    Habit? habit,
    required String name,
    required int color,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (habit != null) {
        final updatedHabit = habit.copyWith(name: name, color: color);
        await updateHabit(updatedHabit);
      } else {
        final newHabit = Habit(
          name: name,
          color: color,
          creationDate: DateTime.now(),
        );
        await addHabit(newHabit);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
