import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:disciplina_visual/data/datasources/local/database_helper.dart';
import 'package:disciplina_visual/data/repositories/habit_repository_impl.dart';
import 'package:disciplina_visual/domain/repositories/habit_repository.dart';
import 'package:disciplina_visual/domain/usecases/add_completion.dart';
import 'package:disciplina_visual/domain/usecases/add_habit.dart';
import 'package:disciplina_visual/domain/usecases/calculate_streak.dart';
import 'package:disciplina_visual/domain/usecases/delete_habit.dart';
import 'package:disciplina_visual/domain/usecases/get_all_habits.dart';
import 'package:disciplina_visual/domain/usecases/get_completions.dart';
import 'package:disciplina_visual/domain/usecases/delete_future_completions.dart';
import 'package:disciplina_visual/domain/usecases/remove_completion.dart';
import 'package:disciplina_visual/domain/usecases/update_habit.dart';
import 'package:disciplina_visual/presentation/providers/create_habit_view_model.dart';
import 'package:disciplina_visual/presentation/providers/dashboard_view_model.dart';
import 'package:disciplina_visual/presentation/providers/habit_detail_view_model.dart';
import 'package:disciplina_visual/presentation/screens/create_habit_screen.dart';
import 'package:disciplina_visual/presentation/screens/dashboard_screen.dart';
import 'package:disciplina_visual/presentation/utils/date_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseHelper>(
          create: (_) => DatabaseHelper.instance,
        ),
        Provider<HabitRepository>(
          create: (context) => HabitRepositoryImpl(
            databaseHelper: context.read<DatabaseHelper>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DateProvider(
            deleteFutureCompletions:
                DeleteFutureCompletions(context.read<HabitRepository>()),
            initialOffsetDays: 60,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DashboardViewModel(
            getAllHabits: GetAllHabits(context.read<HabitRepository>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CreateHabitViewModel(
            addHabit: AddHabit(context.read<HabitRepository>()),
            updateHabit: UpdateHabit(context.read<HabitRepository>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => HabitDetailViewModel(
            getCompletions: GetCompletions(context.read<HabitRepository>()),
            addCompletion: AddCompletion(context.read<HabitRepository>()),
            removeCompletion: RemoveCompletion(context.read<HabitRepository>()),
            deleteHabit: DeleteHabit(context.read<HabitRepository>()),
            calculateStreak: CalculateStreak(),
            dateProvider: context.read<DateProvider>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Disciplina Visual',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const DashboardScreen(),
          '/create': (context) => const CreateHabitScreen(),
        },
      ),
    );
  }
}