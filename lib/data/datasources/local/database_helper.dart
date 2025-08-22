import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../models/habit.dart';
import '../../models/completion.dart';

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


  /// NOTE: Función de ayuda para desarrollo.
  ///
  /// Esta función es temporal y solo para fines de desarrollo.
  /// NO LA USES en el flujo normal de la aplicación.
  /// Siéntete libre de modificarla o eliminarla según tus necesidades.
  /// NINGUNA otra funcionalidad debe depender de esta función.
  ///
  /// Inserta un conjunto de hábitos de ejemplo en la base de datos,
  /// incluyendo algunos días de completado para simular historial.
  /// Para asegurar un estado limpio, primero elimina todos los datos existentes.
  /// Útil para poblar la base de datos para pruebas o demostraciones.
  Future<void> insertSeedHabits() async {
    // Primero, borramos todos los datos existentes para asegurar un estado limpio.
    await deleteAllHabits();

    final db = await database;
    final today = DateTime.now();

    // Lista de hábitos de ejemplo con fechas de creación más antiguas
    final List<Habit> seedHabits = [
      Habit(name: 'Leer 30 minutos', color: 0xFF4CAF50, creationDate: today.subtract(const Duration(days: 30))), // Verde
      Habit(name: 'Meditar 10 minutos', color: 0xFF2196F3, creationDate: today.subtract(const Duration(days: 25))), // Azul
      Habit(name: 'Hacer ejercicio', color: 0xFFFF9800, creationDate: today.subtract(const Duration(days: 20))), // Naranja
      Habit(name: 'Beber 2L de agua', color: 0xFF00BCD4, creationDate: today.subtract(const Duration(days: 15))), // Cyan
      Habit(name: 'Estudiar Flutter', color: 0xFF9C27B0, creationDate: today.subtract(const Duration(days: 10))), // Púrpura
      Habit(name: 'Escribir en el diario', color: 0xFF795548, creationDate: today.subtract(const Duration(days: 5))), // Marrón
    ];

    // Días de completado para cada hábito (días atrás desde hoy)
    final Map<String, List<int>> completionDays = {
      'Leer 30 minutos': [1, 2, 3, 5, 6, 8, 10, 12, 15, 16, 17, 20],
      'Meditar 10 minutos': [1, 3, 4, 7, 9, 11, 14, 18],
      'Hacer ejercicio': [2, 4, 6, 8, 10, 12, 14, 16, 18, 19],
      'Beber 2L de agua': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
      'Estudiar Flutter': [1, 5, 8, 9],
      'Escribir en el diario': [3, 4],
    };

    // Inserta cada hábito y sus completados en la base de datos
    for (final habit in seedHabits) {
      final habitId = await createHabit(habit);

      // Añadir completados para el hábito recién creado
      if (completionDays.containsKey(habit.name)) {
        for (final dayAgo in completionDays[habit.name]!) {
          // Asegurarse de que la fecha de completado no sea anterior a la de creación
          final completionDate = today.subtract(Duration(days: dayAgo));
          if (completionDate.isAfter(habit.creationDate)) {
            await addCompletion(habitId, completionDate);
          }
        }
      }
    }
  }
}