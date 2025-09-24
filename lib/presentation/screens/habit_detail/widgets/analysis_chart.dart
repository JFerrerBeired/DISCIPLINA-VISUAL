import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:disciplina_visual/domain/entities/chart_data_point.dart'; // New import

class AnalysisChart extends StatelessWidget {
  final List<ChartDataPoint> chartData; // Changed
  final int habitColor; // Changed

  const AnalysisChart({
    super.key,
    required this.chartData, // Changed
    required this.habitColor, // Changed
  });

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(
          child: Text("No hay suficientes datos para el análisis."),
        ),
      );
    }

    // Find the max Y value for dynamic axis scaling
    double maxY = 7; // Default max
    if (chartData.isNotEmpty) {
      maxY = chartData.map((point) => point.y).reduce((a, b) => a > b ? a : b);
      if (maxY < 7) maxY = 7; // Ensure a minimum max Y
      maxY = (maxY * 1.2).ceilToDouble(); // Add some padding
    }


    // Determine the first date for label generation from the chartData
    // Assuming chartData is sorted by date
    final DateTime firstDateForLabels = chartData.first.date;


    final List<BarChartGroupData> barGroups = chartData.map((dataPoint) {
      // Calculate the week index relative to the firstDateForLabels
      // This is needed because fl_chart's BarChartGroupData.x expects an integer index,
      // not a raw timestamp. We're effectively re-indexing the data points.
      final int weekIndex = (dataPoint.date.difference(firstDateForLabels).inDays / 7).floor();

      return BarChartGroupData(
        x: weekIndex, // Use the calculated week index
        barRods: [
          BarChartRodData(
            toY: dataPoint.y,
            color: Color(habitColor),
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
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                // Dynamically adjust the interval to show ~4 labels
                interval: (chartData.length / 4).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= chartData.length) return const Text('');
                  // The 'value' here is the index from fl_chart, which corresponds to our weekIndex
                  // We need to find the corresponding ChartDataPoint based on this index
                  // and then get its original date.
                  final date = chartData[value.toInt()].date;
                  return Text(
                    DateFormat('dd\nMMM', 'es').format(date),
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: false,
          ), // Disable touch for simplicity
          alignment: BarChartAlignment.spaceAround,
          groupsSpace: 12,
        ),
      ),
    );
  }
}
