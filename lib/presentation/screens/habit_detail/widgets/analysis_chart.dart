import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:disciplina_visual/data/models/completion.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/presentation/utils/date_provider.dart';

// Calculates chart points based on the full habit history, counting absolute completions per week.
List<FlSpot> _getWeeklyChartData(List<Completion> completions, Habit habit) {
  if (completions.isEmpty) {
    return [];
  }

  // Determine the first Monday of the habit's creation week
  DateTime firstMondayOfHabit = habit.creationDate;
  if (firstMondayOfHabit.weekday != DateTime.monday) {
    firstMondayOfHabit = firstMondayOfHabit.subtract(Duration(days: firstMondayOfHabit.weekday - DateTime.monday));
  }

  final Map<int, int> weeklyCompletionsCount = {};

  for (var completion in completions) {
    // Calculate the week index from the first Monday of the habit
    final weekIndex = (completion.date.difference(firstMondayOfHabit).inDays / 7).floor();
    if (weekIndex < 0) continue; // Ignore completions before the first Monday of the habit
    weeklyCompletionsCount.update(weekIndex, (value) => value + 1,
        ifAbsent: () => 1);
  }

  final List<FlSpot> spots = [];
  if (weeklyCompletionsCount.isNotEmpty) {
    final int maxWeek = weeklyCompletionsCount.keys.reduce((a, b) => a > b ? a : b);
    // Ensure all weeks from 0 to maxWeek are represented
    for (int i = 0; i <= maxWeek; i++) {
      final count = weeklyCompletionsCount[i] ?? 0;
      spots.add(FlSpot(i.toDouble(), count.toDouble()));
    }
  }

  return spots;
}

class AnalysisChart extends StatelessWidget {
  final List<Completion> completions;
  final DateTime simulatedToday;
  final Habit habit;
  final DateProvider dateProvider;

  const AnalysisChart({
    super.key,
    required this.completions,
    required this.simulatedToday,
    required this.habit,
    required this.dateProvider,
  });

  @override
  Widget build(BuildContext context) {
    final chartData = _getWeeklyChartData(completions, habit);

    if (chartData.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(child: Text("No hay suficientes datos para el análisis.")),
      );
    }

    // Find the max Y value for dynamic axis scaling
    double maxY = 7; // Default max

    // Determine the first Monday of the habit's creation week for label generation
    DateTime firstMondayOfHabit = habit.creationDate;
    if (firstMondayOfHabit.weekday != DateTime.monday) {
      firstMondayOfHabit = firstMondayOfHabit.subtract(Duration(days: firstMondayOfHabit.weekday - DateTime.monday));
    }

    final List<BarChartGroupData> barGroups = chartData.map((spot) {
      return BarChartGroupData(
        x: spot.x.toInt(),
        barRods: [
          BarChartRodData(
            toY: spot.y,
            color: Color(habit.color),
            width: 8,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          minY: 0,
          maxY: maxY,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: false,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      // Show only integer labels
                      if (value % 1 != 0 && value != 0) return const SizedBox();
                      return Text('${value.toInt()}');
                    })),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    // Dynamically adjust the interval to show ~4 labels
                    interval: (chartData.length / 4).ceilToDouble(),
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= chartData.length) return const Text('');
                      final date = firstMondayOfHabit.add(Duration(days: value.toInt() * 7));
                      return Text(DateFormat('dd\nMMM', 'es').format(date),
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center);
                    })),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false), // Disable touch for simplicity
          alignment: BarChartAlignment.spaceAround,
          groupsSpace: 12,
        ),
      ),
    );
  }
}