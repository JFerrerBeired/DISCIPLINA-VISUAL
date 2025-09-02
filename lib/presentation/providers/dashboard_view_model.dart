import 'package:flutter/material.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/domain/usecases/get_all_habits.dart';

class DashboardViewModel extends ChangeNotifier {
  final GetAllHabits getAllHabits;

  DashboardViewModel({required this.getAllHabits});

  List<Habit> _habits = [];
  List<Habit> get habits => _habits;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadHabits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _habits = await getAllHabits();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
