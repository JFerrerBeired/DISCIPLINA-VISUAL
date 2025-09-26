import 'package:disciplina_visual/data/models/completion.dart';

class Streak {
  final int current;
  final int record;

  Streak({required this.current, required this.record});
}

class CalculateStreak {
  Streak call(List<Completion> completions, DateTime today) {
    return Streak(
      current: _calculateCurrentStreak(completions, today),
      record: _calculateRecordStreak(completions),
    );
  }

  int _calculateCurrentStreak(List<Completion> completions, DateTime today) {
    if (completions.isEmpty) return 0;

    final Set<DateTime> completedDates = completions
        .map((c) => DateTime(c.date.year, c.date.month, c.date.day))
        .toSet();

    int streak = 0;
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    if (!completedDates.contains(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
      if (!completedDates.contains(checkDate)) {
        return 0;
      }
    }

    while (completedDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int _calculateRecordStreak(List<Completion> completions) {
    if (completions.isEmpty) return 0;

    int maxStreak = 0;
    int currentStreak = 0;

    completions.sort((a, b) => a.date.compareTo(b.date));

    final Set<DateTime> completedDates = completions
        .map((c) => DateTime(c.date.year, c.date.month, c.date.day))
        .toSet();

    if (completedDates.isEmpty) return 0;

    List<DateTime> sortedUniqueDates = completedDates.toList()..sort();

    for (int i = 0; i < sortedUniqueDates.length; i++) {
      if (i == 0) {
        currentStreak = 1;
      } else {
        final Duration difference = sortedUniqueDates[i].difference(
          sortedUniqueDates[i - 1],
        );
        if (difference.inDays == 1) {
          currentStreak++;
        } else if (difference.inDays > 1) {
          currentStreak = 1;
        }
      }
      if (currentStreak > maxStreak) {
        maxStreak = currentStreak;
      }
    }
    return maxStreak;
  }
}
