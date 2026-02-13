/// Drift table definition for Availability Rules.
///
/// Represents the 1:N relationship with Goals.
/// Each goal can have multiple availability rules (days/times).
library;

import 'package:drift/drift.dart';

/// Availability rules table for local cache.
@DataClassName('AvailabilityRuleDbModel')
class AvailabilityRules extends Table {
  /// Auto-increment local ID (not the same as server ID).
  IntColumn get localId => integer().autoIncrement()();

  /// Foreign key to the goal this rule belongs to.
  IntColumn get goalId => integer()();

  /// Day of week (e.g., "monday", "tuesday").
  TextColumn get day => text()();

  /// Start time in HH:mm format.
  TextColumn get start => text()();

  /// End time in HH:mm format.
  TextColumn get end => text()();

  @override
  String? get tableName => 'availability_rules';
}
