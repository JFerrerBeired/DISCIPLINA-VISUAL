import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:disciplina_visual/domain/entities/chart_data_point.dart';

class AnalysisChart extends StatelessWidget {
  final List<ChartDataPoint> chartData;
  final int habitColor;
  final int maxVisibleColumns; // Maximum number of columns to show at once

  const AnalysisChart({
    super.key,
    required this.chartData,
    required this.habitColor,
    this.maxVisibleColumns = 8,
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

    // If we have fewer data points than the max visible columns, we don't need scrolling
    if (chartData.length <= maxVisibleColumns) {
      return _buildFullChart();
    }

    // For scrolling, we'll create a HorizontalScrollView with fixed aspect ratio
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate chart width based on the number of data points, 
          // maintaining the same aspect ratio per bar
          final double singleBarWidth = (constraints.maxWidth - 32) / maxVisibleColumns;
          final double totalChartWidth = singleBarWidth * chartData.length;
          
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: totalChartWidth,
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: _buildFullChart(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFullChart() {
    // Find the max Y value for dynamic axis scaling
    double maxY = 7; // Default max
    if (chartData.isNotEmpty) {
      maxY = chartData.map((point) => point.y).reduce((a, b) => a > b ? a : b);
      if (maxY < 7) maxY = 7; // Ensure a minimum max Y
      maxY = (maxY * 1.2).ceilToDouble(); // Add some padding
    }

    // Create bar groups with simple sequential indices 
    final List<BarChartGroupData> barGroups = chartData.asMap().entries.map((entry) {
      final int index = entry.key;
      final ChartDataPoint dataPoint = entry.value;
      
      return BarChartGroupData(
        x: index, // Use sequential index instead of calculated week index
        barRods: [
          BarChartRodData(
            toY: dataPoint.y,
            color: Color(habitColor),
            width: 20,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      );
    }).toList();

    return BarChart(
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
              // Show labels for all data points but ensure readability
              interval: 1, // Show every label
              getTitlesWidget: (value, meta) {
                // Check if the value corresponds to a valid index in our chartData
                final index = value.toInt();
                if (index < 0 || index >= chartData.length) return const Text('');
                
                final date = chartData[index].date;
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
    );
  }
}