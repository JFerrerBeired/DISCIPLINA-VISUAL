# Estrategia de Pruebas

Este documento describe la estrategia de pruebas para la aplicación de seguimiento de hábitos. El objetivo es asegurar la calidad y mantenibilidad del código a través de un conjunto de pruebas automatizadas.

## Resumen

La estrategia de pruebas se basa en la pirámide de pruebas y se divide en tres niveles principales:

1.  **Pruebas Unitarias:** Para la lógica de negocio y los componentes individuales.
2.  **Pruebas de Widgets:** Para los componentes de la interfaz de usuario (UI).
3.  **Pruebas de Integración:** Para los flujos completos de la aplicación.

## Estructura de Directorios

Todas las pruebas se encuentran en el directorio `test/`. La estructura de este directorio debe replicar la estructura del directorio `lib/` para facilitar la localización de las pruebas correspondientes a cada fichero de código fuente.

```
/test
  /data
    /repositories
      habit_repository_impl_test.dart
  /domain
    /usecases
      add_habit_test.dart
  /presentation
    /providers
      dashboard_view_model_test.dart
    /screens
      dashboard_screen_test.dart
```

## Pruebas Unitarias

Las pruebas unitarias se utilizan para verificar la lógica de negocio en los `ViewModels` (o `Providers`) y los `Use Cases`.

-   **Framework:** `flutter_test`
-   **Mocks:** Se utiliza la biblioteca `mockito` para crear dobles de prueba (mocks) de las dependencias. Esto permite aislar el componente que se está probando.
-   **Generación de Mocks:** Los mocks se generan automáticamente ejecutando el siguiente comando:
    ```bash
    flutter pub run build_runner build
    ```

### Ejemplo: `DashboardViewModel`

Las pruebas para `DashboardViewModel` (`test/presentation/providers/dashboard_view_model_test.dart`) demuestran cómo se mockea el `GetAllHabits` use case para probar el `ViewModel` de forma aislada, verificando que el estado (`isLoading`, `habits`, `error`) se actualiza correctamente.

## Pruebas de Widgets

Las pruebas de widgets se utilizan para verificar que los componentes de la UI se renderizan correctamente y responden a las interacciones del usuario como se espera.

-   **Framework:** `flutter_test`
-   **Enfoque:** Se prueban los widgets de forma individual o como parte de una pantalla. Se utiliza `WidgetTester` para interactuar con los widgets y hacer aserciones sobre su estado.

### Ejemplo: `DashboardScreen`

La prueba de humo en `test/widget_test.dart` es un ejemplo de una prueba de widget simple que verifica que la `DashboardScreen` se construye y muestra su título sin errores.

## Pruebas de Integración

Actualmente, no hay pruebas de integración en el proyecto. Estas pruebas son un área de mejora y deberían añadirse para verificar los flujos completos de la aplicación, desde la interacción con la UI hasta la base de datos.

## Cobertura de Pruebas

El objetivo es mantener un alto nivel de cobertura de pruebas. Las áreas críticas de la aplicación, como la lógica de dominio y la gestión de estado, deben tener una cobertura cercana al 100%.

Se pueden generar informes de cobertura con el siguiente comando:

```bash
flutter test --coverage
```
