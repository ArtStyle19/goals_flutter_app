/// Form validation helpers.
library;

abstract final class Validators {
  /// Validates that a field is not empty.
  static String? required(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio.';
    }
    return null;
  }

  /// Validates a valid email format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es obligatorio.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un email válido.';
    }
    return null;
  }

  /// Validates password with minimum length.
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria.';
    }
    if (value.length < minLength) {
      return 'La contraseña debe tener al menos $minLength caracteres.';
    }
    return null;
  }

  /// Validates that two passwords match.
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña.';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }

  /// Validates that a title has a minimum and maximum length.
  static String? title(
    String? value, {
    int minLength = 3,
    int maxLength = 100,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'El título es obligatorio.';
    }
    if (value.trim().length < minLength) {
      return 'El título debe tener al menos $minLength caracteres.';
    }
    if (value.trim().length > maxLength) {
      return 'El título no puede tener más de $maxLength caracteres.';
    }
    return null;
  }
}
