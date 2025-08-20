
/// Modelo de datos para un Hábito.
///
/// Representa un único hábito que el usuario desea seguir.
class Habit {
  int? id; // El ID es opcional porque se autogenera en la base de datos.
  String name;
  int color;
  DateTime creationDate;

  Habit({
    this.id,
    required this.name,
    required this.color,
    required this.creationDate,
  });

  /// Convierte un objeto [Habit] en un [Map].
  ///
  /// Útil para insertar/actualizar en la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      // Guardamos la fecha como un String en formato ISO 8601.
      'creationDate': creationDate.toIso8601String(),
    };
  }

  /// Convierte un [Map] (de la base de datos) en un objeto [Habit].
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      // Parseamos el String de la base de datos de vuelta a un DateTime.
      creationDate: DateTime.parse(map['creationDate']),
    );
  }
}
