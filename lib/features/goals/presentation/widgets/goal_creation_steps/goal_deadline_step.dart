import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/features/goals/presentation/state/goal_creation_provider.dart';

/// Step 2: Deadline selection with calendar picker.
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
        // Icon header
        _buildHeader(context, theme),
        const SizedBox(height: 24),

        // Date picker card
        _buildDatePickerCard(context, state, notifier, theme),
        const SizedBox(height: 16),

        // Quick date options
        _buildQuickOptions(context, state, notifier, theme),

        // Error message
        if (state.errors['deadline'] != null) ...[
          const SizedBox(height: 12),
          _buildErrorText(context, state.errors['deadline']!, theme),
        ],
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.event,
            color: theme.colorScheme.onSecondaryContainer,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Cuándo quieres terminar?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Establece una fecha límite realista',
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

  Widget _buildDatePickerCard(
    BuildContext context,
    GoalCreationState state,
    GoalCreationNotifier notifier,
    ThemeData theme,
  ) {
    final isSelected = state.deadline != null;

    return InkWell(
      onTap: () => _pickDate(context, state, notifier),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSelected ? 'Fecha seleccionada' : 'Seleccionar fecha',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSelected
                        ? AppDateUtils.formatFull(state.deadline!)
                        : 'Toca para elegir',
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
            if (isSelected)
              Icon(Icons.check_circle, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickOptions(
    BuildContext context,
    GoalCreationState state,
    GoalCreationNotifier notifier,
    ThemeData theme,
  ) {
    final now = DateTime.now();
    final options = [
      ('1 semana', now.add(const Duration(days: 7))),
      ('2 semanas', now.add(const Duration(days: 14))),
      ('1 mes', now.add(const Duration(days: 30))),
      ('3 meses', now.add(const Duration(days: 90))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opciones rápidas',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final label = option.$1;
            final date = option.$2;
            final isSelected =
                state.deadline != null &&
                state.deadline!.year == date.year &&
                state.deadline!.month == date.month &&
                state.deadline!.day == date.day;

            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => notifier.setDeadline(date),
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
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

  Future<void> _pickDate(
    BuildContext context,
    GoalCreationState state,
    GoalCreationNotifier notifier,
  ) async {
    final now = DateTime.now();
    final initialDate = state.deadline ?? now.add(const Duration(days: 7));
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 365 * 2));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      notifier.setDeadline(picked);
    }
  }
}
