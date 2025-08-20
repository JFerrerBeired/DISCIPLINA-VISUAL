import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../services/database_helper.dart';
import '../widgets/habit_card.dart';
import '../utils/date_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Habit>> _habitList;
  late DateProvider _dateProvider;

  @override
  void initState() {
    super.initState();
    _dateProvider = Provider.of<DateProvider>(context, listen: false);
    _dateProvider.addListener(_loadHabits);
    _loadHabits();
  }

  @override
  void dispose() {
    _dateProvider.removeListener(_loadHabits);
    super.dispose();
  }

  /// Carga los hábitos desde la base de datos y actualiza el estado.
  void _loadHabits() {
    setState(() {
      _habitList = DatabaseHelper.instance.getAllHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<DateProvider>(
          builder: (context, dateProvider, child) {
            String title = 'Dashboard de Hábitos';
            if (dateProvider.dayOffset > 0) {
              title += ' (+${dateProvider.dayOffset} días)';
            } else if (dateProvider.dayOffset < 0) {
              title += ' (${dateProvider.dayOffset} días)';
            }
            return Text(title);
          },
        ),
      ),
      body: Column(
        children: [
          // Botones temporales para simular el avance de día
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () async {
                    _dateProvider.advanceDay();
                    // Forzar recarga de hábitos para que se actualicen las tarjetas
                    _loadHabits();
                  },
                  icon: const Icon(Icons.fast_forward),
                  tooltip: 'Simular Avance de Día',
                ),
                IconButton(
                  onPressed: () async {
                    await _dateProvider.resetDay();
                    // Forzar recarga de hábitos para que se actualicen las tarjetas
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
              // FutureBuilder se encarga de la UI mientras los datos se cargan.
              child: FutureBuilder<List<Habit>>(
                future: _habitList,
                builder: (context, snapshot) {
                  // Estado 1: Cargando
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Estado 2: Error
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  // Estado 3: Datos cargados, pero la lista está vacía.
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay hábitos todavía. ¡Añade uno con el botón +!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  // Estado 4: Datos cargados y disponibles.
                  final habits = snapshot.data!;
                  return ListView.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      return HabitCard(habit: habits[index]);
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
          // Navegamos a la pantalla de creación. Cuando volvamos,
          // recargamos los hábitos para ver el nuevo.
          Navigator.pushNamed(context, '/create').then((_) => _loadHabits());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}