---

### **Roadmap Técnico Iterativo: "Disciplina Visual"**

**Instrucciones:**
Actualiza el estado de cada checkpoint a medida que avanzas. No pases al siguiente hasta que la verificación del actual sea 100% satisfactoria.

---

#### **Checkpoint 1: Fundación del Proyecto y Dependencias**

*   `[x] Status: Completado`
*   **Objetivo:** Crear el proyecto base de Flutter, configurar el entorno y añadir todas las dependencias necesarias para evitar tener que hacerlo a mitad del desarrollo.
*   **Tareas Técnicas:**
    1.  Crear el nuevo proyecto Flutter: `flutter create disciplina_visual`.
    2.  Limpiar el `main.dart` del código de ejemplo del contador.
    3.  Editar `pubspec.yaml` y añadir las siguientes dependencias clave:
        *   `sqflite`: Para la base de datos SQL local.
        *   `path_provider`: Para encontrar la ruta correcta donde almacenar la base de datos.
        *   `fl_chart`: Para el gráfico de análisis de tendencia (sparkline).
        *   `intl`: Para formateo de fechas.
    4.  Ejecutar `flutter pub get` para instalar los paquetes.
*   **Verificación:** La aplicación se compila y ejecuta en un emulador o dispositivo físico. Muestra una pantalla en blanco o un "Hola Mundo" simple, sin errores. Las dependencias están instaladas correctamente.

---

#### **Checkpoint 2: Modelo de Datos y Capa de Persistencia**

*   `[x] Status: Completado`
*   **Objetivo:** Definir la estructura de nuestros datos y crear el servicio de base de datos que se encargará de todas las operaciones CRUD (Crear, Leer, Actualizar, Borrar). Esta etapa no tiene UI.
*   **Tareas Técnicas:**
    1.  Crear los archivos de modelo: `models/habit.dart` y `models/completion.dart` con todas sus propiedades (`id`, `name`, `color`, etc.) y métodos `toJson/fromJson`.
    2.  Crear un servicio Singleton `services/database_helper.dart`.
    3.  Implementar el método `initDB()` que crea o abre la base de datos.
    4.  Escribir las funciones SQL para crear las tablas `habits` y `completions`.
    5.  Implementar los métodos asíncronos básicos en el helper:
        *   `Future<int> createHabit(Habit habit)`
        *   `Future<List<Habit>> getAllHabits()`
*   **Verificación:** En `main.dart`, dentro de la función `main`, puedes llamar a tu `DatabaseHelper`, crear un hábito de prueba y luego recuperarlo, imprimiendo el resultado en la consola. La aplicación se ejecuta, no muestra nada en la UI, pero la consola confirma que la base de datos funciona.

---

#### **Checkpoint 3: Esqueleto de la UI y Navegación Básica**

*   `[x] Status: Completado`
*   **Objetivo:** Crear los archivos de las pantallas principales y configurar la navegación entre ellas. Las pantallas estarán vacías o con contenido estático ("placeholders").
*   **Tareas Técnicas:**
    1.  Crear los archivos de las vistas: `screens/dashboard_screen.dart`, `screens/habit_detail_screen.dart`, `screens/create_habit_screen.dart`.
    2.  En `main.dart`, configurar `MaterialApp` y definir las rutas de navegación para estas pantallas.
    3.  En `DashboardScreen`, añadir un `Scaffold` con un `FloatingActionButton` (+).
    4.  Implementar la lógica `onPressed` del botón para que navegue a `CreateHabitScreen`.
    5.  En `DashboardScreen`, añadir un `ListView` con 2 o 3 `ListTile` de datos falsos (hardcodeados). Cada `ListTile` debe ser "tappable" y navegar a `HabitDetailScreen`.
*   **Verificación:** Puedes iniciar la app y ver la lista de hábitos falsos. Puedes pulsar el botón (+) y ser llevado a la pantalla de creación. Puedes pulsar un hábito de la lista y ser llevado a la pantalla de detalles.

---

#### **Checkpoint 4: Visualización Dinámica de Hábitos en el Dashboard**

*   `[x] Status: Completado`
*   **Objetivo:** Conectar la base de datos con el Dashboard para que muestre los hábitos reales en lugar de los datos falsos.
*   **Tareas Técnicas:**
    1.  En `DashboardScreen`, convertir el Widget a un `StatefulWidget`.
    2.  Usar un `FutureBuilder` que llame a `database_helper.getAllHabits()`.
    3.  Dentro del `builder` del `FutureBuilder`, construir el `ListView` usando los datos reales recibidos de la base de datos.
    4.  Diseñar y construir el widget reutilizable `widgets/habit_card.dart` que tomará un objeto `Habit` y mostrará su nombre y el checkbox (por ahora, sin funcionalidad).
*   **Verificación:** Al ejecutar la app, el Dashboard muestra el hábito de prueba que creaste por código en el Checkpoint 2. Si añades otro hábito de prueba en el código, la lista debería mostrar dos.

---

#### **Checkpoint 5: Ciclo Completo de Creación de Hábitos**

*   `[x] Status: Completado`
*   **Objetivo:** Implementar la funcionalidad completa para que un usuario pueda crear un hábito a través de la interfaz y verlo reflejado en el Dashboard.
*   **Tareas Técnicas:**
    1.  En `CreateHabitScreen`, construir el formulario con un `TextFormField` para el nombre y un widget simple para seleccionar el color.
    2.  Implementar la lógica del botón "Guardar":
        *   Recoger los datos del formulario.
        *   Crear un nuevo objeto `Habit`.
        *   Llamar a `database_helper.createHabit()` con el nuevo objeto.
        *   Usar `Navigator.pop(context)` para volver al Dashboard.
    3.  Asegurarse de que el Dashboard se actualice para mostrar el nuevo hábito (puede requerir gestionar el estado o simplemente recargar los datos al volver a la pantalla).
*   **Verificación:** Puedes abrir la app, pulsar (+), crear un hábito llamado "Leer un libro" con color azul, guardarlo, y ver la nueva tarjeta "Leer un libro" aparecer en el Dashboard. Cierra y reabre la app: el hábito debe persistir.

---

#### **Checkpoint 6: Interacción Diaria - Marcar Hábitos**

*   `[x] Status: Completado`
*   **Objetivo:** Implementar la funcionalidad principal de la app: marcar y desmarcar un hábito como completado para el día de hoy.
*   **Tareas Técnicas:**
    1.  En `database_helper.dart`, crear los métodos:
        *   `Future<void> addCompletion(int habitId, DateTime date)`
        *   `Future<void> removeCompletion(int habitId, DateTime date)`
        *   `Future<List<Completion>> getCompletionsForHabit(int habitId)`
    2.  En el widget `HabitCard`, hacer que el `Checkbox` sea funcional (`onChanged`).
    3.  La lógica de `onChanged` llamará al método `addCompletion` o `removeCompletion` correspondiente.
    4.  Implementar la lógica de los "Puntos de Actividad Reciente". Esta parte de la tarjeta deberá obtener los cumplimientos de los últimos 7 días y colorear los puntos adecuadamente.
*   **Verificación:** En el Dashboard, puedes marcar un hábito. El checkbox se actualiza y el punto de "Hoy" se colorea. Puedes desmarcarlo. Al cerrar y reabrir la app, el estado de marcado se conserva.

---

#### **Checkpoint 7: Implementación de la Pantalla de Detalles**

*   `[ ] Status: Pendiente`
*   **Objetivo:** Construir y poblar la Pantalla de Detalles con todos sus componentes visuales y datos reales.
*   **Tareas Técnicas:**
    1.  Pasar el `Habit` seleccionado a `HabitDetailScreen` durante la navegación.
    2.  Calcular y mostrar las métricas clave: **Racha Actual** y **Racha Récord**. Esto requiere escribir funciones de lógica pura que procesen la lista de fechas de cumplimiento.
    3.  Implementar el **Heatmap**: usa un `GridView` para construir el calendario. Pinta cada celda basándose en si existe un `Completion` para esa fecha.
    4.  Implementar el **Gráfico de Análisis**: usa `fl_chart` para visualizar la media móvil. Primero, hazlo funcionar con la vista semanal.
    5.  Implementar el **Historial de Rachas**: escribe la lógica para calcular todas las rachas pasadas y muéstralas en un `ListView`.
*   **Verificación:** Al navegar a la pantalla de detalles de un hábito, puedes ver sus rachas correctas, un heatmap que refleja los días que lo has marcado, y un gráfico que muestra alguna tendencia. Todos los datos son reales y se corresponden con tus acciones.

---

#### **Checkpoint 8: Interacciones Avanzadas y Edición**

*   `[ ] Status: Pendiente`
*   **Objetivo:** Añadir las funcionalidades de edición más complejas que diseñamos para mejorar la UX.
*   **Tareas Técnicas:**
    1.  En `HabitCard`, implementar el `onLongPress` en los "Puntos de Actividad Reciente" para permitir la edición rápida de días pasados desde el Dashboard.
    2.  En `HabitDetailScreen`, implementar el sistema de **Modo Edición** para el heatmap:
        *   Añadir un `bool isEditing` en el estado del widget.
        *   El botón ✏️ cambia el estado de `isEditing`.
        *   El `onTap` de las celdas del heatmap solo funciona si `isEditing` es `true`.
        *   Implementar el `AlertDialog` de confirmación antes de modificar un dato.
    3.  Implementar el ciclo completo de **Editar y Eliminar Hábito** desde el menú de tres puntos en la Pantalla de Detalles.
*   **Verificación:** Puedes editar un día pasado con un toque largo en el Dashboard. Puedes entrar en modo edición en el heatmap, cambiar un día de hace dos semanas (con confirmación), y ver todas las estadísticas recalcularse correctamente. Puedes cambiar el nombre de un hábito y eliminarlo permanentemente.