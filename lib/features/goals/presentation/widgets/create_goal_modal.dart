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
class CreateGoalModal extends ConsumerStatefulWidget {
  const CreateGoalModal({super.key});

  @override
  ConsumerState<CreateGoalModal> createState() => _CreateGoalModalState();
}

class _CreateGoalModalState extends ConsumerState<CreateGoalModal>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final AnimationController _fadeController;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    // Reset state when modal opens
    ref.read(goalCreationProvider.notifier).reset();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pageController = PageController();

    // Start entrance animation
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalCreationProvider);
    final notifier = ref.read(goalCreationProvider.notifier);
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            (1 - _slideController.value) *
                MediaQuery.of(context).size.height *
                0.1,
          ),
          child: child,
        );
      },
      child: FadeTransition(
        opacity: _fadeController,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: 600,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                _buildHandleBar(context),

                // Header with progress
                _buildHeader(context, state),

                // Progress indicator
                _buildProgressIndicator(context, state),

                const SizedBox(height: 8),

                // Content area with page view
                Flexible(
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

                // Bottom action bar
                _buildBottomBar(context, state, notifier),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandleBar(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GoalCreationState state) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Close button
          IconButton(
            onPressed: () => _closeModal(),
            icon: const Icon(Icons.close),
            tooltip: 'Cerrar',
          ),

          const Spacer(),

          // Title
          Text(
            'Nueva Meta',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // Step counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${state.currentStep + 1}/${state.totalSteps}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    GoalCreationState state,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(state.totalSteps, (index) {
          final isCompleted = index < state.currentStep;
          final isCurrent = index == state.currentStep;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: EdgeInsets.only(
                right: index < state.totalSteps - 1 ? 8 : 0,
              ),
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Left button: Cancel (step 1) or Atrás (steps 2-5)
            Expanded(
              flex: 1,
              child: isFirstStep
                  ? TextButton(
                      onPressed: () => _closeModal(),
                      child: const Text('Cancelar'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: () => _goToPreviousStep(notifier),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Atrás'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
            ),

            const SizedBox(width: 12),

            // Continue/Create button
            Expanded(
              flex: 2,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLastStep
                    ? _buildCreateButton(context, state, notifier)
                    : _buildContinueButton(context, canProceed, notifier),
              ),
            ),
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
      icon: const Icon(Icons.arrow_forward),
      label: const Text('Continuar'),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
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
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.check),
      label: Text(state.isSubmitting ? 'Creando...' : 'Crear Meta'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
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
    _slideController.reverse();
    _fadeController.reverse().then((_) {
      if (mounted) {
        context.pop();
        // Reset state after closing
        ref.read(goalCreationProvider.notifier).reset();
      }
    });
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
        _closeModal();

        // Show success message
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
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage(e)),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: child,
    );
  }
}
