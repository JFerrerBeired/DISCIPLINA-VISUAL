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
  static Database? _database;

  /// Getter para la base de datos.
  ///
  /// Si la base de datos no ha sido inicializada, llama a _initDB.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Inicializa la base de datos.
  ///
  /// Obtiene la ruta y abre la conexión. Si la base de datos no existe,
  /// la crea llamando a _onCreate.
  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'disciplina_visual.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Método llamado cuando la base de datos es creada por primera vez.
  ///
  /// Aquí se define el esquema inicial de la base de datos (creación de tablas).
  Future<void> _onCreate(Database db, int version) async {
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

  /// Inserta un nuevo hábito en la base de datos.
  Future<int> createHabit(Habit habit) async {
    final db = await instance.database;
    return await db.insert('habits', habit.toMap());
  }

  /// Recupera todos los hábitos de la base de datos.
  Future<List<Habit>> getAllHabits() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('habits');

    // Convierte la lista de Maps en una lista de Habits.
    return List.generate(maps.length, (i) {
      return Habit.fromMap(maps[i]);
    });
  }

  /// Añade un registro de completado para un hábito en una fecha específica.
  Future<void> addCompletion(int habitId, DateTime date) async {
    final db = await instance.database;
    await db.insert(
      'completions',
      Completion(habitId: habitId, date: date).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Reemplaza si ya existe
    );
  }

  /// Elimina un registro de completado para un hábito en una fecha específica.
  Future<void> removeCompletion(int habitId, DateTime date) async {
    final db = await instance.database;
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
    final db = await instance.database;
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

  /// Elimina todos los hábitos y sus completados asociados.
  /// Útil para pruebas o reseteo de datos.
  Future<void> deleteAllHabits() async {
    final db = await instance.database;
    await db.delete('habits');
    await db.delete('completions'); // También borramos los completados asociados
  }
}