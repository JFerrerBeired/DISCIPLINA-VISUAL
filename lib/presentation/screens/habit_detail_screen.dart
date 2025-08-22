import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/presentation/providers/habit_detail_view_model.dart';
import 'package:disciplina_visual/presentation/screens/create_habit_screen.dart';
import 'package:disciplina_visual/presentation/utils/date_provider.dart';
import 'package:disciplina_visual/data/models/completion.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late HabitDetailViewModel _viewModel;
  late ScrollController _scrollController;
  bool _isEditingHeatmap = false;
  late Habit _displayHabit;

  @override
  void initState() {
    super.initState();
    _displayHabit = widget.habit;
    _viewModel = Provider.of<HabitDetailViewModel>(context, listen: false);
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompletions();
      _scrollToMaxExtent();
    });
    _viewModel.addListener(_onViewModelUpdated);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelUpdated);
    _scrollController.dispose();
    super.dispose();
  }

  void _onViewModelUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  void _loadCompletions() {
    _viewModel.loadCompletions(widget.habit.id!);
  }

  void _scrollToMaxExtent() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _handleHeatmapCellTap(
      DateTime date, bool isCurrentlyCompleted) async {
    final action = isCurrentlyCompleted ? "desmarcar" : "marcar";
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Editar ${_displayHabit.name}"),
          content: Text(
              "¿Deseas $action este hábito para el día ${date.day}/${date.month}?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(action == "desmarcar" ? "Desmarcar" : "Marcar"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (isCurrentlyCompleted) {
        await _viewModel.removeCompletionForHabit(widget.habit.id!, date);
      } else {
        await _viewModel.addCompletionForHabit(widget.habit.id!, date);
      }
    }
  }

  Future<void> _editHabit() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateHabitScreen(habit: _displayHabit),
      ),
    );

    if (result == true) {
      // Habit was updated, so we reload.
      // A better approach would be to get the updated habit back and update _displayHabit
      _loadCompletions();
    }
  }

  Future<void> _deleteHabit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Eliminar Hábito"),
          content: Text(
              "¿Estás seguro de que deseas eliminar el hábito '${_displayHabit.name}'? Esta acción es irreversible y eliminará todos sus datos de completado."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _viewModel.deleteHabitById(widget.habit.id!);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_displayHabit.name),
        backgroundColor: Color(_displayHabit.color),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _editHabit();
              } else if (value == 'delete') {
                _deleteHabit();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Editar Hábito'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Eliminar Hábito'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<HabitDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text('Error: ${viewModel.error}'));
          }
          if (viewModel.completions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _displayHabit.name,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(_displayHabit.color)),
                  ),
                  const SizedBox(height: 20),
                  const Text('No hay datos de completado para este hábito.'),
                ],
              ),
            );
          }

          final completions = viewModel.completions;
          final streak = viewModel.streak;
          final chartData = _getChartData(
              completions, viewModel.dateProvider.simulatedToday);

          final List<String> weekdays = [
            'Lun',
            'Mar',
            'Mié',
            'Jue',
            'Vie',
            'Sáb',
            'Dom'
          ];
          final List<List<DateTime?>> weeksData = [];
          DateTime startDate = _displayHabit.creationDate;
          DateTime endDate = viewModel.dateProvider.simulatedToday;
          startDate = startDate.subtract(Duration(days: startDate.weekday - 1));
          List<DateTime?> currentWeek = List.filled(7, null);

          for (DateTime d = startDate;
              d.isBefore(endDate.add(const Duration(days: 1)));
              d = d.add(const Duration(days: 1))) {
            int weekdayIndex = (d.weekday - 1 + 7) % 7;
            currentWeek[weekdayIndex] = d;

            if (weekdayIndex == 6) {
              weeksData.add(currentWeek);
              currentWeek = List.filled(7, null);
            }
          }
          if (currentWeek.any((element) => element != null)) {
            weeksData.add(currentWeek);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    _displayHabit.name,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(_displayHabit.color)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricCard('Racha Actual',
                        streak?.current.toString() ?? '0', Icons.local_fire_department, Colors.orange),
                    _buildMetricCard('Racha Récord',
                        streak?.record.toString() ?? '0', Icons.star, Colors.amber),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Actividad Reciente',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(_isEditingHeatmap ? Icons.check : Icons.edit),
                      onPressed: () {
                        setState(() {
                          _isEditingHeatmap = !_isEditingHeatmap;
                        });
                        if (!_isEditingHeatmap) {
                          _loadCompletions();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 310.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 35),
                          ...weekdays
                              .map((dayName) => Container(
                                    height: 35,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.all(2.0),
                                    child: Text(dayName,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ))
                              .toList(),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: weeksData.length,
                          itemBuilder: (context, weekIndex) {
                            final week = weeksData[weekIndex];
                            final firstDayOfThisWeek = week.firstWhere(
                                (day) => day != null,
                                orElse: () => null);
                            String monthIndicator = '';
                            if (firstDayOfThisWeek != null) {
                              if (weekIndex == 0) {
                                monthIndicator =
                                    DateFormat('MMM').format(firstDayOfThisWeek);
                              } else {
                                final previousWeek = weeksData[weekIndex - 1];
                                final lastDayOfPreviousWeek =
                                    previousWeek.lastWhere((day) => day != null,
                                        orElse: () => null);
                                bool foundNewMonthFirstDay = false;
                                for (DateTime? dayInCurrentWeek in week) {
                                  if (dayInCurrentWeek != null &&
                                      dayInCurrentWeek.day == 1) {
                                    if (lastDayOfPreviousWeek != null &&
                                        dayInCurrentWeek.month !=
                                            lastDayOfPreviousWeek.month) {
                                      monthIndicator = DateFormat('MMM')
                                          .format(dayInCurrentWeek);
                                      foundNewMonthFirstDay = true;
                                      break;
                                    }
                                  }
                                }
                                if (!foundNewMonthFirstDay &&
                                    lastDayOfPreviousWeek != null &&
                                    firstDayOfThisWeek.month !=
                                        lastDayOfPreviousWeek.month) {
                                  monthIndicator = DateFormat('MMM')
                                      .format(firstDayOfThisWeek);
                                }
                              }
                            }
                            return Column(
                              children: [
                                Container(
                                  width: 35,
                                  height: 35,
                                  alignment: Alignment.center,
                                  child: Text(monthIndicator,
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.grey)),
                                ),
                                ...week.map((day) {
                                  final isCompleted = day != null &&
                                      completions.any((c) =>
                                          c.date.year == day.year &&
                                          c.date.month == day.month &&
                                          c.date.day == day.day);
                                  return GestureDetector(
                                    onTap: day == null || !_isEditingHeatmap
                                        ? null
                                        : () =>
                                            _handleHeatmapCellTap(day, isCompleted),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      margin: const EdgeInsets.all(2.0),
                                      decoration: BoxDecoration(
                                        color: day == null
                                            ? Colors.transparent
                                            : (isCompleted
                                                ? Color(_displayHabit.color)
                                                : Colors.grey.shade200),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      child: day == null
                                          ? null
                                          : Center(
                                              child: Text(
                                                '${day.day}',
                                                style: TextStyle(
                                                  color: isCompleted
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize: 12,
                                                ),
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
                const Text('Gráfico de Análisis',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                  final date = viewModel.dateProvider
                                      .simulatedToday
                                      .subtract(Duration(
                                          days: (chartData.length -
                                                  1 -
                                                  value.toInt()) *
                                              7));
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
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
                          color: Color(_displayHabit.color),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<FlSpot> _getChartData(
      List<Completion> completions, DateTime simulatedToday) {
    final Map<int, int> weeklyCompletions = {};
    final Map<int, int> totalDaysInWeek = {};
    final Set<DateTime> completedDates = completions
        .map((c) => DateTime(c.date.year, c.date.month, c.date.day))
        .toSet();

    for (int i = 0; i < 8 * 7; i++) {
      final date = simulatedToday.subtract(Duration(days: i));
      final weekIndex = (simulatedToday.difference(date).inDays / 7).floor();
      totalDaysInWeek.update(weekIndex, (value) => value + 1,
          ifAbsent: () => 1);
      if (completedDates.contains(date)) {
        weeklyCompletions.update(weekIndex, (value) => value + 1,
            ifAbsent: () => 1);
      }
    }

    final List<FlSpot> spots = [];
    final List<int> weeks = totalDaysInWeek.keys.toList()..sort();
    for (int i = 0; i < weeks.length; i++) {
      final week = weeks[i];
      final completed = weeklyCompletions[week] ?? 0;
      final total = totalDaysInWeek[week] ?? 1;
      final percentage = (completed / total) * 100;
      spots.add(FlSpot(i.toDouble(), percentage));
    }
    return spots;
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}