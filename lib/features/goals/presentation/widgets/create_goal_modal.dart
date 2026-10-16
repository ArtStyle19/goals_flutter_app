import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity/core/error/error_handler.dart';
import 'package:productivity/features/goals/presentation/state/goal_creation_provider.dart';
import 'package:productivity/features/goals/presentation/state/goals_provider.dart';
import 'package:productivity/features/goals/presentation/widgets/goal_creation_steps/goal_availability_step.dart';
import 'package:productivity/features/goals/presentation/widgets/goal_creation_steps/goal_deadline_step.dart';
import 'package:productivity/features/goals/presentation/widgets/goal_creation_steps/goal_duration_step.dart';
import 'package:productivity/features/goals/presentation/widgets/goal_creation_steps/goal_info_step.dart';
import 'package:productivity/features/goals/presentation/widgets/goal_creation_steps/goal_preview_step.dart';

/// Shows the create goal modal as a bottom sheet.
Future<void> showCreateGoalModal(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CreateGoalModal(),
  );
}

/// Main modal widget for creating a new goal.
/// Designed to match the app's card-based design system.
class CreateGoalModal extends ConsumerStatefulWidget {
  const CreateGoalModal({super.key});

  @override
  ConsumerState<CreateGoalModal> createState() => _CreateGoalModalState();
}

class _CreateGoalModalState extends ConsumerState<CreateGoalModal> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Reset state when modal opens
    ref.read(goalCreationProvider.notifier).reset();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalCreationProvider);
    final notifier = ref.read(goalCreationProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      constraints: BoxConstraints(
        maxHeight: screenSize.height * 0.85,
        maxWidth: 600,
        minWidth: 0,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              theme.dividerTheme.color ??
              colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context, state),

            // Progress indicator
            _buildStepIndicator(context, state),

            // Divider
            Divider(height: 1, color: theme.dividerTheme.color),

            // Content - takes available space
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => notifier.goToStep(index),
                children: const [
                  _StepWrapper(child: GoalInfoStep()),
                  _StepWrapper(child: GoalDeadlineStep()),
                  _StepWrapper(child: GoalDurationStep()),
                  _StepWrapper(child: GoalAvailabilityStep()),
                  _StepWrapper(child: GoalPreviewStep()),
                ],
              ),
            ),

            // Bottom bar - always at the bottom
            _buildBottomBar(context, state, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GoalCreationState state) {
    final theme = Theme.of(context);
    final isFirstStep = state.currentStep == 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          // Close/Back button
          IconButton(
            onPressed: () => _closeModal(),
            icon: Icon(isFirstStep ? Icons.close : Icons.arrow_back, size: 20),
            tooltip: isFirstStep ? 'Cerrar' : 'Atrás',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              padding: const EdgeInsets.all(8),
            ),
          ),

          const SizedBox(width: 12),

          // Title - left aligned like app bars
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nueva Meta',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Paso ${state.currentStep + 1} de ${state.totalSteps}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Step dots indicator
          _buildStepDots(context, state),
        ],
      ),
    );
  }

  Widget _buildStepDots(BuildContext context, GoalCreationState state) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(state.totalSteps, (index) {
        final isCompleted = index < state.currentStep;
        final isCurrent = index == state.currentStep;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isCurrent ? 20 : 6,
          height: 6,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: isCompleted || isCurrent
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildStepIndicator(BuildContext context, GoalCreationState state) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: state.progress,
          minHeight: 4,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    GoalCreationState state,
    GoalCreationNotifier notifier,
  ) {
    final isLastStep = state.currentStep == state.totalSteps - 1;
    final canProceed = state.canProceedToNext;
    final theme = Theme.of(context);
    final isFirstStep = state.currentStep == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color:
                theme.dividerTheme.color ??
                theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Left button: Cancel on first step, Back on other steps
            SizedBox(
              width: 100,
              child: isFirstStep
                  ? TextButton(
                      onPressed: () => _closeModal(),
                      child: const Text('Cancelar'),
                    )
                  : OutlinedButton.icon(
                      onPressed: () => _goToPreviousStep(notifier),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Atrás'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
            ),

            const Spacer(),

            // Continue/Create button - right aligned
            isLastStep
                ? _buildCreateButton(context, state, notifier)
                : _buildContinueButton(context, canProceed, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(
    BuildContext context,
    bool canProceed,
    GoalCreationNotifier notifier,
  ) {
    return FilledButton.icon(
      onPressed: canProceed ? () => _goToNextStep(notifier) : null,
      icon: const Icon(Icons.arrow_forward, size: 18),
      label: const Text('Continuar'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        minimumSize: const Size(140, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildCreateButton(
    BuildContext context,
    GoalCreationState state,
    GoalCreationNotifier notifier,
  ) {
    final theme = Theme.of(context);

    return FilledButton.icon(
      onPressed: state.isSubmitting
          ? null
          : () => _submitGoal(context, notifier),
      icon: state.isSubmitting
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.check, size: 18),
      label: Text(state.isSubmitting ? 'Creando...' : 'Crear Meta'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        minimumSize: const Size(160, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }

  void _goToNextStep(GoalCreationNotifier notifier) {
    if (notifier.validateCurrentStep()) {
      notifier.nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousStep(GoalCreationNotifier notifier) {
    notifier.previousStep();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _closeModal() {
    // Reset state before closing to avoid null check errors
    ref.read(goalCreationProvider.notifier).reset();
    if (mounted) {
      context.pop();
    }
  }

  Future<void> _submitGoal(
    BuildContext context,
    GoalCreationNotifier notifier,
  ) async {
    if (!notifier.validateCurrentStep()) return;

    notifier.setSubmitting(true);

    try {
      final goalData = notifier.buildGoalData();
      await ref
          .read(goalsProvider.notifier)
          .createGoal(
            title: goalData.title,
            description: goalData.description,
            deadline: goalData.deadline,
            sessionDurationMinutes: goalData.sessionDurationMinutes,
            availabilityRules: goalData.availabilityRules,
          );

      if (mounted) {
        // Close modal first, then show success message
        context.pop();

        // Show success message after modal is closed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('¡Meta creada exitosamente!'),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage(e)),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        notifier.setSubmitting(false);
      }
    }
  }
}

/// Wrapper for each step to provide consistent padding and scrolling.
class _StepWrapper extends StatelessWidget {
  final Widget child;

  const _StepWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: child,
    );
  }
}
