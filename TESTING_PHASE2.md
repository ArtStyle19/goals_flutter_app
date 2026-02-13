# 🧪 Guía de Pruebas - Fase 2: Offline-First Completo

Esta guía te ayudará a verificar que todas las características de la Fase 2 estén funcionando correctamente antes de iniciar la Fase 3.

---

## 📋 Índice de Pruebas

1. [Caché Local de Goals](#1-caché-local-de-goals)
2. [Caché Local de Calendar](#2-caché-local-de-calendar)
3. [Invalidación Inteligente de Caché](#3-invalidación-inteligente-de-caché)
4. [Timestamps de Sincronización](#4-timestamps-de-sincronización)
5. [Manejo de Errores con Fallback](#5-manejo-de-errores-con-fallback)
6. [Limpieza de Caché en Logout](#6-limpieza-de-caché-en-logout)
7. [Pull-to-Refresh](#7-pull-to-refresh)

---

## 1. Caché Local de Goals

### 1.1 Verificar que los Goals se cachean correctamente

**Pasos:**

1. Inicia sesión en la app
2. Ve a la pantalla de Goals (lista)
3. Espera a que cargue (debe mostrar datos del servidor)
4. Desactiva el WiFi/Datos móviles
5. Cierra la app completamente (swipe up)
6. Abre la app nuevamente
7. Ve a Goals

**✅ Resultado esperado:**

- Los goals deben mostrarse inmediatamente (desde caché local)
- No debe mostrar error de red
- Los datos deben ser los mismos que antes de cerrar la app

### 1.2 Verificar persistencia de un Goal específico

**Pasos:**

1. Con conexión activa, entra a un Goal específico (detalle)
2. Toma nota mental del título/descripción
3. Desactiva conexión
4. Cierra la app
5. Abre la app y entra al mismo Goal

**✅ Resultado esperado:**

- El detalle del goal debe mostrarse sin conexión
- Todos los datos (título, descripción, reglas, etc.) deben estar presentes

### 1.3 Verificar que las reglas de disponibilidad se cachean

**Pasos:**

1. Con conexión, entra a un Goal con reglas de disponibilidad
2. Ve las reglas configuradas (días/horarios)
3. Desactiva conexión
4. Recarga la pantalla (pull-to-refresh)

**✅ Resultado esperado:**

- Las reglas de disponibilidad deben seguir visibles
- No debe desaparecer la información

---

## 2. Caché Local de Calendar

### 2.1 Verificar caché de tareas del calendario

**Pasos:**

1. Ve a la pestaña "Calendar"
2. Espera a que cargue las tareas
3. Desactiva conexión
4. Cambia de mes/semana
5. Vuelve al mes actual

**✅ Resultado esperado:**

- Las tareas deben seguir visibles sin conexión
- La navegación entre fechas debe ser fluida

### 2.2 Verificar caché de "Hoy" (Today)

**Pasos:**

1. Ve a la pestaña "Today"
2. Espera a que cargue las tareas del día
3. Desactiva conexión
4. Cierra y abre la app
5. Ve a "Today"

**✅ Resultado esperado:**

- Las tareas de hoy deben mostrarse inmediatamente
- Debe funcionar completamente offline

### 2.3 Verificar "Próxima tarea" (Next Task)

**Pasos:**

1. Con conexión, ve a Today (muestra la próxima tarea arriba)
2. Desactiva conexión
3. Cierra y abre la app

**✅ Resultado esperado:**

- La próxima tarea debe mostrarse correctamente desde caché

---

## 3. Invalidación Inteligente de Caché

### 3.1 Al borrar un Goal → eliminar tasks huérfanas

**Pasos:**

1. Crea un Goal nuevo con algunas tareas generadas
2. Ve a Calendar y verifica que las tareas aparecen
3. Borra el Goal
4. Ve a Calendar nuevamente

**✅ Resultado esperado:**

- Las tareas del Goal borrado NO deben aparecer en el Calendar
- El caché debe haberse invalidado correctamente

### 3.2 Al completar un Goal → actualizar estado en caché

**Pasos:**

1. Ve a un Goal activo
2. Marca el Goal como completado (menú → "Marcar como completada")
3. Vuelve a la lista de Goals
4. Desactiva conexión
5. Entra al mismo Goal

**✅ Resultado esperado:**

- El Goal debe mostrar estado "completado" incluso offline
- El badge de progreso debe mostrar 100%

### 3.3 Al generar tasks → cachear nuevas tasks automáticamente

**Pasos:**

1. Crea un Goal sin tareas (o borra las existentes)
2. Genera tareas con IA (menú → "Generar tareas con IA")
3. Espera a que termine
4. Desactiva conexión
5. Ve a Calendar y busca las nuevas tareas

**✅ Resultado esperado:**

- Las tareas generadas deben aparecer en Calendar sin conexión
- Deben estar cacheadas inmediatamente

### 3.4 Al cambiar deadline/disponibilidad → invalidar sesiones futuras

**Pasos:**

1. Ve a un Goal con tareas programadas en el futuro
2. Cambia el deadline a una fecha más cercana (menú → "Cambiar fecha límite")
3. Ve a Calendar y busca las tareas futuras

**✅ Resultado esperado:**

- Las tareas que ya no caben en el nuevo deadline deben desaparecer
- El caché de tasks futuras debe invalidarse

### 3.5 Al cambiar disponibilidad → invalidar tasks futuras

**Pasos:**

1. Ve a un Goal con reglas de disponibilidad
2. Modifica las reglas (quita algunos días)
3. Ve a Calendar

**✅ Resultado esperado:**

- Las tareas en días que ya no están disponibles deben desaparecer
- El caché debe reflejar los nuevos horarios

---

## 4. Timestamps de Sincronización

### 4.1 Verificar que se muestra "Última actualización"

**Pasos:**

1. Ve a Goals
2. Espera a que cargue
3. Busca en la UI el texto de "Actualizado hace..."

**✅ Resultado esperado:**

- Debe aparecer texto como "Actualizado hace un momento" o "Actualizado hace 2 min"
- El timestamp debe actualizarse después de pull-to-refresh

### 4.2 Verificar timestamp en Calendar

**Pasos:**

1. Ve a Calendar
2. Espera a que cargue
3. Verifica el timestamp de sincronización

**✅ Resultado esperado:**

- Debe mostrar cuándo fue la última sincronización
- El formato debe ser legible (ej: "hace 5 minutos")

### 4.3 Verificar que el timestamp se actualiza después de operaciones

**Pasos:**

1. Ve a Goals, toma nota del timestamp
2. Crea un nuevo Goal
3. Vuelve a la lista de Goals

**✅ Resultado esperado:**

- El timestamp debe haberse actualizado a "hace un momento"
- Indica que la sincronización ocurrió recientemente

---

## 5. Manejo de Errores con Fallback

### 5.1 Fallback a caché cuando no hay conexión (Goals)

**Pasos:**

1. Con conexión activa, carga la lista de Goals
2. Desactiva conexión
3. Cierra y abre la app
4. Ve a Goals

**✅ Resultado esperado:**

- Debe mostrar los goals desde caché sin error visible
- No debe mostrar pantalla de error de red
- (Opcional) Podría mostrar indicador sutil de "modo offline"

### 5.2 Fallback a caché cuando el servidor falla

**Pasos:**

1. Con conexión activa, carga Goals
2. Simula error del servidor (si es posible, o desactiva conexión)
3. Intenta recargar (pull-to-refresh)

**✅ Resultado esperado:**

- Si hay caché: muestra datos cacheados
- Si no hay caché: muestra error amigable con opción de reintentar

### 5.3 Fallback en Calendar

**Pasos:**

1. Carga Calendar con conexión
2. Desactiva conexión
3. Cambia de mes y vuelve

**✅ Resultado esperado:**

- Debe mostrar tareas cacheadas
- Navegación fluida sin errores

---

## 6. Limpieza de Caché en Logout

### 6.1 Verificar que el caché se limpia al cerrar sesión

**Pasos:**

1. Inicia sesión y usa la app (crea goals, tareas, etc.)
2. Ve a Settings → "Cerrar sesión"
3. Confirma el logout
4. Vuelve a iniciar sesión (con el mismo usuario u otro)

**✅ Resultado esperado:**

- Al iniciar sesión nuevamente, los datos deben cargarse desde el servidor
- No debe mostrar datos "fantasma" del usuario anterior
- Todo debe estar limpio

### 6.2 Verificar que no hay datos de sesión anterior

**Pasos:**

1. Cierra sesión
2. Sin cerrar la app, inicia sesión con OTRO usuario
3. Ve a Goals

**✅ Resultado esperado:**

- Debe mostrar los goals del nuevo usuario, NO del anterior
- El caché debe haberse limpiado completamente

---

## 7. Pull-to-Refresh

### 7.1 Verificar que invalida caché y recarga

**Pasos:**

1. Ve a Goals
2. Haz pull-to-refresh (arrastrar hacia abajo)
3. Observa el indicador de carga

**✅ Resultado esperado:**

- Debe mostrar indicador de carga
- Debe recargar datos del servidor
- El timestamp debe actualizarse

### 7.2 Verificar en pantalla de detalle de Goal

**Pasos:**

1. Entra a un Goal específico
2. Haz pull-to-refresh
3. Verifica que se actualiza la información

**✅ Resultado esperado:**

- El detalle debe recargarse desde el servidor
- Las tareas deben actualizarse si hubo cambios

### 7.3 Verificar en Calendar

**Pasos:**

1. Ve a Calendar
2. Haz pull-to-refresh
3. Verifica que se actualizan las tareas

**✅ Resultado esperado:**

- Las tareas deben recargarse desde el servidor
- El timestamp debe actualizarse

---

## 🔧 Herramientas de Debugging

### Ver estadísticas de caché (opcional)

Si necesitas verificar qué hay en la base de datos local, puedes agregar temporalmente un botón de debug:

```dart
// En SettingsPage, agregar temporalmente:
ListTile(
  leading: const Icon(Icons.storage),
  title: const Text('Debug: Cache Stats'),
  subtitle: const Text('Ver estadísticas de caché local'),
  onTap: () async {
    final db = ref.read(appDatabaseProvider);
    final stats = await db.getCacheStats();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cache Stats'),
        content: Text(
          'Tasks: ${stats['tasks']}\n'
          'Goals: ${stats['goals']}\n'
          'Rules: ${stats['availabilityRules']}',
        ),
      ),
    );
  },
),
```

---

## ✅ Checklist Final de Verificación

Antes de iniciar la Fase 3, asegúrate de que:

- [ ] Todos los tests de la sección 1 pasan (Caché de Goals)
- [ ] Todos los tests de la sección 2 pasan (Caché de Calendar)
- [ ] Todos los tests de la sección 3 pasan (Invalidación)
- [ ] Todos los tests de la sección 4 pasan (Timestamps)
- [ ] Todos los tests de la sección 5 pasan (Fallback)
- [ ] Todos los tests de la sección 6 pasan (Logout)
- [ ] Todos los tests de la sección 7 pasan (Pull-to-refresh)
- [ ] `flutter analyze` no muestra errores
- [ ] La app no crashea en ningún escenario

---

## 🐛 Problemas Comunes y Soluciones

### Problema: Los datos no persisten después de cerrar la app

**Posible causa:** La base de datos no se está guardando correctamente.

**Verificación:** Revisa que `AppDatabase` use `NativeDatabase.createInBackground()` y no `NativeDatabase.memory()`.

### Problema: Las tareas de un Goal borrado siguen apareciendo

**Posible causa:** La invalidación de caché no está funcionando.

**Verificación:** Revisa que `GoalRepositoryImpl.deleteGoal()` llame a `_taskLocalDataSource.deleteTasksByGoalId(id)`.

### Problema: El timestamp no se actualiza

**Posible causa:** El provider de sync no está siendo notificado.

**Verificación:** Revisa que los repositorios llamen a `_updateSyncTime()` después de operaciones exitosas.

### Problema: Al hacer logout, los datos del usuario anterior persisten

**Posible causa:** `clearAllCache()` no se está llamando o no funciona.

**Verificación:** Revisa que `AuthNotifier.logout()` llame a `db.clearAllCache()` y que este método borre todas las tablas.

---

## 📝 Notas para el Desarrollador

Si encuentras algún problema durante las pruebas:

1. **Revisa los logs:** Busca mensajes de error relacionados con Drift/SQLite
2. **Verifica la base de datos:** Usa la herramienta de debug para ver estadísticas
3. **Prueba en modo avión:** Es la forma más confiable de simular offline
4. **Limpia la app:** Desinstala y reinstala si sospechas de caché corrupto

---

**¿Listo para la Fase 3?** ✅

Una vez que todas las pruebas pasen, el sistema offline-first estará completamente funcional y podrás proceder con confianza a la Fase 3.
