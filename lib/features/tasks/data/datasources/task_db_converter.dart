/// Centralized converter between TaskModel and Drift database models.
///
/// Eliminates code duplication between TaskLocalDataSource and CalendarLocalDataSource.
/// All DateTime conversions use the centralized json_converters utilities.
library;

import 'package:drift/drift.dart';
import 'package:productivity/core/database/app_database.dart';
import 'package:productivity/core/utils/json_converters.dart';
import 'package:productivity/features/tasks/data/models/task_model.dart';

/// Converts Drift DB model to API TaskModel.
TaskModel dbToTaskModel(TaskDbModel db) {
  return TaskModel(
    id: db.id,
    goalId: db.goalId,
    goalTitle: db.goalTitle,
    title: db.title,
    description: db.description,
    order: db.order,
    scheduledAt: dateTimeToApiString(db.scheduledAt),
    endAt: db.endAt != null ? dateTimeToApiString(db.endAt!) : null,
    durationMinutes: db.durationMinutes,
    status: db.status,
    isLocked: db.isLocked,
    notes: db.notes,
    completedAt: db.completedAt != null
        ? dateTimeToApiString(db.completedAt!)
        : null,
  );
}

/// Converts API TaskModel to Drift companion for insertion.
///
/// Calculates endAt if not provided using scheduledAt + durationMinutes.
TasksCompanion taskModelToCompanion(TaskModel model) {
  final scheduled = apiStringToDateTime(model.scheduledAt)!;
  final duration = model.durationMinutes ?? 60;
  final end = model.endAt != null
      ? apiStringToDateTime(model.endAt!)!
      : scheduled.add(Duration(minutes: duration));

  return TasksCompanion(
    id: Value(model.id),
    goalId: Value(model.goalId),
    goalTitle: Value(model.goalTitle),
    title: Value(model.title),
    description: Value(model.description),
    order: Value(model.order),
    scheduledAt: Value(scheduled),
    endAt: Value(end),
    durationMinutes: Value(duration),
    status: Value(model.status),
    isLocked: Value(model.isLocked),
    notes: Value(model.notes),
    completedAt: Value(
      model.completedAt != null
          ? apiStringToDateTime(model.completedAt!)
          : null,
    ),
    cachedAt: Value(DateTime.now()),
  );
}
