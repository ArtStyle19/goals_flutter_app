import 'package:flutter/material.dart';

import 'package:productivity/core/constants/app_constants.dart';

/// A reusable availability editor widget with the same UX used in goal creation.
///
/// Shows a day selector row, a detail card for the selected day with
/// time-slot editing (time pickers, add/remove), and an optional summary.
/// Designed to be used in both goal creation and replan flows via callbacks.
class AvailabilityEditor extends StatefulWidget {
  /// Current availability map: day key → list of time slots.
  final Map<String, List<({String start, String end})>> availability;

  /// Session duration in minutes — used for the sessions-per-day badge.
  final int sessionDurationMinutes;

  /// Called whenever the availability map changes.
  final ValueChanged<Map<String, List<({String start, String end})>>>
  onAvailabilityChanged;

  /// Optional error text shown below the day selector.
  final String? errorText;

  /// Whether to show the summary bar when no day is selected.
  final bool showSummary;

  const AvailabilityEditor({
    super.key,
    required this.availability,
    required this.sessionDurationMinutes,
    required this.onAvailabilityChanged,
    this.errorText,
    this.showSummary = true,
  });

  @override
  State<AvailabilityEditor> createState() => _AvailabilityEditorState();
}

class _AvailabilityEditorState extends State<AvailabilityEditor> {
  String? _selectedDay;

  // ─── Helpers ──────────────────────────────────────────

  void _toggleDay(String day) {
    final updated = Map<String, List<({String start, String end})>>.from(
      widget.availability,
    );

    if (updated.containsKey(day)) {
      // Day exists → toggle selection for editing
      setState(() {
        _selectedDay = (_selectedDay == day) ? null : day;
      });
    } else {
      // New day → add with empty slots, select it
      updated[day] = [];
      setState(() => _selectedDay = day);
      widget.onAvailabilityChanged(updated);
    }
  }

  void _removeDay(String day) {
    final updated = Map<String, List<({String start, String end})>>.from(
      widget.availability,
    );
    updated.remove(day);
    setState(() {
      if (_selectedDay == day) _selectedDay = null;
    });
    widget.onAvailabilityChanged(updated);
  }

  void _updateDaySlots(String day, List<({String start, String end})> slots) {
    final updated = Map<String, List<({String start, String end})>>.from(
      widget.availability,
    );
    if (slots.isEmpty) {
      updated.remove(day);
      if (_selectedDay == day) setState(() => _selectedDay = null);
    } else {
      updated[day] = slots;
    }
    widget.onAvailabilityChanged(updated);
  }

  void _addNewSlot(
    String day,
    List<({String start, String end})> currentSlots,
  ) {
    String suggestedStart = '09:00';
    String suggestedEnd = '12:00';

    if (currentSlots.isNotEmpty) {
      final sorted = List<({String start, String end})>.from(currentSlots)
        ..sort((a, b) => a.start.compareTo(b.start));
      final lastEndHour = int.parse(sorted.last.end.split(':')[0]);
      if (lastEndHour < 20) {
        suggestedStart = '${lastEndHour.toString().padLeft(2, '0')}:00';
        suggestedEnd =
            '${(lastEndHour + 2).clamp(0, 23).toString().padLeft(2, '0')}:00';
      }
    }

    final updated = List<({String start, String end})>.from(currentSlots);
    updated.add((start: suggestedStart, end: suggestedEnd));
    _updateDaySlots(day, updated);
  }

  int _dayMinutes(List<({String start, String end})> slots) {
    int total = 0;
    for (final slot in slots) {
      final s = slot.start.split(':');
      final e = slot.end.split(':');
      total +=
          (int.parse(e[0]) * 60 + int.parse(e[1])) -
          (int.parse(s[0]) * 60 + int.parse(s[1]));
    }
    return total;
  }

  // ─── Build ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Day selector row
        _buildDaySelector(theme),
        const SizedBox(height: 16),

        // Selected day editor or prompt / empty state
        if (_selectedDay != null)
          _buildDayEditor(theme)
        else if (widget.availability.isNotEmpty)
          _buildDaySelectionPrompt(theme)
        else
          _buildEmptyState(theme),

        // Error message
        if (widget.errorText != null) ...[
          const SizedBox(height: 12),
          _buildError(theme),
        ],

        // Summary
        if (widget.showSummary &&
            widget.availability.isNotEmpty &&
            _selectedDay == null)
          _buildSummary(theme),
      ],
    );
  }

  // ─── Day Selector ─────────────────────────────────────

  Widget _buildDaySelector(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.weekDays.map((day) {
            final hasSlots =
                widget.availability.containsKey(day) &&
                (widget.availability[day]?.isNotEmpty ?? false);
            final isSelected = _selectedDay == day;
            final dayLabel = AppConstants.dayShortLabels[day]!;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => _toggleDay(day),
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

  // ─── Day Editor Card ──────────────────────────────────

  Widget _buildDayEditor(ThemeData theme) {
    final day = _selectedDay!;
    final slots = widget.availability[day] ?? [];
    final dayLabel = AppConstants.dayLabels[day]!;
    final hasSlots = slots.isNotEmpty;

    final daySessions = _dayMinutes(slots) ~/ widget.sessionDurationMinutes;

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
            // Day header with sessions badge + delete
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
                      '$daySessions ${daySessions == 1 ? 'sesión' : 'sesiones'}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeDay(day),
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

            // Time ranges or empty hint
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
                    _updateDaySlots(day, updated);
                  },
                  onEndChanged: (newEnd) {
                    final updated = List<({String start, String end})>.from(
                      slots,
                    );
                    updated[index] = (start: slot.start, end: newEnd);
                    _updateDaySlots(day, updated);
                  },
                  onDelete: () {
                    final updated = List<({String start, String end})>.from(
                      slots,
                    );
                    updated.removeAt(index);
                    _updateDaySlots(day, updated);
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
              onPressed: () => _addNewSlot(day, slots),
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

  // ─── Prompt / Empty States ────────────────────────────

  Widget _buildDaySelectionPrompt(ThemeData theme) {
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

  Widget _buildEmptyState(ThemeData theme) {
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

  // ─── Error ────────────────────────────────────────────

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 16),
          const SizedBox(width: 6),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Summary ──────────────────────────────────────────

  Widget _buildSummary(ThemeData theme) {
    int totalMinutes = 0;
    int daysWithSlots = 0;
    int totalTimeSlots = 0;

    widget.availability.forEach((_, slots) {
      if (slots.isNotEmpty) {
        daysWithSlots++;
        totalTimeSlots += slots.length;
        totalMinutes += _dayMinutes(slots);
      }
    });

    final estimatedSessions = totalMinutes ~/ widget.sessionDurationMinutes;

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
}

// ─── Private Widgets ──────────────────────────────────────

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

    final picked = await showTimePicker(context: context, initialTime: initial);

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
