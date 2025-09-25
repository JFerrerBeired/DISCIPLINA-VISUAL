import 'package:disciplina_visual/data/models/completion.dart';
import 'package:disciplina_visual/domain/usecases/chart_calculation_params.dart';

class CompletionsGroupingHelper {
  static Map<DateTime, List<Completion>> groupBy(
    List<Completion> allCompletions,
    DateTime startDate,
    DateTime endDate,
    TimeGrouping grouping,
  ) {
    // Adjust start and end dates to the beginning of their respective periods
    DateTime adjustedStartDate = _getPeriodStart(startDate, grouping);
    DateTime adjustedEndDate = _getPeriodStart(endDate, grouping);

    // Create a map with all periods initialized with empty lists
    final Map<DateTime, List<Completion>> groupedData = {};
    DateTime currentDate = adjustedStartDate;

    // Initialize all periods in the range with empty lists
    while (currentDate.isBefore(adjustedEndDate) ||
        currentDate.isAtSameMomentAs(adjustedEndDate)) {
      groupedData[currentDate] = [];
      currentDate = _getNextPeriod(currentDate, grouping);
    }

    // Add completions to their respective periods
    for (var completion in allCompletions) {
      DateTime period = _getPeriodStart(completion.date, grouping);

      // Only add completions that fall within our date range
      if (period.isAfter(adjustedEndDate) ||
          period.isBefore(adjustedStartDate)) {
        continue;
      }

      groupedData[period]?.add(completion);
    }

    return groupedData;
  }

  /// Returns the start of the period for the given date based on grouping
  static DateTime _getPeriodStart(DateTime date, TimeGrouping grouping) {
    switch (grouping) {
      case TimeGrouping.daily:
        return DateTime(date.year, date.month, date.day);
      case TimeGrouping.weekly:
        // Calculate how many days to subtract to get to Monday
        // weekday(): 1=Monday, 2=Tuesday, ..., 7=Sunday
        // Monday is 1, so subtract 0 days; Sunday is 7, so subtract 6 days
        int daysToSubtract = date.weekday - 1; 
        return DateTime(date.year, date.month, date.day - daysToSubtract);
      case TimeGrouping.monthly:
        return DateTime(date.year, date.month);
    }
  }

  /// Returns the next period based on the current date and grouping
  static DateTime _getNextPeriod(DateTime date, TimeGrouping grouping) {
    switch (grouping) {
      case TimeGrouping.daily:
        return date.add(const Duration(days: 1));
      case TimeGrouping.weekly:
        return date.add(const Duration(days: 7));
      case TimeGrouping.monthly:
        return DateTime(date.year, date.month + 1);
    }
  }
}
