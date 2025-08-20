import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplina_visual/screens/dashboard_screen.dart';
import 'package:disciplina_visual/screens/create_habit_screen.dart';
import 'package:disciplina_visual/screens/habit_detail_screen.dart';
import 'package:disciplina_visual/utils/date_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DateProvider(initialOffsetDays: 60),
      child: const MyApp(),
    ),
  );
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
        // La ruta '/details' ya no es necesaria aquí, se navega directamente.
      },
    );
  }
}