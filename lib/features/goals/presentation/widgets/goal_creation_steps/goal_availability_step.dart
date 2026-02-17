import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/core/constants/app_constants.dart';
import 'package:productivity/features/goals/presentation/state/goal_creation_provider.dart';

/// Step 4: Availability selection with single-line day selector.
class GoalAvailabilityStep extends ConsumerWidget {
  const GoalAvailabilityStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalCreationProvider);
    final notifier = ref.read(goalCreationProvider.notifier);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon header
          _buildHeader(context, theme, state.sessionDuration),
          const SizedBox(height: 24),

          // Day selector - centered with proper constraints
          _buildDaySelector(context, state, notifier, theme),
          const SizedBox(height: 20),

          // Selected day editor or empty state
          if (state.selectedDay != null)
            _buildDayEditor(context, state, notifier, theme)
          else if (state.availability.isNotEmpty)
            _buildDaySelectionPrompt(context, theme)
          else
            _buildEmptyState(context, theme),

          // Error message
          if (state.errors['availability'] != null) ...[
            const SizedBox(height: 12),
            _buildErrorText(context, state.errors['availability']!, theme),
          ],

          // Summary
          if (state.availability.isNotEmpty && state.selectedDay == null)
            _buildSummary(context, state, theme),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    int sessionDuration,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.access_time,
            color: theme.colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Cuándo estás disponible?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sesiones de ${sessionDuration}min',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector(
    BuildContext context,
    GoalCreationState state,
    GoalCreationNotifier notifier,
    ThemeData theme,
  ) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.weekDays.map((day) {
            final hasSlots =
                state.availability.containsKey(day) &&
                (state.availability[day]?.isNotEmpty ?? false);
            final isSelected = state.selectedDay == day;
            final dayLabel = AppConstants.dayShortLabels[day]!;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => notifier.toggleDay(day),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : hasSlots
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : hasSlots
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                      width: isSelected || hasSlots ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dayLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : hasSlots
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDayEditor(
    BuildContext context,
    GoalCreationState state,
    GoalCreationNotifier notifier,
    ThemeData theme,
  ) {
    final day = state.selectedDay!;
    final slots = state.availability[day] ?? [];
    final dayLabel = AppConstants.dayLabels[day]!;
    final hasSlots = slots.isNotEmpty;

    // Calculate sessions for this day
    int dayMinutes = 0;
    for (final slot in slots) {
      final startParts = slot.start.split(':');
      final endParts = slot.end.split(':');
      final startMinutes =
          int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      dayMinutes += endMinutes - startMinutes;
    }
    final daySessions = dayMinutes ~/ state.sessionDuration;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day header with remove button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    dayLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (hasSlots && daySessions > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$daySessions sesiones',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => notifier.removeDay(day),
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  tooltip: 'Eliminar día',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time ranges or empty state
            if (hasSlots) ...[
              ...slots.asMap().entries.map((entry) {
                final index = entry.key;
                final slot = entry.value;
                return _TimeRangeRow(
                  slot: slot,
                  onStartChanged: (newStart) {
                    final updated = List<({String start, String end})>.from(
                      slots,
                    );
                    updated[index] = (start: newStart, end: slot.end);
                    notifier.updateDaySlots(day, updated);
                  },
                  onEndChanged: (newEnd) {
                    final updated = List<({String start, String end})>.from(
                      slots,
                    );
                    updated[index] = (start: slot.start, end: newEnd);
                    notifier.updateDaySlots(day, updated);
                  },
                  onDelete: () {
                    final updated = List<({String start, String end})>.from(
                      slots,
                    );
                    updated.removeAt(index);
                    notifier.updateDaySlots(day, updated);
                  },
                  theme: theme,
                );
              }),
              const SizedBox(height: 8),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No has agregado horarios para este día',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Add time range button
            TextButton.icon(
              onPressed: () => _addNewSlot(context, day, slots, notifier),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: Text(
                hasSlots ? 'Agregar otro horario' : 'Agregar horario',
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelectionPrompt(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toca un día para editar',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Los días en color ya tienen horarios',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.5,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Selecciona los días',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Toca las letras de los días donde puedas trabajar en tu meta',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 16,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Empieza tocando un día',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorText(BuildContext context, String error, ThemeData theme) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 16),
          const SizedBox(width: 6),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    GoalCreationState state,
    ThemeData theme,
  ) {
    int totalMinutes = 0;
    int daysWithSlots = 0;
    int totalTimeSlots = 0;

    state.availability.forEach((day, slots) {
      if (slots.isNotEmpty) {
        daysWithSlots++;
        totalTimeSlots += slots.length;
        for (final slot in slots) {
          final startParts = slot.start.split(':');
          final endParts = slot.end.split(':');
          final startMinutes =
              int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
          final endMinutes =
              int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
          totalMinutes += endMinutes - startMinutes;
        }
      }
    });

    final estimatedSessions = totalMinutes ~/ state.sessionDuration;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: totalTimeSlots > 0
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : theme.colorScheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            totalTimeSlots > 0
                ? Icons.check_circle_outline
                : Icons.warning_amber,
            color: totalTimeSlots > 0
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onErrorContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalTimeSlots > 0
                      ? '$estimatedSessions sesiones posibles'
                      : 'Agrega al menos un horario',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: totalTimeSlots > 0
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                if (totalTimeSlots > 0)
                  Text(
                    'En $daysWithSlots días con ${totalMinutes ~/ 60}h ${totalMinutes % 60}min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  )
                else
                  Text(
                    'Debes agregar horarios para poder continuar',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewSlot(
    BuildContext context,
    String day,
    List<({String start, String end})> currentSlots,
    GoalCreationNotifier notifier,
  ) async {
    String suggestedStart = '09:00';
    String suggestedEnd = '12:00';

    if (currentSlots.isNotEmpty) {
      final sorted = List<({String start, String end})>.from(currentSlots)
        ..sort((a, b) => a.start.compareTo(b.start));

      final lastSlot = sorted.last;
      final lastEndHour = int.parse(lastSlot.end.split(':')[0]);
      if (lastEndHour < 20) {
        suggestedStart = '${(lastEndHour).toString().padLeft(2, '0')}:00';
        suggestedEnd = '${(lastEndHour + 2).toString().padLeft(2, '0')}:00';
      }
    }

    final updated = List<({String start, String end})>.from(currentSlots);
    updated.add((start: suggestedStart, end: suggestedEnd));
    notifier.updateDaySlots(day, updated);
  }
}

class _TimeRangeRow extends StatelessWidget {
  final ({String start, String end}) slot;
  final ValueChanged<String> onStartChanged;
  final ValueChanged<String> onEndChanged;
  final VoidCallback onDelete;
  final ThemeData theme;

  const _TimeRangeRow({
    required this.slot,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onDelete,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: _TimeButton(
              time: slot.start,
              label: 'Inicio',
              onTap: () => _pickTime(context, slot.start, onStartChanged),
              theme: theme,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: _TimeButton(
              time: slot.end,
              label: 'Fin',
              onTap: () => _pickTime(context, slot.end, onEndChanged),
              theme: theme,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.error,
              size: 20,
            ),
            tooltip: 'Eliminar horario',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    String current,
    ValueChanged<String> onChanged,
  ) async {
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onChanged(formatted);
    }
  }
}

class _TimeButton extends StatelessWidget {
  final String time;
  final String label;
  final VoidCallback onTap;
  final ThemeData theme;

  const _TimeButton({
    required this.time,
    required this.label,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
