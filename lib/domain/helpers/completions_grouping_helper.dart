import 'package:disciplina_visual/data/models/completion.dart';
import 'package:disciplina_visual/domain/usecases/chart_calculation_params.dart';

class CompletionsGroupingHelper {
  static Map<DateTime, List<Completion>> groupBy(
      List<Completion> allCompletions, TimeGrouping grouping) {
    final Map<DateTime, List<Completion>> groupedData = {};

    for (var completion in allCompletions) {
      DateTime key;
      switch (grouping) {
        case TimeGrouping.daily:
          key = DateTime(completion.date.year, completion.date.month, completion.date.day);
          break;
        case TimeGrouping.weekly:
          // Find the start of the week (Monday)
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

    return groupedData;
  }
}