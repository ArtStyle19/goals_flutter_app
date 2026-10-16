/// Drift table definition for Tasks.
///
/// Maps to the TaskModel structure for local caching.
/// Uses Unix timestamps for efficient date querying.
library;

import 'package:drift/drift.dart';

import 'package:productivity/core/database/converters/datetime_converter.dart';

/// Tasks table for local cache.
@DataClassName('TaskDbModel')
class Tasks extends Table {
  /// Unique identifier (primary key).
  IntColumn get id => integer()();

  /// Foreign key to the goal this task belongs to.
  IntColumn get goalId => integer()();

  /// Title of the goal (denormalized for display).
  TextColumn get goalTitle => text().nullable()();

  /// Task title.
  TextColumn get title => text()();

  /// Optional description.
  TextColumn get description => text().nullable()();

  /// Display order within the goal.
  IntColumn get order => integer().withDefault(const Constant(0))();

  /// When the task is scheduled (Unix timestamp).
  IntColumn get scheduledAt => integer().map(const DateTimeConverter())();

  /// When the task ends (Unix timestamp).
  IntColumn get endAt => integer().map(const DateTimeConverter())();

  /// Duration in minutes.
  IntColumn get durationMinutes => integer()();

  /// Status: scheduled, completed, skipped.
  TextColumn get status => text()();

  /// Whether the task is locked.
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();

  /// Optional notes.
  TextColumn get notes => text().nullable()();

  /// When the task was completed (Unix timestamp, nullable).
  IntColumn get completedAt =>
      integer().map(const DateTimeConverter()).nullable()();

  /// When this record was cached (for cache invalidation).
  IntColumn get cachedAt => integer().map(const DateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'tasks';
}
