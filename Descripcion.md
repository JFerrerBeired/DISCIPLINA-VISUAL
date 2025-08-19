### **Documento de Diseño y Especificación Funcional: "Disciplina Visual"**

#### **1. Concepto Central y Propuesta de Valor Única (PVU)**

"Disciplina Visual" es una aplicación de seguimiento de hábitos para Android, diseñada para el individuo auto-motivado que valora la consistencia, la disciplina y el análisis de datos. Su propósito no es entretener, sino funcionar como un espejo claro y honesto del compromiso del usuario consigo mismo.

La motivación se genera a través de la visualización minimalista de datos, la satisfacción de mantener rachas y el análisis de tendencias de consistencia a lo largo del tiempo.

#### **2. Flujo Principal del Usuario**

1.  **Apertura Diaria:** El usuario abre la app y es recibido por el **Dashboard**, donde ve una lista clara de los hábitos programados para hoy.
2.  **Registro de Hoy:** Al completar un hábito, realiza un **short-press (toque corto)** en el checkbox junto al nombre del hábito. La interfaz proporciona una respuesta visual inmediata.
3.  **Corrección Rápida:** Si el usuario olvidó registrar un hábito del día anterior, realiza un **long-press (toque largo)** sobre el punto correspondiente a "Ayer" en la micro-visualización de la tarjeta del hábito. El estado se actualiza instantáneamente desde el Dashboard.
4.  **Análisis Profundo:** Para explorar la historia de un hábito, el usuario pulsa en cualquier parte de la tarjeta del hábito. Esto le lleva a la **Pantalla de Detalles**.
5.  **Exploración Histórica y Edición:** En la Pantalla de Detalles, el usuario explora su progreso y, si necesita editar el historial, activa el **Modo Edición** para realizar cambios de forma segura y confirmada.
6.  **Gestión de Hábitos:** El usuario puede crear nuevos hábitos desde el Dashboard o editar y eliminar los existentes desde la Pantalla de Detalles.

#### **3. Descripción Detallada de Pantallas y Componentes**

##### **A. Pantalla Principal (Dashboard)**

Es el centro de mando operativo de la aplicación.

*   **Estructura:** Una lista vertical y desplazable de "Tarjetas de Hábito" (`HabitCard`).
*   **Componente Flotante:** Un **Botón de Acción Flotante (+)** en la esquina inferior derecha que inicia el flujo de creación de un nuevo hábito.
*   **Componente Clave: `HabitCard`**
    *   **Zona Izquierda (Acción de Hoy):**
        *   **Checkbox:** Círculo para marcar el hábito de hoy. **Interacción:** `Short-press` para cambiar el estado.
        *   **Nombre del Hábito:** Texto claro y legible.
    *   **Zona Derecha (Progreso y Edición Rápida):**
        *   **"Puntos de Actividad Reciente":** Fila de 5 a 7 puntos que representan los últimos días.
        *   **Interacción:** Un `long-press` sobre cualquiera de estos puntos permite marcar/desmarcar el hábito para ese día específico.

##### **B. Pantalla de Detalles del Hábito**

El santuario analítico para cada hábito individual.

*   **Cabecera:** Muestra el nombre del hábito y un **menú (icono de tres puntos)** que da acceso a las acciones de "Editar" y "Eliminar".
*   **Secciones:** Indicadores Clave (Rachas), Heatmap Histórico Interactivo (con Modo Edición), Análisis de Tendencia (Gráfico) e Historial de Rachas.

#### **4. Gestión de Hábitos: Creación, Edición y Eliminación**

Este apartado detalla el ciclo de vida completo de un hábito dentro de la aplicación.

##### **A. Creación de un Nuevo Hábito**

*   **Punto de Entrada:** El usuario pulsa el Botón de Acción Flotante (+) en el Dashboard.
*   **Flujo:**
    1.  Se navega a la **Pantalla de Creación de Hábito**.
    2.  Esta pantalla contiene un formulario simple con dos campos:
        *   **Nombre del Hábito:** Un campo de texto obligatorio.
        *   **Selector de Color:** Una paleta o cuadrícula de colores predefinidos para que el usuario elija uno, permitiendo la personalización visual.
    3.  El usuario rellena los datos y pulsa el botón "Guardar".
    4.  Tras guardar, la aplicación navega automáticamente de vuelta al Dashboard, donde la nueva tarjeta del hábito aparece al final de la lista, lista para ser registrada.

##### **B. Edición de un Hábito**

*   **Punto de Entrada:** Desde la Pantalla de Detalles de un hábito, el usuario pulsa el menú de tres puntos y selecciona la opción "Editar".
*   **Flujo:**
    1.  Se navega a la misma pantalla utilizada para la creación, pero esta vez los campos ya están rellenos con el nombre y el color actuales del hábito.
    2.  El usuario puede modificar el nombre y/o el color.
    3.  Al pulsar "Guardar", los cambios se aplican al hábito existente y se regresa a la Pantalla de Detalles, que ahora reflejará la nueva información.

##### **C. Eliminación de un Hábito**

*   **Punto de Entrada:** Desde la Pantalla de Detalles de un hábito, el usuario pulsa el menú de tres puntos y selecciona la opción "Eliminar".
*   **Flujo:**
    1.  Al seleccionar "Eliminar", se muestra una **ventana emergente de confirmación** para prevenir la eliminación accidental.
    2.  El mensaje será claro y directo: "¿Estás seguro de que quieres eliminar '[Nombre del Hábito]'? Se borrará todo su historial de forma permanente. Esta acción no se puede deshacer."
    3.  La ventana tendrá dos opciones: `Cancelar` y `Eliminar`.
    4.  Si el usuario confirma, el hábito y todos sus registros de cumplimiento asociados son eliminados de la base de datos. La aplicación navega de vuelta al Dashboard, donde la tarjeta del hábito ha desaparecido.

#### **5. Modelo de Datos Simplificado**

*   **`Habit`:** Contiene `id`, `name`, `color`, `creationDate`.
*   **`Completion`:** Contiene `id`, `habitId` (para vincularlo a un hábito), y `date` (solo la fecha, la hora es irrelevante).
