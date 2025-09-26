import 'dart:io';
import 'package:csv/csv.dart';
import 'package:disciplina_visual/domain/repositories/habit_repository.dart';
import 'package:disciplina_visual/domain/entities/habit.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class ImportHabitsFromCsv {
  final HabitRepository repository;

  ImportHabitsFromCsv(this.repository);

  Future<void> call(String filePath) async {
    final file = File(filePath);
    final csvString = await file.readAsString();
    final fields = const CsvToListConverter().convert(csvString);

    if (fields.isEmpty) {
      return;
    }

    await repository.clearAllData();

    final header = fields[0];
    final habitNames = header.sublist(1);
    final habits = <Habit>[];
    final random = Random();

    for (final habitName in habitNames) {
      final habit = Habit(
        id:null,
        name: habitName,
        color: Color((random.nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0).value,
        creationDate: DateTime.now(),
      );
      habits.add(habit);
    }

    final habitIds = await repository.addHabits(habits);

    for (var i = 1; i < fields.length; i++) {
      final row = fields[i];
      final date = DateTime.parse(row[0]);
      for (var j = 1; j < row.length; j++) {
        if (row[j] == 2) {
          await repository.addCompletion(habitIds[j - 1], date);
        }
      }
    }
  }
}