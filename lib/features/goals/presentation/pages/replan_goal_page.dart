import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity/app/theme/app_colors.dart';
import 'package:productivity/core/error/error_handler.dart';
import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/features/goals/domain/entities/goal_entity.dart';
import 'package:productivity/features/goals/presentation/state/goals_provider.dart';
import 'package:productivity/features/goals/presentation/widgets/availability_editor.dart';

/// Full-screen page for replanning a goal.
///
/// Allows the user to adjust deadline, availability, and description
/// before triggering the AI-powered replan. All changes are sent
/// atomically in a single request.
class ReplanGoalPage extends ConsumerStatefulWidget {
  final int goalId;

  const ReplanGoalPage({super.key, required this.goalId});

  @override
  ConsumerState<ReplanGoalPage> createState() => _ReplanGoalPageState();
}

class _ReplanGoalPageState extends ConsumerState<ReplanGoalPage> {
  // Editable state — initialized from the goal
  late DateTime _deadline;
  late Map<String, List<({String start, String end})>> _availability;
  late TextEditingController _descriptionController;
  bool _isSubmitting = false;

  // Track whether any field changed
  late DateTime _originalDeadline;
  late Map<String, List<({String start, String end})>> _originalAvailability;
  late String _originalDescription;

  bool _initialized = false;

  void _initFromGoal(GoalEntity goal) {
    if (_initialized) return;
    _initialized = true;

    _deadline = goal.deadline;
    _originalDeadline = goal.deadline;

    _originalDescription = goal.description ?? '';
    _descriptionController = TextEditingController(text: _originalDescription);

    // Convert AvailabilityRuleEntity list to grouped map
    _availability = {};
    _originalAvailability = {};
    for (final rule in goal.availabilityRules) {
      _availability.putIfAbsent(rule.day, () => []).add((
        start: rule.start,
        end: rule.end,
      ));
      _originalAvailability.putIfAbsent(rule.day, () => []).add((
        start: rule.start,
        end: rule.end,
      ));
    }
  }

  @override
  void dispose() {
    if (_initialized) _descriptionController.dispose();
    super.dispose();
  }

  // ─── Change Detection ───────────────────────────────────

  bool get _deadlineChanged =>
      _deadline.year != _originalDeadline.year ||
      _deadline.month != _originalDeadline.month ||
      _deadline.day != _originalDeadline.day;

  bool get _availabilityChanged {
    if (_availability.length != _originalAvailability.length) return true;
    for (final entry in _availability.entries) {
      final original = _originalAvailability[entry.key];
      if (original == null || original.length != entry.value.length)
        return true;
      for (int i = 0; i < entry.value.length; i++) {
        if (entry.value[i].start != original[i].start ||
            entry.value[i].end != original[i].end) {
          return true;
        }
      }
    }
    return false;
  }

  bool get _descriptionChanged =>
      _descriptionController.text.trim() != _originalDescription;

  int get _changesCount {
    int count = 0;
    if (_deadlineChanged) count++;
    if (_availabilityChanged) count++;
    if (_descriptionChanged) count++;
    return count;
  }

  // ─── Build ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final goalAsync = ref.watch(goalDetailProvider(widget.goalId));

    return goalAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(userFriendlyMessage(e))),
      ),
      data: (goal) {
        _initFromGoal(goal);
        return _buildPage(context, goal);
      },
    );
  }

  Widget _buildPage(BuildContext context, GoalEntity goal) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Replanificar'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // ─── Header ─────────────────────────────
                _buildHeader(context, theme, goal),
                const SizedBox(height: 20),

                // ─── Deadline Section ───────────────────
                _buildSectionTitle(theme, Icons.event, 'Fecha límite'),
                const SizedBox(height: 8),
                _buildDeadlineCard(context, theme),
                const SizedBox(height: 20),

                // ─── Availability Section ───────────────
                _buildSectionTitle(theme, Icons.access_time, 'Disponibilidad'),
                const SizedBox(height: 8),
                _buildAvailabilitySection(theme, goal),
                const SizedBox(height: 20),

                // ─── Description Section ────────────────
                _buildSectionTitle(
                  theme,
                  Icons.description_outlined,
                  'Descripción',
                ),
                const SizedBox(height: 8),
                _buildDescriptionCard(context, theme),
                const SizedBox(height: 20),

                // ─── Info Card ──────────────────────────
                _buildInfoCard(context, theme, goal),
              ],
            ),
          ),

          // ─── Bottom Action Bar ──────────────────────
          _buildBottomBar(context, theme, goal),
        ],
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, ThemeData theme, GoalEntity goal) {
    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ajusta lo que necesites y regenera tu plan',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

  // ─── Section Title ──────────────────────────────────────

  Widget _buildSectionTitle(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ─── Deadline Card ──────────────────────────────────────

  Widget _buildDeadlineCard(BuildContext context, ThemeData theme) {
    final isExpired = _deadline.isBefore(DateTime.now());
    final daysLeft = AppDateUtils.daysUntil(_deadline);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isExpired
              ? theme.colorScheme.error.withValues(alpha: 0.5)
              : _deadlineChanged
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _pickDeadline,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 20,
                color: isExpired
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppDateUtils.formatFull(_deadline),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isExpired ? theme.colorScheme.error : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isExpired
                          ? 'Expirada — selecciona una nueva fecha'
                          : '$daysLeft días restantes${_deadlineChanged ? ' (modificada)' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isExpired
                            ? theme.colorScheme.error
                            : _deadlineChanged
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline.isAfter(now.add(const Duration(days: 1)))
          ? _deadline
          : now.add(const Duration(days: 7)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  // ─── Availability Section (shared widget) ──────────────

  Widget _buildAvailabilitySection(ThemeData theme, GoalEntity goal) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _availabilityChanged
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AvailabilityEditor(
              availability: _availability,
              sessionDurationMinutes: goal.sessionDurationMinutes,
              onAvailabilityChanged: (updated) {
                setState(() => _availability = updated);
              },
              showSummary: true,
            ),
            if (_availabilityChanged)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Horario modificado',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
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

  // ─── Description Card ──────────────────────────────────

  Widget _buildDescriptionCard(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _descriptionChanged
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          controller: _descriptionController,
          onChanged: (_) => setState(() {}),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ajusta el enfoque de tu meta...',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.all(4),
          ),
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }

  // ─── Info Card ──────────────────────────────────────────

  Widget _buildInfoCard(
    BuildContext context,
    ThemeData theme,
    GoalEntity goal,
  ) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '¿Qué ocurrirá?',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildInfoItem(
              theme,
              Icons.check_circle,
              AppColors.success,
              '${goal.completedTasksCount} tareas completadas se mantienen',
            ),
            const SizedBox(height: 6),
            _buildInfoItem(
              theme,
              Icons.autorenew,
              theme.colorScheme.primary,
              '${goal.tasksCount - goal.completedTasksCount} tareas pendientes se reemplazan',
            ),
            const SizedBox(height: 6),
            _buildInfoItem(
              theme,
              Icons.auto_awesome,
              AppColors.warning,
              'La IA generará nuevas tareas adaptadas',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    ThemeData theme,
    IconData icon,
    Color color,
    String text,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Bottom Bar ─────────────────────────────────────────

  Widget _buildBottomBar(
    BuildContext context,
    ThemeData theme,
    GoalEntity goal,
  ) {
    final isExpired = _deadline.isBefore(DateTime.now());
    final hasAvailability = _availability.isNotEmpty;
    final canSubmit = !isExpired && hasAvailability && !_isSubmitting;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_changesCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_note,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_changesCount ${_changesCount == 1 ? 'cambio' : 'cambios'} antes de replanificar',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: canSubmit ? () => _submit(goal) : null,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome, size: 20),
                label: Text(
                  _isSubmitting ? 'Replanificando...' : 'Replanificar con IA',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Submit ─────────────────────────────────────────────

  Future<void> _submit(GoalEntity goal) async {
    setState(() => _isSubmitting = true);

    // Build only changed fields
    final newDesc = _descriptionController.text.trim();
    final descriptionChanged = newDesc != _originalDescription;

    List<AvailabilityRuleEntity>? rules;
    if (_availabilityChanged) {
      rules = [];
      _availability.forEach((day, slots) {
        for (final slot in slots) {
          rules!.add(
            AvailabilityRuleEntity(day: day, start: slot.start, end: slot.end),
          );
        }
      });
    }

    try {
      await ref
          .read(goalsProvider.notifier)
          .replanGoal(
            widget.goalId,
            description: descriptionChanged ? newDesc : null,
            deadline: _deadlineChanged ? _deadline : null,
            availabilityRules: rules,
          );
      if (mounted) {
        ref.invalidate(goalDetailProvider(widget.goalId));
        context.pop(true); // Return true = success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Plan regenerado exitosamente!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
