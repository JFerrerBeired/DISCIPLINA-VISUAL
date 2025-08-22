import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplina_visual/presentation/providers/dashboard_view_model.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/domain/repositories/habit_repository.dart';
import 'package:disciplina_visual/domain/usecases/add_completion.dart';
import 'package:disciplina_visual/domain/usecases/calculate_streak.dart';
import 'package:disciplina_visual/domain/usecases/get_completions.dart';
import 'package:disciplina_visual/domain/usecases/remove_completion.dart';
import 'package:disciplina_visual/presentation/providers/habit_card_view_model.dart';
import 'package:disciplina_visual/presentation/widgets/habit_card.dart';
import 'package:disciplina_visual/presentation/utils/date_provider.dart';
import 'package:disciplina_visual/presentation/screens/habit_detail_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DateProvider _dateProvider;

  @override
  void initState() {
    super.initState();
    _dateProvider = Provider.of<DateProvider>(context, listen: false);
    _dateProvider.addListener(_loadHabits);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHabits();
    });
  }

  @override
  void dispose() {
    _dateProvider.removeListener(_loadHabits);
    super.dispose();
  }

  void _loadHabits() {
    Provider.of<DashboardViewModel>(context, listen: false).loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<DateProvider>(
          builder: (context, dateProvider, child) {
            String title = 'Dashboard de Hábitos';
            String dateString =
                DateFormat('dd/MM/yyyy').format(dateProvider.simulatedToday);
            if (dateProvider.dayOffset > 0) {
              title =
                  'Dashboard de Hábitos ($dateString +${dateProvider.dayOffset} días)';
            } else if (dateProvider.dayOffset < 0) {
              title =
                  'Dashboard de Hábitos ($dateString ${dateProvider.dayOffset} días)';
            } else {
              title = 'Dashboard de Hábitos ($dateString)';
            }
            return Text(title);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    _dateProvider.advanceDay();
                    _loadHabits();
                  },
                  icon: const Icon(Icons.fast_forward),
                  tooltip: 'Simular Avance de Día',
                ),
                IconButton(
                  onPressed: () {
                    _dateProvider.resetDay();
                    _loadHabits();
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Resetear Día',
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<DashboardViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (viewModel.error != null) {
                    return Center(child: Text('Error: ${viewModel.error}'));
                  }
                  if (viewModel.habits.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay hábitos todavía. ¡Añade uno con el botón +!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: viewModel.habits.length,
                    itemBuilder: (context, index) {
                      final habit = viewModel.habits[index];
                      return ChangeNotifierProvider(
                        create: (context) => HabitCardViewModel(
                          habit: habit,
                          getCompletions: GetCompletions(
                              context.read<HabitRepository>()),
                          addCompletion: AddCompletion(
                              context.read<HabitRepository>()),
                          removeCompletion: RemoveCompletion(
                              context.read<HabitRepository>()),
                          calculateStreak: CalculateStreak(),
                          dateProvider: context.read<DateProvider>(),
                        ),
                        child: Consumer<HabitCardViewModel>(
                          builder: (context, habitCardViewModel, child) =>
                              HabitCard(
                            viewModel: habitCardViewModel,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HabitDetailScreen(habit: habit),
                                ),
                              ).then((_) => _loadHabits());
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create').then((_) => _loadHabits());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
