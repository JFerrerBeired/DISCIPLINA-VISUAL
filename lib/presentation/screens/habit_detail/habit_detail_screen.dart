import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/presentation/providers/habit_detail_view_model.dart';
import 'package:disciplina_visual/presentation/screens/create_habit_screen.dart';

import 'widgets/analysis_chart.dart';
import 'widgets/habit_heatmap.dart';
import 'widgets/streak_metrics.dart';

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
    _viewModel.loadCompletions(widget.habit.id!, _displayHabit);
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
    DateTime date,
    bool isCurrentlyCompleted,
  ) async {
    final action = isCurrentlyCompleted ? "desmarcar" : "marcar";
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Editar ${_displayHabit.name}"),
          content: Text(
            "¿Deseas $action este hábito para el día ${date.day}/${date.month}?",
          ),
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
            "¿Estás seguro de que deseas eliminar el hábito '${_displayHabit.name}'? Esta acción es irreversible y eliminará todos sus datos de completado.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.red),
              ),
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
                      color: Color(_displayHabit.color),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('No hay datos de completado para este hábito.'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            key: const PageStorageKey<String>('habitDetail'),
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
                      color: Color(_displayHabit.color),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                StreakMetrics(streak: viewModel.streak),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Actividad Reciente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                HabitHeatmap(
                  habit: _displayHabit,
                  completions: viewModel.completions,
                  simulatedToday: viewModel.dateProvider.simulatedToday,
                  isEditing: _isEditingHeatmap,
                  onCellTap: _handleHeatmapCellTap,
                  scrollController: _scrollController,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Gráfico de Análisis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                AnalysisChart(
                  chartData: viewModel.chartData,
                  habitColor: _displayHabit.color,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
