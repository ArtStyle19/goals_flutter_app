/// Keys used for secure/shared preferences storage.
library;

abstract final class StorageKeys {
  /// The authentication token stored in secure storage.
  static const String authToken = 'auth_token';

  /// The cached user data stored in shared preferences.
  static const String cachedUser = 'cached_user';

  /// Whether onboarding has been completed.
  static const String onboardingComplete = 'onboarding_complete';

  /// The user's preferred theme mode ('system', 'light', 'dark').
  static const String themeMode = 'theme_mode';
}
