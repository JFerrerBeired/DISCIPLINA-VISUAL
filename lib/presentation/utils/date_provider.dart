import 'package:flutter/material.dart';
import 'package:disciplina_visual/domain/usecases/delete_future_completions.dart';

class DateProvider with ChangeNotifier {
  final DeleteFutureCompletions deleteFutureCompletions;
  DateTime _simulatedToday;
  int _dayOffset = 0;

  DateProvider({
    required this.deleteFutureCompletions,
    int initialOffsetDays = 0,
  }) : _simulatedToday = DateTime.now().add(Duration(days: initialOffsetDays));

  DateTime get simulatedToday => _simulatedToday;
  int get dayOffset => _dayOffset;

  void advanceDay() {
    _simulatedToday = _simulatedToday.add(const Duration(days: 1));
    _dayOffset++;
    notifyListeners();
  }

  Future<void> resetDay() async {
    _simulatedToday = DateTime.now();
    _dayOffset = 0;
    await deleteFutureCompletions(DateTime.now());
    notifyListeners();
  }
}
