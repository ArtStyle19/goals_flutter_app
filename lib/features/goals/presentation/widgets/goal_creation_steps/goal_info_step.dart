import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/core/widgets/custom_text_field.dart';
import 'package:productivity/features/goals/presentation/state/goal_creation_provider.dart';

/// Step 1: Goal title and description.
class GoalInfoStep extends ConsumerStatefulWidget {
  const GoalInfoStep({super.key});

  @override
  ConsumerState<GoalInfoStep> createState() => _GoalInfoStepState();
}

class _GoalInfoStepState extends ConsumerState<GoalInfoStep> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(goalCreationProvider);
    _titleController = TextEditingController(text: state.title);
    _descriptionController = TextEditingController(text: state.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalCreationProvider);
    final notifier = ref.read(goalCreationProvider.notifier);
    final theme = Theme.of(context);

    // Update controllers if state changed externally (e.g., when resetting)
    if (_titleController.text != state.title) {
      _titleController.text = state.title;
      _titleController.selection = TextSelection.collapsed(
        offset: state.title.length,
      );
    }
    if (_descriptionController.text != state.description) {
      _descriptionController.text = state.description;
      _descriptionController.selection = TextSelection.collapsed(
        offset: state.description.length,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon header
        _buildHeader(context, theme),
        const SizedBox(height: 24),

        // Title field
        CustomTextField(
          controller: _titleController,
          label: 'Título de la meta',
          hint: 'Ej: Aprender Flutter',
          onChanged: notifier.setTitle,
          textInputAction: TextInputAction.next,
          prefixIcon: Icon(
            Icons.flag_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (state.errors['title'] != null) ...[
          const SizedBox(height: 6),
          _buildErrorText(context, state.errors['title']!, theme),
        ],
        const SizedBox(height: 20),

        // Description field
        CustomTextField(
          controller: _descriptionController,
          label: 'Descripción (opcional)',
          hint: 'Describe los detalles de tu meta...',
          onChanged: notifier.setDescription,
          maxLines: 3,
          textInputAction: TextInputAction.done,
          prefixIcon: Icon(
            Icons.description_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Helper text
        _buildHelperCard(context, theme),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.edit_note,
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
                '¿Qué quieres lograr?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Define tu meta de forma clara y específica',
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
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outlined,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Un buen título te ayuda a mantener el enfoque. Sé específico pero conciso.',
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
