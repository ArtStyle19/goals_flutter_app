import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/core/constants/app_constants.dart';
import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/features/goals/presentation/state/goal_creation_provider.dart';

/// Step 5: Visual weekly calendar preview showing sessions as blocks.
class GoalPreviewStep extends ConsumerWidget {
  const GoalPreviewStep({super.key});

  static const int _startHour = 6; // 6 AM
  static const int _endHour = 22; // 10 PM
  static const double _hourHeight = 50; // Height per hour in the grid

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalCreationProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with deadline
        _buildHeader(context, state, theme),
        const SizedBox(height: 16),

        // Visual weekly calendar
        Flexible(child: _buildVisualCalendar(context, state, theme)),

        // Summary
        _buildSummary(context, state, theme),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    GoalCreationState state,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.calendar_view_week,
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
                'Vista previa del horario',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Meta: ${state.title}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            AppDateUtils.formatShort(state.deadline!),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisualCalendar(
    BuildContext context,
    GoalCreationState state,
    ThemeData theme,
  ) {
    final sessions = _calculateSessions(state);
    final totalHours = _endHour - _startHour;
    final gridHeight = totalHours * _hourHeight;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day headers
            _buildDayHeaders(theme),

            // Scrollable calendar grid
            Flexible(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: gridHeight,
                  child: Row(
                    children: [
                      // Time column (hours)
                      _buildTimeColumn(theme),

                      // Days columns
                      ...AppConstants.weekDays.map((day) {
                        final daySessions = sessions
                            .where((s) => s.day == day)
                            .toList();
                        return Expanded(
                          child: _buildDayColumn(
                            day,
                            daySessions,
                            theme,
                            state.sessionDuration,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayHeaders(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // Empty corner cell
          SizedBox(
            width: 50,
            child: Center(
              child: Text(
                'Hora',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Day headers
          ...AppConstants.weekDays.map((day) {
            final shortLabel = AppConstants.dayShortLabels[day]!;
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    shortLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(ThemeData theme) {
    return Container(
      width: 50,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        children: List.generate(_endHour - _startHour, (index) {
          final hour = _startHour + index;
          return Container(
            height: _hourHeight,
            padding: const EdgeInsets.only(right: 8),
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  height: 1,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayColumn(
    String day,
    List<_Session> sessions,
    ThemeData theme,
    int sessionDuration,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Stack(
        children: [
          // Hour grid lines
          Column(
            children: List.generate(_endHour - _startHour, (index) {
              return Container(
                height: _hourHeight,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          // Session blocks
          ...sessions.map((session) {
            final startMinutesFrom6AM =
                session.startMinutes - (_startHour * 60);
            final top = (startMinutesFrom6AM / 60) * _hourHeight;
            final height = (session.durationMinutes / 60) * _hourHeight;

            return Positioned(
              top: top,
              left: 2,
              right: 2,
              height: height,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: height > 25
                    ? Center(
                        child: Text(
                          session.isShort
                              ? '${session.startTime}'
                              : '${session.startTime}\n${session.endTime}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                            height: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<_Session> _calculateSessions(GoalCreationState state) {
    final sessions = <_Session>[];
    final sessionDuration = state.sessionDuration;

    state.availability.forEach((day, slots) {
      for (final slot in slots) {
        final startParts = slot.start.split(':');
        final endParts = slot.end.split(':');
        final startHour = int.parse(startParts[0]);
        final startMin = int.parse(startParts[1]);
        final endHour = int.parse(endParts[0]);
        final endMin = int.parse(endParts[1]);

        // Calculate how many sessions fit in this slot
        final startMinutes = startHour * 60 + startMin;
        final endMinutes = endHour * 60 + endMin;
        final totalMinutes = endMinutes - startMinutes;
        final numSessions = totalMinutes ~/ sessionDuration;

        // Create session objects
        for (int i = 0; i < numSessions; i++) {
          final sessionStartMinutes = startMinutes + (i * sessionDuration);
          final sessionEndMinutes = sessionStartMinutes + sessionDuration;

          final sessionStartHour = sessionStartMinutes ~/ 60;
          final sessionStartMin = sessionStartMinutes % 60;
          final sessionEndHour = sessionEndMinutes ~/ 60;
          final sessionEndMin = sessionEndMinutes % 60;

          sessions.add(
            _Session(
              day: day,
              startTime:
                  '${sessionStartHour.toString().padLeft(2, '0')}:${sessionStartMin.toString().padLeft(2, '0')}',
              endTime:
                  '${sessionEndHour.toString().padLeft(2, '0')}:${sessionEndMin.toString().padLeft(2, '0')}',
              startMinutes: sessionStartMinutes,
              durationMinutes: sessionDuration,
            ),
          );
        }
      }
    });

    return sessions;
  }

  Widget _buildSummary(
    BuildContext context,
    GoalCreationState state,
    ThemeData theme,
  ) {
    // Calculate totals
    int totalSessions = 0;
    int totalMinutes = 0;
    int daysWithSlots = 0;

    state.availability.forEach((day, slots) {
      if (slots.isNotEmpty) {
        daysWithSlots++;
        for (final slot in slots) {
          final startParts = slot.start.split(':');
          final endParts = slot.end.split(':');
          final startMinutes =
              int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
          final endMinutes =
              int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
          final slotMinutes = endMinutes - startMinutes;
          totalMinutes += slotMinutes;
          totalSessions += slotMinutes ~/ state.sessionDuration;
        }
      }
    });

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.onTertiaryContainer.withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: theme.colorScheme.onTertiaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Todo listo!',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$totalSessions sesiones de ${state.sessionDuration}min en $daysWithSlots días',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer.withValues(
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

/// Session data class for visual calendar.
class _Session {
  final String day;
  final String startTime;
  final String endTime;
  final int startMinutes;
  final int durationMinutes;

  _Session({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.startMinutes,
    required this.durationMinutes,
  });

  bool get isShort => durationMinutes <= 30;
}
