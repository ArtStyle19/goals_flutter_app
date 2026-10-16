/// Drift table definition for Goals.
///
/// Maps to the GoalModel structure for local caching.
library;

import 'package:drift/drift.dart';

import 'package:productivity/core/database/converters/datetime_converter.dart';

/// Goals table for local cache.
@DataClassName('GoalDbModel')
class Goals extends Table {
  /// Unique identifier (primary key).
  IntColumn get id => integer()();

  /// Goal title.
  TextColumn get title => text()();

  /// Optional description.
  TextColumn get description => text().nullable()();

  /// Deadline (Unix timestamp).
  IntColumn get deadline => integer().map(const DateTimeConverter())();

  /// Session duration in minutes.
  IntColumn get sessionDurationMinutes => integer()();

  /// Status: draft, active, completed.
  TextColumn get status => text()();

  /// Total number of sessions.
  IntColumn get totalSessions => integer().nullable()();

  /// Total hours planned.
  RealColumn get totalHours => real().nullable()();

  /// When the goal was completed (Unix timestamp, nullable).
  IntColumn get completedAt =>
      integer().map(const DateTimeConverter()).nullable()();

  /// Created at (Unix timestamp).
  IntColumn get createdAt => integer().map(const DateTimeConverter())();

  /// Updated at (Unix timestamp).
  IntColumn get updatedAt => integer().map(const DateTimeConverter())();

  /// Cached task count (denormalized for performance).
  IntColumn get tasksCount => integer().withDefault(const Constant(0))();

  /// Cached completed task count (denormalized for performance).
  IntColumn get completedTasksCount =>
      integer().withDefault(const Constant(0))();

  /// When this record was cached (for cache invalidation).
  IntColumn get cachedAt => integer().map(const DateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'goals';
}
