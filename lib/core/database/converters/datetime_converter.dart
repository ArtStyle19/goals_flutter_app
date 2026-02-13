/// Type converter for DateTime <-> int (Unix timestamp) in Drift.
///
/// Storing as INTEGER (Unix timestamp) is more efficient than TEXT (ISO8601)
/// and allows for easy date comparisons and indexing in SQL.
///
/// Uses centralized utilities from [json_converters.dart] to ensure
/// consistency across the entire app and avoid code duplication.
library;

import 'package:drift/drift.dart';
import 'package:productivity/core/utils/json_converters.dart';

/// Converts DateTime to Unix timestamp (seconds since epoch) for storage.
///
/// Delegates to centralized [unixSecondsToDateTime] and [dateTimeToUnixSeconds]
/// to ensure consistent DateTime handling across all layers.
final class DateTimeConverter extends TypeConverter<DateTime, int> {
  const DateTimeConverter();

  @override
  DateTime fromSql(int fromDb) {
    return unixSecondsToDateTime(fromDb);
  }

  @override
  int toSql(DateTime value) {
    return dateTimeToUnixSeconds(value);
  }
}
