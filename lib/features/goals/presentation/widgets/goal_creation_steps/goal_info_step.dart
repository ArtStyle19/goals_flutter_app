import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/core/widgets/custom_text_field.dart';
import 'package:productivity/features/goals/presentation/state/goal_creation_provider.dart';

/// Step 1: Goal title and description input.
class GoalInfoStep extends ConsumerWidget {
  const GoalInfoStep({super.key});

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

        // Title input
        CustomTextField(
          controller: TextEditingController(text: state.title)
            ..selection = TextSelection.collapsed(offset: state.title.length),
          label: 'Título de la meta',
          hint: 'Ej: Aprender React, Terminar proyecto...',
          validator: (value) => state.errors['title'],
          onChanged: notifier.setTitle,
          textInputAction: TextInputAction.next,
          prefixIcon: Icon(
            Icons.flag_outlined,
            color: theme.colorScheme.primary,
          ),
        ),
        if (state.errors['title'] != null) ...[
          const SizedBox(height: 8),
          _buildErrorText(context, state.errors['title']!, theme),
        ],
        const SizedBox(height: 20),

        // Description input
        CustomTextField(
          controller: TextEditingController(text: state.description)
            ..selection = TextSelection.collapsed(
              offset: state.description.length,
            ),
          label: 'Descripción (opcional)',
          hint: 'Describe brevemente qué quieres lograr...',
          maxLines: 3,
          onChanged: notifier.setDescription,
          textInputAction: TextInputAction.done,
          prefixIcon: Icon(
            Icons.description_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),

        // Helper text
        _buildHelperCard(context, theme),
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
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.lightbulb_outline,
            color: theme.colorScheme.onPrimaryContainer,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '¿Qué meta quieres alcanzar?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Define un título claro y opcionalmente una descripción para tu meta.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
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

  Widget _buildHelperCard(BuildContext context, ThemeData theme) {
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
          Icon(
            Icons.tips_and_updates_outlined,
            color: theme.colorScheme.tertiary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tip: Un buen título es específico y medible. Ej: "Completar curso de Flutter" en lugar de "Aprender Flutter".',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
