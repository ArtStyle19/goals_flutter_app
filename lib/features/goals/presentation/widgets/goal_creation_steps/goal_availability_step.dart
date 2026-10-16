import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/features/goals/presentation/state/goal_creation_provider.dart';
import 'package:productivity/features/goals/presentation/widgets/availability_editor.dart';

/// Step 4: Availability selection.
///
/// Delegates all UI to the shared [AvailabilityEditor] widget and
/// bridges callbacks to the [GoalCreationNotifier].
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
          _buildHeader(theme, state.sessionDuration),
          const SizedBox(height: 24),

          // Shared availability editor
          AvailabilityEditor(
            availability: state.availability,
            sessionDurationMinutes: state.sessionDuration,
            onAvailabilityChanged: (updated) =>
                notifier.setAvailability(updated),
            errorText: state.errors['availability'],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, int sessionDuration) {
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
}
