import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:productivity/app/router/routes.dart';
import 'package:productivity/app/theme/app_colors.dart';
import 'package:productivity/core/error/error_handler.dart';
import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/core/widgets/app_error_widget.dart';
import 'package:productivity/core/widgets/loading_widget.dart';
import 'package:productivity/features/calendar/presentation/state/calendar_provider.dart';
import 'package:productivity/features/tasks/domain/entities/task_entity.dart';

/// Calendar page with monthly view and task list per day.
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late ({DateTime from, DateTime to}) _currentRange;

  @override
  void initState() {
    super.initState();
    _updateRange();
  }

  void _updateRange() {
    final first = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final last = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    _currentRange = (from: first, to: last);
  }

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(calendarTasksProvider(_currentRange));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async => await ref
                .read(calendarTasksProvider(_currentRange).notifier)
                .refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Calendar Widget ───────────────────
          calendarAsync.when(
            loading: () => _buildCalendar([]),
            error: (_, _) => _buildCalendar([]),
            data: (data) => _buildCalendar(data.tasks),
          ),
          const Divider(height: 1),

          // ─── Task list for selected day ────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => await ref
                  .read(calendarTasksProvider(_currentRange).notifier)
                  .refresh(),
              child: calendarAsync.when(
                loading: () =>
                    const LoadingWidget(message: 'Cargando tareas...'),
                error: (e, _) => AppErrorWidget(
                  message: userFriendlyMessage(e),
                  onRetry: () async => await ref
                      .read(calendarTasksProvider(_currentRange).notifier)
                      .refresh(),
                ),
                data: (data) {
                  final dayTasks =
                      data.tasks.where((task) {
                        return isSameDay(task.scheduledAt, _selectedDay);
                      }).toList()..sort(
                        (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
                      );

                  if (dayTasks.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 48),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_available,
                                size: 48,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sin tareas para este día',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: dayTasks.length,
                    itemBuilder: (context, index) {
                      final task = dayTasks[index];
                      return _CalendarTaskTile(
                        task: task,
                        onTap: () => context.push(
                          AppRoutes.taskDetail.replaceFirst(
                            ':id',
                            '${task.id}',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(List<TaskEntity> tasks) {
    return TableCalendar<TaskEntity>(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
      },
      onFormatChanged: (format) {
        setState(() => _calendarFormat = format);
      },
      onPageChanged: (focused) {
        setState(() {
          _focusedDay = focused;
          _updateRange();
        });
      },
      eventLoader: (day) {
        return tasks.where((t) => isSameDay(t.scheduledAt, day)).toList();
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        markerSize: 6,
        markersMaxCount: 3,
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
      ),
      locale: 'es',
    );
  }
}

class _CalendarTaskTile extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;

  const _CalendarTaskTile({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (task.status) {
      TaskStatus.completed => AppColors.success,
      TaskStatus.skipped => AppColors.textSecondary,
      TaskStatus.scheduled when task.isOverdue => AppColors.error,
      TaskStatus.scheduled => AppColors.primary,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.status == TaskStatus.completed
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Text(
          [
            AppDateUtils.formatTimeRange(task.scheduledAt, task.endAt),
            if (task.goalTitle != null) task.goalTitle!,
          ].join(' · '),
        ),
        trailing: Icon(
          switch (task.status) {
            TaskStatus.completed => Icons.check_circle,
            TaskStatus.skipped => Icons.skip_next,
            TaskStatus.scheduled => Icons.schedule,
          },
          color: statusColor,
          size: 20,
        ),
      ),
    );
  }
}
