# Correcciones Completadas - Productivity App

## ✅ Críticos (Bloquean compilación/funcionamiento)

- [x] 1. Corregir error de sintaxis en `injection_container.dart` (`Provider<FlNaN`)
- [x] 2. Completar código truncado en `app_router.dart` (`SlideTransNaN`) - Verificado: código ya estaba completo
- [x] 3. Registrar datasources locales faltantes en DI container
- [x] 4. Unificar providers de autenticación - Se mantiene `authProvider` como principal

## ✅ Funcionales (Problemas reportados por usuario)

- [x] 5. **Problema 1: Tareas no se cachean en modo offline**
  - ✅ Modificar `GoalLocalDataSource.getGoal()` para obtener tareas desde caché local
  - ✅ Agregar método `getTasksForGoal()` en `TaskLocalDataSource`
  - ✅ Agregar método `getTasksByGoalId()` en `AppDatabase`
  - ✅ Inyectar `TaskLocalDataSource` en `GoalLocalDataSourceImpl`
  - ✅ Actualizar `_dbToModel()` para incluir tareas en el modelo
- [x] 6. **Problema 2: Sincronización aparece como "sin sincronizar"**
  - ✅ Corregir `SyncNotifier` para actualizar también el `StateProvider`
  - ✅ Pasar `Ref` y `StateProvider` al constructor de `SyncNotifier`
  - ✅ Sincronizar estado entre `SyncNotifier` y `timestampProvider`
- [x] 7. **Problema 3: Próxima tarea solo funciona en offline**
  - ✅ Agregar manejo robusto de respuestas nulas en `getNextTask()`
  - ✅ Agregar logging con `debugPrint` para debugging
  - ✅ Manejar casos donde el servidor retorna respuesta vacía
  - ✅ Agregar UI de estado vacío con botón de reintentar en `today_page.dart`
  - ✅ Agregar logging detallado en `CalendarRepositoryImpl.getNextTask()`
  - ✅ **FIX CRÍTICO**: Hacer `TaskModel` robusto contra campos null del backend
    - Agregados helpers `_safeString()` y `_safeStringNullable()`
    - Todos los campos String ahora usan safe converters
    - `scheduledAt` y `status` tienen valores por defecto
    - `toEntity()` maneja strings vacíos gracefully
  - ✅ **FIX CRÍTICO**: Actualizar `task_model.g.dart` para usar safe converters
    - El archivo generado no usaba los helpers safe
    - Causaba `type 'Null' is not a subtype of type 'String' in type cast`
    - Ahora usa `_safeString()`, `_safeStringNullable()`, `_safeInt()`, `_safeBool()`
- [x] 8. **Problema 4: Completar tarea no actualiza Goal Detail / Today / Calendar**
  - ✅ Agregar invalidación de `goalDetailProvider(goalId)` en `_invalidateTaskProviders()`
  - ✅ Agregar invalidación de `goalsProvider` para actualizar progreso
  - ✅ Pasar `goalId` a la función de invalidación
  - ✅ Remover invalidación de `calendarTasksProvider` (causaba error)
  - ✅ **FIX CRÍTICO**: Sincronizar caché de calendario al completar tarea
    - `TaskRepositoryImpl` ahora recibe `CalendarLocalDataSource`
    - `completeTask()` y `skipTask()` actualizan AMBOS cachés (task + calendar)
    - Esto asegura que Today y Calendar muestren datos actualizados inmediatamente
  - ✅ **FIX CRÍTICO**: Usar `refresh()` en lugar de `invalidate()` para AsyncNotifiers
    - `ref.read(todayProvider.notifier).refresh()` en lugar de `invalidate()`
    - `ref.read(nextTaskProvider.notifier).refresh()` en lugar de `invalidate()`
    - Los AsyncNotifiers necesitan refresh() para reconstruirse con nuevos datos
  - ✅ **FIX CRÍTICO**: Sistema de trigger global para calendario
    - `calendarRefreshTriggerProvider` - StateProvider<int> para forzar rebuilds
    - `refreshCalendar(Ref ref)` - función helper para trigger desde cualquier lugar
    - `CalendarTasksNotifier` hace `ref.watch(calendarRefreshTriggerProvider)`
    - Esto fuerza rebuild de TODAS las instancias de calendario en la app

## 🟢 Mejoras Adicionales (Robustez y mantenibilidad)

- [x] 9. Agregar manejo de errores en `CalendarRemoteDataSource`
- [x] 10. Estructura de DI container mejorada con todos los providers locales
- [x] 11. Arquitectura offline-first completamente funcional
- [x] 12. UI mejorada para "Sin próxima tarea" con opción de reintentar

---

## 📁 Archivos Modificados

1. `lib/app/di/injection_container.dart` - DI container completo y funcional, agregado `calendarLocalDataSourceProvider` a `taskRepositoryProvider`
2. `lib/features/goals/data/datasources/goal_local_datasource.dart` - Soporte offline para tareas
3. `lib/features/tasks/data/datasources/task_local_datasource.dart` - Nuevo método `getTasksForGoal()`
4. `lib/core/database/app_database.dart` - Nuevo método `getTasksByGoalId()`
5. `lib/features/tasks/presentation/state/task_provider.dart` - **Usar `refresh()` + trigger global de calendario**
6. `lib/core/providers/sync_provider.dart` - Sincronización de estado fija
7. `lib/features/calendar/data/datasources/calendar_remote_datasource.dart` - **Logging detallado para debugging de /next**
8. `lib/features/calendar/presentation/pages/today_page.dart` - UI mejorada para próxima tarea
9. `lib/features/calendar/data/repositories/calendar_repository_impl.dart` - Logging detallado
10. `lib/features/tasks/data/repositories/task_repository_impl.dart` - **Sincronización de caché calendario al completar/saltar tarea**
11. `lib/features/tasks/data/models/task_model.dart` - **Robustez contra campos null del backend**
12. `lib/features/tasks/data/models/task_model.g.dart` - **FIX CRÍTICO: Usar safe converters en código generado**
13. `lib/features/calendar/presentation/state/calendar_provider.dart` - **Trigger global + `ref.watch()` para reconstrucción automática**

---

## 🔍 Debugging - Próxima Tarea en Online

Si "Siguiente tarea" sigue sin mostrarse en online, revisar los logs de debug:

1. Buscar en consola: `CalendarRemote: Raw response data: ...`
2. Verificar si el servidor retorna datos válidos
3. Si muestra `taskJson is null or not a Map`, el backend no está enviando la próxima tarea
4. Si muestra `Error parsing next task:`, hay un problema de parsing - revisar el stack trace
5. Verificar endpoint `/next` en el backend

### Logs clave a buscar:

```
CalendarRemote: Raw response data: {...}
CalendarRemote: Response keys: [task, starts_in]
CalendarRemote: taskJson type: _Map<String, dynamic>, value: {...}
CalendarRemote: Parsing task with id: 5
CalendarRemote: Task parsed successfully: Sesión 5: Eloquent ORM
CalendarRemote: starts_in: 2 hours from now
```

## 🎯 Resumen de Soluciones Clave

### Problema: "Ocurrió un error" al completar tarea

**Causa**: Se invalidaba `calendarTasksProvider` (provider con familia) sin parámetros  
**Solución**: Remover invalidación de provider con familia

### Problema: Today/Calendar no se actualizan automáticamente

**Causa raíz**: Dos problemas:

1. Dos cachés separados (TaskLocalDataSource vs CalendarLocalDataSource) no sincronizados
2. `invalidate()` no funciona bien con `AsyncNotifier` - necesita `refresh()`

**Solución**:

- `TaskRepositoryImpl` actualiza AMBOS cachés al completar/saltar tarea
- `task_provider.dart` usa `ref.read(todayProvider.notifier).refresh()` en lugar de `invalidate()`
- `calendar_provider.dart` usa `ref.watch()` en `build()` para reconstrucción automática

### Problema: Próxima tarea no aparece en online

**Causa raíz**: Dos problemas:

1. **Backend retorna campos null**: El modelo espera `String` pero recibe `null`
2. **Código generado no usaba safe converters**: `task_model.g.dart` usaba casts directos (`as String`)

**Error**: `type 'Null' is not a subtype of type 'String' in type cast` en `_$TaskModelFromJson`

**Solución**:

- `TaskModel` ahora usa safe converters: `_safeString()`, `_safeStringNullable()`
- **`task_model.g.dart` actualizado** para usar los safe converters en lugar de casts directos
- Todos los campos String manejan null gracefully
- Valores por defecto para campos críticos (`scheduledAt = ''`, `status = 'scheduled'`)
- `toEntity()` maneja strings vacíos sin crash

### Problema: Calendario no se actualiza al completar tarea

**Causa raíz**: `calendarTasksProvider` es un provider con familia que se crea por rango de fechas. Cuando se completa una tarea desde otra página (ej: Today o Task Detail), las instancias del calendario no se enteran.

**Solución**:

- **Sistema de trigger global**: `calendarRefreshTriggerProvider` (StateProvider<int>)
- **Función helper**: `refreshCalendar(Ref ref)` que incrementa el trigger
- **Watch en notifier**: `CalendarTasksNotifier` hace `ref.watch(calendarRefreshTriggerProvider)`
- Cuando se completa una tarea, se llama `refreshCalendar(ref)` y TODAS las instancias del calendario se reconstruyen automáticamente
