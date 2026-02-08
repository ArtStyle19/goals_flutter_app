/// Application-wide constants.
library;

abstract final class AppConstants {
  /// Available session duration options in minutes.
  static const List<int> sessionDurations = [30, 45, 60, 90, 120];

  /// Days of the week for availability rules.
  static const List<String> weekDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  /// User-friendly day labels (Spanish).
  static const Map<String, String> dayLabels = {
    'monday': 'Lunes',
    'tuesday': 'Martes',
    'wednesday': 'Miércoles',
    'thursday': 'Jueves',
    'friday': 'Viernes',
    'saturday': 'Sábado',
    'sunday': 'Domingo',
  };

  /// Short day labels for compact UI.
  static const Map<String, String> dayShortLabels = {
    'monday': 'Lun',
    'tuesday': 'Mar',
    'wednesday': 'Mié',
    'thursday': 'Jue',
    'friday': 'Vie',
    'saturday': 'Sáb',
    'sunday': 'Dom',
  };
}
