/// Task status constants for the application.
///
/// Centralizes all task status values to avoid magic strings
/// and provide type safety and autocompletion.
library;

/// Enum representing the possible states of a task.
enum TaskStatus {
  /// Task is scheduled for the future.
  scheduled('scheduled'),

  /// Task has been completed successfully.
  completed('completed'),

  /// Task was skipped by the user.
  skipped('skipped'),

  /// Task is currently in progress.
  inProgress('in_progress');

  /// The string value used in API and database.
  final String value;

  const TaskStatus(this.value);

  /// Creates a [TaskStatus] from a string value.
  ///
  /// Returns [TaskStatus.scheduled] as default if the value is unknown
  /// or null to ensure the app doesn't crash on unexpected data.
  static TaskStatus fromString(String? value) {
    if (value == null) return TaskStatus.scheduled;

    return TaskStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TaskStatus.scheduled,
    );
  }

  /// Whether the task is in a final state (completed or skipped).
  bool get isFinal =>
      this == TaskStatus.completed || this == TaskStatus.skipped;

  /// Whether the task is still pending (scheduled or in progress).
  bool get isPending =>
      this == TaskStatus.scheduled || this == TaskStatus.inProgress;

  /// Whether the task can be completed.
  bool get canComplete => isPending;

  /// Whether the task can be skipped.
  bool get canSkip => isPending;
}

/// Extension to provide display names for task statuses.
extension TaskStatusDisplay on TaskStatus {
  /// Human-readable display name in Spanish.
  String get displayName {
    return switch (this) {
      TaskStatus.scheduled => 'Pendiente',
      TaskStatus.completed => 'Completada',
      TaskStatus.skipped => 'Omitida',
      TaskStatus.inProgress => 'En progreso',
    };
  }
}
