import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import '../models/habit.dart';
import '../models/completion.dart';
import '../services/database_helper.dart';
import '../utils/date_provider.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late Future<List<Completion>> _completionsFuture;
  late DateProvider _dateProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _dateProvider = Provider.of<DateProvider>(context, listen: false);
    _dateProvider.addListener(_loadCompletions);
    _loadCompletions();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 50)); // Pequeño retraso para asegurar el layout
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _dateProvider.removeListener(_loadCompletions);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCompletions() async {
    setState(() {
      _completionsFuture = DatabaseHelper.instance.getCompletionsForHabit(widget.habit.id!); 
    });
  }

  /// Calcula y devuelve una lista de todas las rachas pasadas.
  List<int> _calculatePastStreaks(List<Completion> completions) {
    if (completions.isEmpty) return [];

    final List<int> pastStreaks = [];
    // Ordenar las completaciones por fecha ascendente
    completions.sort((a, b) => a.date.compareTo(b.date));

    int currentStreak = 0;
    for (int i = 0; i < completions.length; i++) {
      if (i == 0) {
        currentStreak = 1;
      } else {
        final Duration difference = completions[i].date.difference(completions[i-1].date);
        if (difference.inDays == 1) {
          currentStreak++;
        } else if (difference.inDays > 1) {
          // Racha rota, guardar la anterior y empezar una nueva
          pastStreaks.add(currentStreak);
          currentStreak = 1;
        }
      }
    }
    // Añadir la última racha si existe
    if (currentStreak > 0) {
      pastStreaks.add(currentStreak);
    }
    return pastStreaks;
  }

  /// Genera los datos para el gráfico de análisis.
  /// Calcula el porcentaje de completado semanal.
  List<FlSpot> _getChartData(List<Completion> completions, DateTime simulatedToday) {
    final Map<int, int> weeklyCompletions = {}; // Week index -> number of completions
    final Map<int, int> totalDaysInWeek = {}; // Week index -> total days in week

    // Normalizar completados a inicio de día
    final Set<DateTime> completedDates = completions.map((c) =>
        DateTime(c.date.year, c.date.month, c.date.day)).toSet();

    // Considerar las últimas 8 semanas para el gráfico
    for (int i = 0; i < 8 * 7; i++) { // 8 semanas * 7 días/semana
      final date = simulatedToday.subtract(Duration(days: i));
      // Calculate a simple week index relative to simulatedToday
      // Week 0 is the current week (days 0-6 from simulatedToday)
      // Week 1 is the previous week (days 7-13 from simulatedToday), etc.
      final weekIndex = (simulatedToday.difference(date).inDays / 7).floor();

      totalDaysInWeek.update(weekIndex, (value) => value + 1, ifAbsent: () => 1);
      if (completedDates.contains(date)) {
        weeklyCompletions.update(weekIndex, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    final List<FlSpot> spots = [];
    // Get unique week indices and sort them
    final List<int> weeks = totalDaysInWeek.keys.toList()..sort();

    // Iterate through the sorted week indices to create spots
    for (int i = 0; i < weeks.length; i++) {
      final week = weeks[i];
      final completed = weeklyCompletions[week] ?? 0;
      final total = totalDaysInWeek[week] ?? 1; // Avoid division by zero
      final percentage = (completed / total) * 100;
      // The x-value should represent the order of weeks, so 'i' is fine.
      // The y-value is the percentage.
      spots.add(FlSpot(i.toDouble(), percentage));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
        backgroundColor: Color(widget.habit.color),
      ),
      body: FutureBuilder<List<Completion>>(
        future: _completionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.habit.name}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(widget.habit.color)),
                  ),
                  const SizedBox(height: 20),
                  const Text('No hay datos de completado para este hábito.'),
                ],
              ),
            );
          }

          final completions = snapshot.data!;
          final currentStreak = DatabaseHelper.instance.calculateCurrentStreak(completions, _dateProvider.simulatedToday);
          final recordStreak = DatabaseHelper.instance.calculateRecordStreak(completions);
          final pastStreaks = _calculatePastStreaks(completions);
          final chartData = _getChartData(completions, _dateProvider.simulatedToday);

          // Generar los días para el heatmap (últimos 30 días)
          final List<DateTime> days = [];
          for (int i = 29; i >= 0; i--) {
            days.add(_dateProvider.simulatedToday.subtract(Duration(days: i)));
          }

          // Preparar datos para el heatmap transpuesto
          final List<String> weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
          final List<List<DateTime?>> weeksData = [];
          
          // Generar semanas desde la fecha de creación del hábito hasta la fecha simulada actual
          DateTime startDate = widget.habit.creationDate; // Fecha de inicio del heatmap
          DateTime endDate = _dateProvider.simulatedToday; // Fecha fin del heatmap

          // Asegurarse de que startDate sea el inicio de la semana
          startDate = startDate.subtract(Duration(days: startDate.weekday - 1));

          List<DateTime?> currentWeek = List.filled(7, null);

          for (DateTime d = startDate; d.isBefore(endDate.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
            int weekdayIndex = (d.weekday - 1 + 7) % 7; // 0=Lun, 6=Dom
            currentWeek[weekdayIndex] = d;

            if (weekdayIndex == 6) { // Si es domingo, la semana está completa
              weeksData.add(currentWeek);
              currentWeek = List.filled(7, null);
            }
          }
          if (currentWeek.any((element) => element != null)) { // Añadir la última semana si no está vacía
            weeksData.add(currentWeek);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    '${widget.habit.name}',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(widget.habit.color)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricCard('Racha Actual', currentStreak.toString(), Icons.local_fire_department, Colors.orange),
                    _buildMetricCard('Racha Récord', recordStreak.toString(), Icons.star, Colors.amber),
                  ],
                ),
                const SizedBox(height: 30),
                const Text('Actividad Reciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                // Heatmap transpuesto
                Container(
                  height: 310.0, // Altura ajustada para evitar renderflex
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombres de los días de la semana
                      Column(
                        children: [
                          const SizedBox(height: 35), // Espacio para alinear con el indicador de mes
                          ...weekdays.map((dayName) => Container(
                            height: 35,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.all(2.0),
                            child: Text(dayName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          )).toList(),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: weeksData.length, // Número de semanas
                          itemBuilder: (context, weekIndex) {
                            final week = weeksData[weekIndex];
                            // Indicador de mes
                            final firstDayOfThisWeek = week.firstWhere((day) => day != null, orElse: () => null);
                            String monthIndicator = '';
                            if (firstDayOfThisWeek != null) {
                              if (weekIndex == 0) {
                                monthIndicator = DateFormat('MMM').format(firstDayOfThisWeek);
                              } else {
                                // Find the last day of the previous week
                                final previousWeek = weeksData[weekIndex - 1];
                                final lastDayOfPreviousWeek = previousWeek.lastWhere((day) => day != null, orElse: () => null);

                                // Check if any day in the current week is the 1st of a month,
                                // and that month is different from the previous month
                                bool foundNewMonthFirstDay = false;
                                for (DateTime? dayInCurrentWeek in week) {
                                  if (dayInCurrentWeek != null && dayInCurrentWeek.day == 1) {
                                    if (lastDayOfPreviousWeek != null && dayInCurrentWeek.month != lastDayOfPreviousWeek.month) {
                                      monthIndicator = DateFormat('MMM').format(dayInCurrentWeek);
                                      foundNewMonthFirstDay = true;
                                      break;
                                    }
                                  }
                                }

                                // If no 1st of a new month was found in this week,
                                // but the month changed between the first day of this week and the last day of the previous week
                                if (!foundNewMonthFirstDay && lastDayOfPreviousWeek != null && firstDayOfThisWeek.month != lastDayOfPreviousWeek.month) {
                                  monthIndicator = DateFormat('MMM').format(firstDayOfThisWeek);
                                }
                              }
                            }

                            return Column(
                              children: [
                                Container(
                                  width: 35, // Ancho de la columna de la semana
                                  height: 35,
                                  alignment: Alignment.center,
                                  child: Text(monthIndicator, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ),
                                ...week.map((day) {
                                  final isCompleted = day != null && completions.any(
                                    (c) => c.date.year == day.year &&
                                           c.date.month == day.month &&
                                           c.date.day == day.day,
                                  );
                                  return Container(
                                    width: 35,
                                    height: 35,
                                    margin: const EdgeInsets.all(2.0),
                                    decoration: BoxDecoration(
                                      color: day == null ? Colors.transparent : (isCompleted ? Color(widget.habit.color) : Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: day == null ? null : Center(
                                      child: Text(
                                        '${day.day}',
                                        style: TextStyle(
                                          color: isCompleted ? Colors.white : Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Gráfico de Análisis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
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
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text('${value.toInt()}%'))),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) {
                          // Asumiendo que value es el índice de la semana
                          final date = _dateProvider.simulatedToday.subtract(Duration(days: (chartData.length - 1 - value.toInt()) * 7));
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(DateFormat('MMM dd').format(date), style: const TextStyle(fontSize: 10)),
                          );
                        })),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData,
                          isCurved: true,
                          color: Color(widget.habit.color),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Historial de Rachas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  height: pastStreaks.isEmpty ? 50 : pastStreaks.length * 50.0, // Altura dinámica
                  child: pastStreaks.isEmpty
                      ? const Center(child: Text('No hay rachas pasadas.'))
                      : ListView.builder(
                          itemCount: pastStreaks.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text('Racha: ${pastStreaks[index]} días'),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}