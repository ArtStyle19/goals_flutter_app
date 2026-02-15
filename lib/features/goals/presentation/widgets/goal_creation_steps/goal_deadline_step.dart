import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/features/goals/presentation/state/goal_creation_provider.dart';

/// Step 2: Goal deadline selection.
class GoalDeadlineStep extends ConsumerWidget {
  const GoalDeadlineStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalCreationProvider);
    final notifier = ref.read(goalCreationProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(context, theme),
        const SizedBox(height: 24),

        // Date picker card
        _buildDatePickerCard(context, state, notifier, theme),
        if (state.errors['deadline'] != null) ...[
          const SizedBox(height: 12),
          _buildErrorText(context, state.errors['deadline']!, theme),
        ],
        const SizedBox(height: 24),

        // Quick select buttons
        _buildQuickSelectButtons(context, notifier, theme),
        const SizedBox(height: 24),

        // Info card
        if (state.deadline != null)
          _buildDeadlineInfoCard(context, state.deadline!, theme),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.calendar_today_outlined,
            color: theme.colorScheme.onSecondaryContainer,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '¿Cuándo quieres completarla?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona una fecha límite realista para tu meta.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerCard(
    BuildContext context,
    GoalCreationState state,
    GoalCreationNotifier notifier,
    ThemeData theme,
  ) {
    final isSelected = state.deadline != null;

    return InkWell(
      onTap: () => _showDatePicker(context, notifier),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? Icons.event_available : Icons.event_outlined,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSelected ? 'Fecha seleccionada' : 'Seleccionar fecha',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSelected
                        ? AppDateUtils.formatFull(state.deadline!)
                        : 'Toca para abrir el calendario',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSelectButtons(
    BuildContext context,
    GoalCreationNotifier notifier,
    ThemeData theme,
  ) {
    final options = [
      (label: '1 semana', days: 7),
      (label: '2 semanas', days: 14),
      (label: '1 mes', days: 30),
      (label: '3 meses', days: 90),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selección rápida',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            return ActionChip(
              avatar: Icon(
                Icons.flash_on,
                size: 18,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              label: Text(option.label),
              onPressed: () {
                final date = DateTime.now().add(Duration(days: option.days));
                notifier.setDeadline(date);
              },
              backgroundColor: theme.colorScheme.secondaryContainer,
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDeadlineInfoCard(
    BuildContext context,
    DateTime deadline,
    ThemeData theme,
  ) {
    final daysUntil = AppDateUtils.daysUntil(deadline);
    final isShort = daysUntil <= 7;
    final isLong = daysUntil >= 90;

    final (icon, title, description, color) = switch ((isShort, isLong)) {
      (true, _) => (
        Icons.timer,
        'Plazo corto',
        'Asegúrate de tener suficiente tiempo disponible.',
        theme.colorScheme.tertiary,
      ),
      (_, true) => (
        Icons.calendar_month,
        'Plazo amplio',
        'Perfecto para metas complejas que requieren más tiempo.',
        theme.colorScheme.primary,
      ),
      _ => (
        Icons.schedule,
        'Plazo moderado',
        'Buen balance para la mayoría de metas.',
        theme.colorScheme.secondary,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$daysUntil días desde hoy',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
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

  Widget _buildErrorText(BuildContext context, String error, ThemeData theme) {
    return Row(
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
    );
  }

  Future<void> _showDatePicker(
    BuildContext context,
    GoalCreationNotifier notifier,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      notifier.setDeadline(picked);
    }
  }
}
