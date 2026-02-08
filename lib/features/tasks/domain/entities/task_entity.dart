import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_entity.freezed.dart';

/// Task status enum matching the backend.
enum TaskStatus { scheduled, completed, skipped }

/// Represents a task in the domain layer.
@freezed
abstract class TaskEntity with _$TaskEntity {
  const factory TaskEntity({
    required int id,
    required int goalId,
    String? goalTitle,
    required String title,
    String? description,
    required int order,
    required DateTime scheduledAt,
    required DateTime endAt,
    required int durationMinutes,
    required TaskStatus status,
    required bool isLocked,
    String? notes,
    DateTime? completedAt,
  }) = _TaskEntity;

  const TaskEntity._();

  /// Whether this task is still pending.
  bool get isPending => status == TaskStatus.scheduled;

  /// Whether this task is overdue.
  bool get isOverdue => isPending && scheduledAt.isBefore(DateTime.now());

  /// Whether this task is currently happening.
  bool get isActive {
    final now = DateTime.now();
    return isPending && scheduledAt.isBefore(now) && endAt.isAfter(now);
  }
}
