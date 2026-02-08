/// Useful Dart extensions for common types.
library;

/// Extension on [String] for common operations.
extension StringExtension on String {
  /// Capitalizes the first letter of the string.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Converts a string to title case.
  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }
}

/// Extension on [DateTime] for common operations.
extension DateTimeExtension on DateTime {
  /// Returns true if this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if this date is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Returns true if this date is in the future.
  bool get isFuture => isAfter(DateTime.now());

  /// Returns a new [DateTime] with only the date part (no time).
  DateTime get dateOnly => DateTime(year, month, day);

  /// Returns true if same day as [other].
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

/// Extension on [num] to create durations more readably.
extension DurationExtension on int {
  Duration get seconds => Duration(seconds: this);
  Duration get minutes => Duration(minutes: this);
  Duration get hours => Duration(hours: this);
  Duration get days => Duration(days: this);
}
