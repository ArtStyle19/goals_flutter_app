/// Type converter for DateTime <-> int (Unix timestamp) in Drift.
///
/// Storing as INTEGER (Unix timestamp) is more efficient than TEXT (ISO8601)
/// and allows for easy date comparisons and indexing in SQL.
library;

import 'package:drift/drift.dart';

/// Converts DateTime to Unix timestamp (seconds since epoch) for storage.
final class DateTimeConverter extends TypeConverter<DateTime, int> {
  const DateTimeConverter();

  @override
  DateTime fromSql(int fromDb) {
    return DateTime.fromMillisecondsSinceEpoch(
      fromDb * 1000,
      isUtc: true,
    ).toLocal();
  }

  @override
  int toSql(DateTime value) {
    // Store in UTC to avoid timezone issues, convert to local on retrieval
    return value.toUtc().millisecondsSinceEpoch ~/ 1000;
  }
}
