import 'package:disciplina_visual/data/models/completion.dart';

enum TimeGrouping {
  daily,
  weekly,
  monthly,
}

class ChartCalculationParams {
  final List<Completion> completions;
  final TimeGrouping grouping;
  // Puedes añadir más parámetros aquí si son comunes a varios cálculos

  ChartCalculationParams({
    required this.completions,
    required this.grouping,
  });
}