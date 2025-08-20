import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:disciplina_visual/models/habit.dart';
import 'package:disciplina_visual/models/completion.dart';
import 'package:disciplina_visual/services/database_helper.dart';

void main() {
  sqfliteFfiInit(); // Initialize FFI for testing

  group('DatabaseHelper', () {
    late DatabaseHelper dbHelper;
    late Database db;

    setUp(() async {
      // Use an in-memory database for testing
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      dbHelper = DatabaseHelper.instance;
      // Inject the in-memory database directly
      dbHelper.setTestDatabase = db; // Use the new setter

      // Create tables
      await dbHelper.createTables(db); // Use the public helper method
    });

    tearDown(() async {
      await db.close();
    });

    test('createHabit and getAllHabits', () async {
      final habit = Habit(name: 'Test Habit', color: 0xFF0000FF, creationDate: DateTime.now());
      final id = await dbHelper.createHabit(habit);
      expect(id, isNotNull);

      final habits = await dbHelper.getAllHabits();
      expect(habits.length, 1);
      expect(habits.first.name, 'Test Habit');
    });

    test('updateHabit', () async {
      final habit = Habit(name: 'Original Name', color: 0xFF0000FF, creationDate: DateTime.now());
      final id = await dbHelper.createHabit(habit);

      final updatedHabit = habit.copyWith(id: id, name: 'Updated Name');
      final rowsAffected = await dbHelper.updateHabit(updatedHabit);
      expect(rowsAffected, 1);

      final habits = await dbHelper.getAllHabits();
      expect(habits.first.name, 'Updated Name');
    });

    test('deleteHabit', () async {
      final habit = Habit(name: 'Habit to Delete', color: 0xFF0000FF, creationDate: DateTime.now());
      final id = await dbHelper.createHabit(habit);

      final rowsAffected = await dbHelper.deleteHabit(id!);
      expect(rowsAffected, 1);

      final habits = await dbHelper.getAllHabits();
      expect(habits.isEmpty, true);
    });

    test('addCompletion and getCompletionsForHabit', () async {
      final habit = Habit(name: 'Habit with Completions', color: 0xFF0000FF, creationDate: DateTime.now());
      final habitId = await dbHelper.createHabit(habit);

      final date1 = DateTime.now();
      final date2 = DateTime.now().subtract(const Duration(days: 1));

      await dbHelper.addCompletion(habitId!, date1);
      await dbHelper.addCompletion(habitId, date2);

      final completions = await dbHelper.getCompletionsForHabit(habitId);
      expect(completions.length, 2);
      // Check if dates are present (order might vary based on orderBy in getCompletionsForHabit) 
      expect(completions.any((c) => c.date.day == date1.day), true);
      expect(completions.any((c) => c.date.day == date2.day), true);
    });

    test('removeCompletion', () async {
      final habit = Habit(name: 'Habit to Remove Completion', color: 0xFF0000FF, creationDate: DateTime.now());
      final habitId = await dbHelper.createHabit(habit);

      final date = DateTime.now();
      await dbHelper.addCompletion(habitId!, date);

      var completions = await dbHelper.getCompletionsForHabit(habitId);
      expect(completions.length, 1);

      await dbHelper.removeCompletion(habitId, date);
      completions = await dbHelper.getCompletionsForHabit(habitId);
      expect(completions.isEmpty, true);
    });
  });
}