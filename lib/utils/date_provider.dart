import 'package:flutter/material.dart';
import '../services/database_helper.dart';

/// Provee la fecha actual simulada para la aplicación.
///
/// Permite avanzar o resetear la fecha para propósitos de prueba
/// y asegura la consistencia de los datos en la base de datos.
class DateProvider with ChangeNotifier {
  DateTime _simulatedToday = DateTime.now();
  int _dayOffset = 0;

  DateTime get simulatedToday => _simulatedToday;
  int get dayOffset => _dayOffset;

  /// Avanza la fecha simulada un día.
  void advanceDay() {
    _simulatedToday = _simulatedToday.add(const Duration(days: 1));
    _dayOffset++;
    notifyListeners();
  }

  /// Resetea la fecha simulada a la fecha real actual.
  ///
  /// También elimina cualquier registro de completado que haya sido
  /// añadido para fechas futuras (simuladas) en la base de datos.
  Future<void> resetDay() async {
    _simulatedToday = DateTime.now();
    _dayOffset = 0;
    // Eliminar completados futuros de la base de datos
    await DatabaseHelper.instance.deleteFutureCompletions(DateTime.now());
    notifyListeners();
  }
}
