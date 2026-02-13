# TODO - Correcciones Fase 2 (12 Problemas Críticos)

## 🔴 PROBLEMAS CRÍTICOS A CORREGIR

### 1. Ordenamiento inconsistente de Goals (1.1)

**Problema:** Goals se ordenan por deadline en caché, pero por fecha de creación en servidor.
**Solución:** Modificar `getAllGoals()` para ordenar por `createdAt` DESC
**Archivos:** `lib/core/database/app_database.dart`, `lib/core/database/tables/goals_table.dart`

### 2. Tareas no se cachean en detalle de Goal (1.2, 3.3)

**Problema:** Las tareas/sesiones no se cachean cuando se ve el detalle de un Goal.
**Solución:** Cachear tareas al obtener goal detail
**Archivos:**

- `lib/features/goals/data/datasources/goal_local_datasource.dart`
- `lib/features/goals/data/repositories/goal_repository_impl.dart`
- `lib/features/tasks/data/datasources/task_local_datasource.dart`
- `lib/app/di/injection_container.dart`

### 3. Timestamp de sincronización no visible (4.1, 4.2, 4.3)

**Problema:** No se muestra "Última actualización" en ninguna pantalla.
**Solución:** Crear widget `LastSyncIndicator` y agregarlo a las páginas
**Archivos:**

- Crear: `lib/core/widgets/last_sync_indicator.dart`
- `lib/features/goals/presentation/pages/goals_list_page.dart`
- `lib/features/calendar/presentation/pages/calendar_page.dart`
- `lib/features/calendar/presentation/pages/today_page.dart`

### 4. Caché no se limpia en logout (6.1, 6.2)

**Problema:** Al hacer logout e iniciar con otro usuario, se ven datos del usuario anterior.
**Solución:** Asegurar que `clearAllCache()` se ejecute completamente antes de navegar
**Archivos:** `lib/features/auth/presentation/state/auth_provider.dart`

### 5. Sesión no persiste al cerrar app

**Problema:** Cada vez que se cierra la app, hay que iniciar sesión de nuevo.
**Solución:** Revisar recuperación de token en `AuthNotifier.build()`
**Archivos:** `lib/features/auth/presentation/state/auth_provider.dart`

### 6. Tareas de IA no se cachean

**Problema:** Al crear goal con IA, solo se cachean datos básicos del goal, no las tareas.
**Solución:** Cachear tareas del response en `generateTasks()`
**Archivos:** `lib/features/goals/data/repositories/goal_repository_impl.dart`

### 7. Cambios en tareas requieren refresh manual

**Problema:** Al completar una tarea, los cambios no se reflejan hasta hacer refresh.
**Solución:** Invalidar providers automáticamente después de operaciones
**Archivos:** `lib/features/tasks/presentation/state/task_provider.dart`

### 8. Próxima tarea solo en offline (2.3)

**Problema:** La próxima tarea solo se muestra en modo offline, no en online.
**Solución:** Revisar lógica condicional en `TodayPage`
**Archivos:** `lib/features/calendar/presentation/pages/today_page.dart`

### 9. Indicador de modo offline (5.1)

**Problema:** No hay indicador visual de modo offline.
**Solución:** Crear provider de conectividad y banner sutil
**Archivos:**

- Crear: `lib/core/providers/connectivity_provider.dart`
- Modificar: `lib/app/shell/main_shell.dart`

### 10. Disponibilidad no se muestra (1.3)

**Problema:** Las reglas de disponibilidad no se muestran en frontend.
**Nota:** Esto es esperado según el usuario, no requiere corrección ahora.

### 11. Cambiar deadline/disponibilidad no implementado (3.4, 3.5)

**Problema:** Funcionalidad no implementada en frontend/backend.
**Nota:** Requiere implementación completa, no es bug.

### 12. Invalidación de caché funciona pero requiere refresh (3.2)

**Problema:** Se invalida correctamente pero UI no se actualiza automáticamente.
**Solución:** Mejorar invalidación de providers

---

## 📋 CHECKLIST DE PROGRESO

- [x] 1. Ordenamiento Goals por createdAt - ✅ CORREGIDO
- [x] 2. Cachear tareas en goal detail - ✅ CORREGIDO
- [x] 3. Timestamp visible en páginas - ✅ CORREGIDO (integrado en GoalsListPage, CalendarPage, TodayPage)
- [x] 4. Fix logout limpieza caché - ✅ CORREGIDO
- [x] 5. Fix persistencia sesión - ✅ CORREGIDO (offline fallback)
- [x] 6. Cachear tareas de IA - ✅ CORREGIDO (ya estaba implementado)
- [x] 7. Auto-invalidate providers - ✅ CORREGIDO
- [x] 8. Fix próxima tarea online - ✅ CORREGIDO (debug agregado, página actualizada)
- [x] 9. Indicador offline - ✅ CORREGIDO (integrado en MainShell)
- [ ] 10. (No requiere - disponibilidad)
- [ ] 11. (No requiere - no implementado)
- [x] 12. Mejorar invalidación UI - ✅ CORREGIDO (auto-invalidate en task_provider)

---

## 🎯 PRIORIDADES

**ALTA (Crítica):** 4, 5, 2, 8
**MEDIA:** 1, 3, 6, 7, 12
**BAJA:** 9
