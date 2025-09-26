import 'package:disciplina_visual/domain/entities/chart_data_point.dart';
import 'package:disciplina_visual/domain/usecases/chart_calculation_params.dart';
import 'package:disciplina_visual/domain/usecases/calculate_chart_data.dart';
import 'package:disciplina_visual/domain/helpers/completions_grouping_helper.dart';
import 'package:disciplina_visual/data/models/completion.dart';

class CalculateCompletionTotalsUseCase implements CalculateChartData {
  @override
  List<ChartDataPoint> call(ChartCalculationParams params) {
    final Map<DateTime, List<Completion>> groupedCompletions =
        CompletionsGroupingHelper.groupBy(
          params.completions,
          params.startDate,
          params.endDate,
          params.grouping,
        );

    final List<ChartDataPoint> chartPoints = [];

    // Sort the keys to ensure the chart points are in chronological order
    final sortedKeys = groupedCompletions.keys.toList()..sort();

    for (var date in sortedKeys) {
      final completionsInPeriod = groupedCompletions[date]!;
      final total = completionsInPeriod.length;
      chartPoints.add(ChartDataPoint(date: date, y: total.toDouble()));
    }

    return chartPoints;
  }
}
