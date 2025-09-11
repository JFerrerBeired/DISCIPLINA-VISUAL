import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:disciplina_visual/data/models/completion.dart';
import 'package:disciplina_visual/presentation/utils/date_provider.dart';

List<FlSpot> _getChartData(List<Completion> completions, DateTime simulatedToday) {
  final Map<int, int> weeklyCompletions = {};
  final Map<int, int> totalDaysInWeek = {};
  final Set<DateTime> completedDates = completions
      .map((c) => DateTime(c.date.year, c.date.month, c.date.day))
      .toSet();

  for (int i = 0; i < 8 * 7; i++) {
    final date = simulatedToday.subtract(Duration(days: i));
    final weekIndex = (simulatedToday.difference(date).inDays / 7).floor();
    totalDaysInWeek.update(weekIndex, (value) => value + 1, ifAbsent: () => 1);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (completedDates.contains(normalizedDate)) {
      weeklyCompletions.update(weekIndex, (value) => value + 1, ifAbsent: () => 1);
    }
  }

  final List<FlSpot> spots = [];
  final List<int> weeks = totalDaysInWeek.keys.toList()..sort();
  final reversedWeeks = weeks.reversed.toList();

  for (int i = 0; i < reversedWeeks.length; i++) {
    final week = reversedWeeks[i];
    final completed = weeklyCompletions[week] ?? 0;
    final total = totalDaysInWeek[week] ?? 1;
    final percentage = total > 0 ? (completed / total) * 100 : 0.0;
    spots.add(FlSpot(i.toDouble(), percentage));
  }
  return spots;
}

class AnalysisChart extends StatelessWidget {
  final List<Completion> completions;
  final DateTime simulatedToday;
  final int habitColor;
  final DateProvider dateProvider;

  const AnalysisChart({
    super.key,
    required this.completions,
    required this.simulatedToday,
    required this.habitColor,
    required this.dateProvider,
  });

  @override
  Widget build(BuildContext context) {
    final chartData = _getChartData(completions, simulatedToday);
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) =>
                        Text('${value.toInt()}%'))),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= chartData.length) return const Text('');
                      final date = dateProvider
                          .simulatedToday
                          .subtract(Duration(
                              days: (chartData.length -
                                      1 -
                                      value.toInt()) *
                                  7));
                      return SideTitleWidget(
                        meta: meta,
                        space: 0,
                        child: Text(DateFormat('MMM dd').format(date),
                            style: const TextStyle(fontSize: 10)),
                      );
                    })),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
              show: true,
              border: Border.all(
                  color: const Color(0xff37434d), width: 1)),
          lineBarsData: [
            LineChartBarData(
              spots: chartData,
              isCurved: true,
              color: Color(habitColor),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
