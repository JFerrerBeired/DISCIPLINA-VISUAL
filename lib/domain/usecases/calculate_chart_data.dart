import 'package:disciplina_visual/domain/entities/chart_data_point.dart';
import 'package:disciplina_visual/domain/usecases/chart_calculation_params.dart';

abstract class CalculateChartData {
  List<ChartDataPoint> call(ChartCalculationParams params);
}
