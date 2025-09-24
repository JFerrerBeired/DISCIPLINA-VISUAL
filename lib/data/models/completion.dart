/// Modelo de datos para un registro de Hábito Completado.
///
/// Representa una única marca de "hecho" en un día específico para un hábito.
class Completion {
  int? id;
  final int habitId; // Clave foránea para enlazar con el Hábito.
  final DateTime date;

  Completion({this.id, required this.habitId, required this.date});

  /// Convierte un objeto [Completion] en un [Map] para la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      // Guardamos solo la fecha, sin la hora, en formato ISO 8601 (YYYY-MM-DD).
      'date': date.toIso8601String().substring(0, 10),
    };
  }

  /// Convierte un [Map] de la base de datos en un objeto [Completion].
  factory Completion.fromMap(Map<String, dynamic> map) {
    return Completion(
      id: map['id'],
      habitId: map['habitId'],
      date: DateTime.parse(map['date']),
    );
  }
}
