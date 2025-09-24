import 'package:disciplina_visual/data/models/completion.dart';

enum TimeGrouping {
  daily,
  weekly,
  monthly,
}

class ChartCalculationParams {
  final List<Completion> completions;
  final TimeGrouping grouping;
  final DateTime startDate; 
  final DateTime endDate; 

  ChartCalculationParams({
    required this.completions,
    required this.grouping,
    required this.startDate,
    required this.endDate,
  });
}