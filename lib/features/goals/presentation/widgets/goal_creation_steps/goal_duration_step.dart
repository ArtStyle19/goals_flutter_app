import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/core/constants/app_constants.dart';
import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/features/goals/presentation/state/goal_creation_provider.dart';

/// Step 3: Session duration selection.
class GoalDurationStep extends ConsumerWidget {
  const GoalDurationStep({super.key});

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

        // Duration cards grid
        _buildDurationGrid(context, state, notifier, theme),
        const SizedBox(height: 24),

        // Info card
        _buildDurationInfoCard(context, state.sessionDuration, theme),
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
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.timer_outlined,
            color: theme.colorScheme.onTertiaryContainer,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '¿Cuánto tiempo por sesión?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona la duración ideal para cada sesión de trabajo.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDurationGrid(
    BuildContext context,
    GoalCreationState state,
    GoalCreationNotifier notifier,
    ThemeData theme,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: AppConstants.sessionDurations.length,
      itemBuilder: (context, index) {
        final duration = AppConstants.sessionDurations[index];
        final isSelected = state.sessionDuration == duration;

        return _DurationCard(
          duration: duration,
          isSelected: isSelected,
          onTap: () => notifier.setSessionDuration(duration),
          theme: theme,
        );
      },
    );
  }

  Widget _buildDurationInfoCard(
    BuildContext context,
    int duration,
    ThemeData theme,
  ) {
    final (icon, title, description) = _getDurationInfo(duration, theme);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
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

  (IconData, String, String) _getDurationInfo(int duration, ThemeData theme) {
    return switch (duration) {
      30 => (
        Icons.flash_on,
        'Sesión express',
        'Perfecta para mantener el enfoque y evitar fatiga.',
      ),
      45 => (
        Icons.bolt,
        'Sesión corta',
        'Ideal para tareas pequeñas o cuando tienes poco tiempo.',
      ),
      60 => (
        Icons.schedule,
        'Sesión estándar',
        'La duración clásica de Pomodoro extendido. Buen balance.',
      ),
      90 => (
        Icons.hourglass_bottom,
        'Sesión profunda',
        'Perfecta para trabajo que requiere concentración intensa.',
      ),
      120 => (
        Icons.timelapse,
        'Sesión extendida',
        'Para sesiones de trabajo profundo en bloques largos.',
      ),
      _ => (
        Icons.timer,
        'Sesión personalizada',
        'Selecciona la duración que mejor se adapte a ti.',
      ),
    };
  }
}

class _DurationCard extends StatelessWidget {
  final int duration;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _DurationCard({
    required this.duration,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Duration value
            Text(
              AppDateUtils.formatDuration(duration),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            // Label
            Text(
              _getDurationLabel(duration),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w500 : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 24 : 0,
              height: isSelected ? 24 : 0,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: theme.colorScheme.onPrimary,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _getDurationLabel(int duration) {
    return switch (duration) {
      30 => 'Express',
      45 => 'Corta',
      60 => 'Estándar',
      90 => 'Profunda',
      120 => 'Extendida',
      _ => 'Personalizada',
    };
  }
}
