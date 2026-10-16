/// Centralized JSON converters and safe parsing utilities.
///
/// Provides type-safe conversion helpers for JSON serialization
/// that handle null values, type mismatches, and edge cases gracefully.
library;

import 'dart:convert';

// ═══════════════════════════════════════════════════════════
// SAFE JSON PARSERS
// ═══════════════════════════════════════════════════════════

/// Safely converts a dynamic value to String with fallback.
///
/// Handles: null, String, num (converts to string), other types (toString).
String safeString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value;
  if (value is num) return value.toString();
  return value.toString();
}

/// Safely converts a dynamic value to nullable String.
///
/// Returns null only if value is null, otherwise converts to String.
String? safeStringNullable(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

/// Safely converts a dynamic value to int with fallback.
///
/// Handles: null, int, double (truncates), String (parses), other types (fallback).
int safeInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    return parsed ?? fallback;
  }
  return fallback;
}

/// Safely converts a dynamic value to nullable int.
///
/// Returns null if value is null or cannot be parsed.
int? safeIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Safely converts a dynamic value to double with fallback.
///
/// Handles: null, double, int (converts), String (parses).
double safeDouble(dynamic value, {double fallback = 0.0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    return parsed ?? fallback;
  }
  return fallback;
}

/// Safely converts a dynamic value to nullable double.
///
/// Returns null if value is null or cannot be parsed.
double? safeDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Safely converts a dynamic value to bool with fallback.
///
/// Handles: null, bool, int (0=false, other=true), String ('true', '1', 'yes').
bool safeBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase().trim();
    return lower == 'true' || lower == '1' || lower == 'yes';
  }
  return fallback;
}

/// Safely converts a dynamic value to nullable bool.
///
/// Returns null if value is null, otherwise attempts conversion.
bool? safeBoolNullable(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase().trim();
    if (lower == 'true' || lower == '1' || lower == 'yes') return true;
    if (lower == 'false' || lower == '0' || lower == 'no') return false;
  }
  return null;
}

/// Safely converts a dynamic value to DateTime with fallback.
///
/// Handles: null, String (ISO8601), int (Unix timestamp ms), DateTime.
DateTime safeDateTime(dynamic value, {DateTime? fallback}) {
  final effectiveFallback = fallback ?? DateTime.now();
  if (value == null) return effectiveFallback;
  if (value is DateTime) return value;
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return effectiveFallback;
    }
  }
  if (value is int) {
    // Assume Unix timestamp in milliseconds
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  return effectiveFallback;
}

/// Safely converts a dynamic value to nullable DateTime.
///
/// Returns null if value is null or cannot be parsed.
DateTime? safeDateTimeNullable(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
  if (value is int) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } catch (_) {
      return null;
    }
  }
  return null;
}

// ═══════════════════════════════════════════════════════════
// DATE TIME ↔ STRING CONVERTERS (for API/DB)
// ═══════════════════════════════════════════════════════════

/// Converts DateTime to ISO8601 string (API format).
///
/// Always returns UTC format with 'Z' suffix for consistency.
String dateTimeToApiString(DateTime date) {
  return date.toUtc().toIso8601String();
}

/// Converts nullable DateTime to ISO8601 string.
///
/// Returns null if input is null.
String? dateTimeToApiStringNullable(DateTime? date) {
  if (date == null) return null;
  return date.toUtc().toIso8601String();
}

/// Parses ISO8601 string to DateTime (local timezone).
///
/// Handles empty strings by returning null.
DateTime? apiStringToDateTime(String? str) {
  if (str == null || str.isEmpty) return null;
  try {
    return DateTime.parse(str).toLocal();
  } catch (_) {
    return null;
  }
}

/// Parses ISO8601 string to DateTime with fallback.
///
/// Never returns null - uses fallback if parsing fails.
DateTime apiStringToDateTimeWithFallback(String str, DateTime fallback) {
  if (str.isEmpty) return fallback;
  try {
    return DateTime.parse(str).toLocal();
  } catch (_) {
    return fallback;
  }
}

/// Converts DateTime to Unix timestamp (seconds since epoch).
///
/// Used for Drift database storage.
int dateTimeToUnixSeconds(DateTime date) {
  return date.millisecondsSinceEpoch ~/ 1000;
}

/// Converts Unix timestamp to DateTime.
///
/// Used for Drift database retrieval.
DateTime unixSecondsToDateTime(int unixSeconds) {
  return DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
}

/// Converts DateTime to Unix timestamp (milliseconds).
int dateTimeToUnixMillis(DateTime date) {
  return date.millisecondsSinceEpoch;
}

/// Converts Unix timestamp (milliseconds) to DateTime.
DateTime unixMillisToDateTime(int unixMillis) {
  return DateTime.fromMillisecondsSinceEpoch(unixMillis);
}

// ═══════════════════════════════════════════════════════════
// JSON SERIALIZATION HELPERS
// ═══════════════════════════════════════════════════════════

/// Safely extracts a String from JSON map.
String jsonString(
  Map<String, dynamic> json,
  String key, {
  String fallback = '',
}) {
  return safeString(json[key], fallback: fallback);
}

/// Safely extracts a nullable String from JSON map.
String? jsonStringNullable(Map<String, dynamic> json, String key) {
  return safeStringNullable(json[key]);
}

/// Safely extracts an int from JSON map.
int jsonInt(Map<String, dynamic> json, String key, {int fallback = 0}) {
  return safeInt(json[key], fallback: fallback);
}

/// Safely extracts a nullable int from JSON map.
int? jsonIntNullable(Map<String, dynamic> json, String key) {
  return safeIntNullable(json[key]);
}

/// Safely extracts a double from JSON map.
double jsonDouble(
  Map<String, dynamic> json,
  String key, {
  double fallback = 0.0,
}) {
  return safeDouble(json[key], fallback: fallback);
}

/// Safely extracts a nullable double from JSON map.
double? jsonDoubleNullable(Map<String, dynamic> json, String key) {
  return safeDoubleNullable(json[key]);
}

/// Safely extracts a bool from JSON map.
bool jsonBool(Map<String, dynamic> json, String key, {bool fallback = false}) {
  return safeBool(json[key], fallback: fallback);
}

/// Safely extracts a nullable bool from JSON map.
bool? jsonBoolNullable(Map<String, dynamic> json, String key) {
  return safeBoolNullable(json[key]);
}

/// Safely extracts a DateTime from JSON map (from ISO8601 string).
DateTime jsonDateTime(
  Map<String, dynamic> json,
  String key, {
  DateTime? fallback,
}) {
  final str = jsonStringNullable(json, key);
  if (str == null) return fallback ?? DateTime.now();
  return apiStringToDateTimeWithFallback(str, fallback ?? DateTime.now());
}

/// Safely extracts a nullable DateTime from JSON map.
DateTime? jsonDateTimeNullable(Map<String, dynamic> json, String key) {
  final str = jsonStringNullable(json, key);
  return apiStringToDateTime(str);
}

/// Safely extracts a list from JSON map.
///
/// Applies converter function to each element.
List<T> jsonList<T>(
  Map<String, dynamic> json,
  String key,
  T Function(dynamic) converter, {
  List<T> fallback = const [],
}) {
  final value = json[key];
  if (value == null) return fallback;
  if (value is! List) return fallback;
  return value.map(converter).whereType<T>().toList();
}

/// Safely extracts a nullable list from JSON map.
List<T>? jsonListNullable<T>(
  Map<String, dynamic> json,
  String key,
  T Function(dynamic) converter,
) {
  final value = json[key];
  if (value == null) return null;
  if (value is! List) return null;
  final result = value.map(converter).whereType<T>().toList();
  return result.isEmpty ? null : result;
}

// ═══════════════════════════════════════════════════════════
// JSON ENCODING/DECODING HELPERS
// ═══════════════════════════════════════════════════════════

/// Safely encodes a value to JSON string.
///
/// Handles null values and encoding errors gracefully.
String safeJsonEncode(dynamic value) {
  if (value == null) return '{}';
  try {
    return jsonEncode(value);
  } catch (_) {
    return '{}';
  }
}

/// Safely decodes a JSON string to a Map.
///
/// Returns null if string is null, empty, or invalid JSON.
Map<String, dynamic>? safeJsonDecode(String? jsonString) {
  if (jsonString == null || jsonString.isEmpty) return null;
  try {
    final result = jsonDecode(jsonString);
    if (result is Map<String, dynamic>) return result;
    return null;
  } catch (_) {
    return null;
  }
}
