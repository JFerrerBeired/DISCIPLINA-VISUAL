import 'package:disciplina_visual/data/models/completion.dart';
import 'package:disciplina_visual/domain/usecases/chart_calculation_params.dart';

class CompletionsGroupingHelper {
  static Map<DateTime, List<Completion>> groupBy(
      List<Completion> allCompletions, DateTime startDate, DateTime endDate, TimeGrouping grouping) {
    final Map<DateTime, List<Completion>> groupedData = {};

    // First, populate with existing completions
    for (var completion in allCompletions) {
      DateTime key;
      switch (grouping) {
        case TimeGrouping.daily:
          key = DateTime(completion.date.year, completion.date.month, completion.date.day);
          break;
        case TimeGrouping.weekly:
          DateTime date = DateTime(completion.date.year, completion.date.month, completion.date.day);
          while (date.weekday != DateTime.monday) {
            date = date.subtract(const Duration(days: 1));
          }
          key = date;
          break;
        case TimeGrouping.monthly:
          key = DateTime(completion.date.year, completion.date.month);
          break;
      }
      groupedData.putIfAbsent(key, () => []).add(completion);
    }

    // Now, fill in missing periods from startDate to endDate
    DateTime currentPeriodStart = DateTime(startDate.year, startDate.month, startDate.day);
    // Adjust currentPeriodStart to the beginning of its period based on grouping
    switch (grouping) {
      case TimeGrouping.daily:
        // Already at start of day
        break;
      case TimeGrouping.weekly:
        while (currentPeriodStart.weekday != DateTime.monday) {
          currentPeriodStart = currentPeriodStart.subtract(const Duration(days: 1));
        }
        break;
      case TimeGrouping.monthly:
        currentPeriodStart = DateTime(currentPeriodStart.year, currentPeriodStart.month);
        break;
    }

    DateTime endPeriod = DateTime(endDate.year, endDate.month, endDate.day);
    // Adjust endPeriod to the beginning of its period based on grouping
    switch (grouping) {
      case TimeGrouping.daily:
        // Already at start of day
        break;
      case TimeGrouping.weekly:
        while (endPeriod.weekday != DateTime.monday) {
          endPeriod = endPeriod.subtract(const Duration(days: 1));
        }
        break;
      case TimeGrouping.monthly:
        endPeriod = DateTime(endPeriod.year, endPeriod.month);
        break;
    }


    while (currentPeriodStart.isBefore(endPeriod) || currentPeriodStart.isAtSameMomentAs(endPeriod)) {
      groupedData.putIfAbsent(currentPeriodStart, () => []); // Ensure period exists, even if empty

      // Move to the next period
      switch (grouping) {
        case TimeGrouping.daily:
          currentPeriodStart = currentPeriodStart.add(const Duration(days: 1));
          break;
        case TimeGrouping.weekly:
          currentPeriodStart = currentPeriodStart.add(const Duration(days: 7));
          break;
        case TimeGrouping.monthly:
          currentPeriodStart = DateTime(currentPeriodStart.year, currentPeriodStart.month + 1);
          break;
      }
    }

    return groupedData;
  }
}