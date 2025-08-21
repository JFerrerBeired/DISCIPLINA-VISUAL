import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplina_visual/screens/create_habit_screen.dart'; // Add this line
import '../models/habit.dart';
import '../models/completion.dart';
import '../services/database_helper.dart';
import '../utils/date_provider.dart';
import '../widgets/habit_detail/analysis_chart.dart';
import '../widgets/habit_detail/heatmap.dart';
import '../widgets/habit_detail/streak_history.dart';
import '../widgets/habit_detail/streaks_display.dart';

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
  late Habit _displayHabit; // Add this line

  @override
  void initState() {
    super.initState();
    _displayHabit = widget.habit; // Initialize _displayHabit
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

  /// Maneja el tap en una celda del heatmap en modo edición.
  Future<void> _handleHeatmapCellTap(DateTime date, bool isCurrentlyCompleted) async {
    final action = isCurrentlyCompleted ? "desmarcar" : "marcar";

    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Editar ${widget.habit.name}"),
          content: Text("¿Deseas $action este hábito para el día ${date.day}/${date.month}?",),
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
        await DatabaseHelper.instance.removeCompletion(widget.habit.id!, date);
      } else {
        await DatabaseHelper.instance.addCompletion(widget.habit.id!, date);
      }
      _loadCompletions(); // Recargar datos para actualizar la UI
    }
  }


  /// Navega a la pantalla de edición de hábito.
  Future<void> _editHabit() async {
    final updatedHabit = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateHabitScreen(habit: _displayHabit), // Pass _displayHabit
      ),
    );

    if (updatedHabit != null && updatedHabit is Habit) {
      setState(() {
        _displayHabit = updatedHabit; // Update _displayHabit
      });
      _loadCompletions(); // Reload completions as well, in case habit ID changed (unlikely but good practice)
    }
  }

  /// Muestra un diálogo de confirmación y elimina el hábito si se confirma.
  Future<void> _deleteHabit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Eliminar Hábito"),
          content: Text("¿Estás seguro de que deseas eliminar el hábito '${widget.habit.name}'? Esta acción es irreversible y eliminará todos sus datos de completado."),
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
      await DatabaseHelper.instance.deleteHabit(widget.habit.id!);
      // Volver al Dashboard después de eliminar
      if (mounted) {
        Navigator.of(context).pop(); // Pop HabitDetailScreen
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
                    '${_displayHabit.name}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(_displayHabit.color)),
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
          final pastStreaks = DatabaseHelper.calculatePastStreaks(completions);
          final chartData = DatabaseHelper.getChartData(completions, _dateProvider.simulatedToday);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    '${_displayHabit.name}',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(_displayHabit.color)),
                  ),
                ),
                const SizedBox(height: 20),
                StreaksDisplay(
                  currentStreak: currentStreak,
                  recordStreak: recordStreak,
                ),
                const SizedBox(height: 30),
                Heatmap(
                  habit: _displayHabit,
                  completions: completions,
                  scrollController: _scrollController,
                  simulatedToday: _dateProvider.simulatedToday,
                  onCellTap: _handleHeatmapCellTap,
                  onEditModeToggled: _loadCompletions,
                ),
                const SizedBox(height: 20),
                AnalysisChart(
                  chartData: chartData,
                  habit: _displayHabit,
                  dateProvider: _dateProvider,
                ),
                const SizedBox(height: 20),
                StreakHistory(pastStreaks: pastStreaks),
              ],
            ),
          );
        },
      ),
    );
  }

}