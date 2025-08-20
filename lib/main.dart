import 'package:flutter/material.dart';
import 'package:disciplina_visual/screens/dashboard_screen.dart';
import 'package:disciplina_visual/screens/create_habit_screen.dart';
import 'package:disciplina_visual/screens/habit_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disciplina Visual',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/create': (context) => const CreateHabitScreen(),
        '/details': (context) => const HabitDetailScreen(),
      },
    );
  }
}