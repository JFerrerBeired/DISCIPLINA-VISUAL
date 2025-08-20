import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/database_helper.dart';
import '../widgets/habit_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Usamos `late` porque inicializaremos la variable en initState.
  late Future<List<Habit>> _habitList;

  @override
  void initState() {
    super.initState();
    // Obtenemos la lista de hábitos al iniciar la pantalla.
    _loadHabits();
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
        title: const Text('Dashboard de Hábitos'),
      ),
      body: Padding(
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