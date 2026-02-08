/// Date formatting and utility helpers.
library;

import 'package:intl/intl.dart';

abstract final class AppDateUtils {
  /// Formats a [DateTime] to "dd MMM yyyy" (e.g., "15 Mar 2026").
  static String formatShort(DateTime date) {
    return DateFormat('dd MMM yyyy', 'es').format(date);
  }

  /// Formats a [DateTime] to "EEEE, dd 'de' MMMM" (e.g., "Lunes, 15 de Marzo").
  static String formatFull(DateTime date) {
    return DateFormat("EEEE, dd 'de' MMMM", 'es').format(date);
  }

  /// Formats a [DateTime] to API date format "yyyy-MM-dd".
  static String toApiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Formats a [DateTime] to time string "HH:mm".
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Formats a [DateTime] to time range "HH:mm - HH:mm".
  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  /// Returns a relative description like "Comienza en 45 minutos".
  static String relativeTime(DateTime target) {
    final now = DateTime.now();
    final difference = target.difference(now);

    if (difference.isNegative) {
      return 'Ya pasó';
    }

    if (difference.inMinutes < 1) {
      return 'Ahora mismo';
    }

    if (difference.inMinutes < 60) {
      return 'En ${difference.inMinutes} min';
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;
      final mins = difference.inMinutes % 60;
      if (mins == 0) return 'En $hours h';
      return 'En $hours h $mins min';
    }

    final days = difference.inDays;
    if (days == 1) return 'Mañana';
    return 'En $days días';
  }

  /// Returns days remaining until [deadline] from today.
  static int daysUntil(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(deadline.year, deadline.month, deadline.day);
    return target.difference(today).inDays;
  }

  /// Formats duration in minutes to a human-readable string.
  static String formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (remaining == 0) return '$hours h';
    return '$hours h $remaining min';
  }
}
