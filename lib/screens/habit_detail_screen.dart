import 'package:flutter/material.dart';

class HabitDetailScreen extends StatefulWidget {
  const HabitDetailScreen({super.key});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Hábito'),
      ),
      body: const Center(
        child: Text('Aquí se mostrarán las estadísticas de un hábito.'),
      ),
    );
  }
}
