import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/habit.dart';
import '../models/completion.dart';

/// Clase Singleton para gestionar la base de datos de la aplicación.
///
/// Se encarga de la inicialización y de proporcionar una instancia única
/// de la base de datos a través de toda la app.
class DatabaseHelper {
  // Hacemos la clase un Singleton.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Única instancia de la base de datos.
  Database? _database; // Removed static

  /// Getter para la base de datos.
  ///
  /// Si la base de datos no ha sido inicializada, llama a _initDB.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Setter para la base de datos (solo para uso en tests).
  set setTestDatabase(Database newDatabase) { // Changed Future<Database> to Database
    _database = newDatabase;
  }

  /// Inicializa la base de datos.
  ///
  /// Obtiene la ruta y abre la conexión. Si la base de datos no existe,
  /// la crea llamando a _onCreateInternal.
  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'disciplina_visual.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateInternal, // Use internal onCreate
    );
  }

  /// Método llamado cuando la base de datos es creada por primera vez.
  ///
  /// Aquí se define el esquema inicial de la base de datos (creación de tablas).
  // Made public for testing purposes
  Future<void> _onCreateInternal(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        creationDate TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE completions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (habitId) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');
  }

  // Public method to create tables for testing
  Future<void> createTables(Database db) async {
    await _onCreateInternal(db, 1);
  }

  /// Inserta un nuevo hábito en la base de datos.
  Future<int> createHabit(Habit habit) async {
    final db = await database;
    return await db.insert('habits', habit.toMap());
  }

  /// Recupera todos los hábitos de la base de datos.
  Future<List<Habit>> getAllHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('habits');

    // Convierte la lista de Maps en una lista de Habits.
    return List.generate(maps.length, (i) {
      return Habit.fromMap(maps[i]);
    });
  }

  /// Añade un registro de completado para un hábito en una fecha específica.
  Future<void> addCompletion(int habitId, DateTime date) async {
    final db = await database;
    await db.insert(
      'completions',
      Completion(habitId: habitId, date: date).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Reemplaza si ya existe
    );
  }

  /// Elimina un registro de completado para un hábito en una fecha específica.
  Future<void> removeCompletion(int habitId, DateTime date) async {
    final db = await database;
    // Normalizamos la fecha para que coincida con cómo la guardamos (solo YYYY-MM-DD)
    final String formattedDate = date.toIso8601String().substring(0, 10);
    await db.delete(
      'completions',
      where: 'habitId = ? AND date = ?',
      whereArgs: [habitId, formattedDate],
    );
  }

  /// Recupera todos los registros de completado para un hábito dado.
  Future<List<Completion>> getCompletionsForHabit(int habitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'completions',
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC', // Ordenamos por fecha descendente
    );

    return List.generate(maps.length, (i) {
      return Completion.fromMap(maps[i]);
    });
  }

  /// Actualiza un hábito existente en la base de datos.
  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  /// Elimina un hábito de la base de datos y sus completados asociados.
  Future<int> deleteHabit(int id) async {
    final db = await database;
    // Eliminar los completados asociados primero (debido a ON DELETE CASCADE, esto podría ser opcional si la FK está bien configurada)
    await db.delete(
      'completions',
      where: 'habitId = ?',
      whereArgs: [id],
    );
    // Eliminar el hábito
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Elimina todos los hábitos y sus completados asociados.
  /// Útil para pruebas o reseteo de datos.
  Future<void> deleteAllHabits() async {
    final db = await database;
    await db.delete('habits');
    await db.delete('completions'); // También borramos los completados asociados
  }

  /// Elimina registros de completado cuya fecha sea posterior a la fecha de corte.
  Future<void> deleteFutureCompletions(DateTime cutoffDate) async {
    final db = await database;
    final String formattedCutoffDate = cutoffDate.toIso8601String().substring(0, 10);
    await db.delete(
      'completions',
      where: 'date > ?',
      whereArgs: [formattedCutoffDate],
    );
  }

  /// Calcula la racha actual de un hábito.
  /// Recibe una lista de completados y la fecha actual de referencia.
  int calculateCurrentStreak(List<Completion> completions, DateTime today) {
    if (completions.isEmpty) return 0;

    // Normalizar todas las fechas de completado al inicio del día para una comparación precisa
    final Set<DateTime> completedDates = completions.map((c) =>
        DateTime(c.date.year, c.date.month, c.date.day)).toSet();

    int streak = 0;
    DateTime checkDate = DateTime(today.year, today.month, today.day); // Empezar desde hoy, normalizado

    // Si el hábito no se completó hoy, la racha actual es 0 a menos que se haya completado ayer
    if (!completedDates.contains(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1)); // Mover a ayer
      if (!completedDates.contains(checkDate)) {
        return 0; // No completado hoy ni ayer, racha 0
      }
    }

    // Iterar hacia atrás desde checkDate (que es hoy o ayer) para encontrar días completados consecutivos.
    while (completedDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Calcula la racha récord de un hábito.
  /// Recibe una lista de completados.
  int calculateRecordStreak(List<Completion> completions) {
    if (completions.isEmpty) return 0;

    int maxStreak = 0;
    int currentStreak = 0;

    // Ordenar las completaciones por fecha ascendente para calcular rachas históricas
    completions.sort((a, b) => a.date.compareTo(b.date));

    // Usar un Set para un acceso rápido a las fechas completadas
    final Set<DateTime> completedDates = completions.map((c) =>
        DateTime(c.date.year, c.date.month, c.date.day)).toSet();

    if (completedDates.isEmpty) return 0;

    // Iterar a través de las fechas completadas para encontrar rachas
    List<DateTime> sortedUniqueDates = completedDates.toList()..sort();

    for (int i = 0; i < sortedUniqueDates.length; i++) {
      if (i == 0) {
        currentStreak = 1;
      } else {
        final Duration difference = sortedUniqueDates[i].difference(sortedUniqueDates[i-1]);
        if (difference.inDays == 1) {
          currentStreak++;
        } else if (difference.inDays > 1) {
          currentStreak = 1;
        }
      }
      if (currentStreak > maxStreak) {
        maxStreak = currentStreak;
      }
    }
    return maxStreak;
  }
}