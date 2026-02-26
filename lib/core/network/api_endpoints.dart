/// API endpoint constants.
///
/// Centralizes all backend URL paths to avoid hardcoded strings
/// scattered throughout the data layer.
library;

abstract final class ApiEndpoints {
  // ─── Auth ───────────────────────────────────────────────
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String me = '/me';
  static const String googleAuth = '/auth/google';

  // ─── Goals ──────────────────────────────────────────────
  static const String goals = '/goals';
  static String goal(int id) => '/goals/$id';
  static String goalStats(int id) => '/goals/$id/stats';
  static String goalGenerate(int id) => '/goals/$id/generate';
  static String goalTasks(int id) => '/goals/$id/tasks';
  static String goalComplete(int id) => '/goals/$id/complete';
  static String goalAvailability(int id) => '/goals/$id/availability';
  static String goalDeadline(int id) => '/goals/$id/deadline';

  // ─── Tasks ──────────────────────────────────────────────
  static String task(int id) => '/tasks/$id';
  static String taskComplete(int id) => '/tasks/$id/complete';
  static String taskSkip(int id) => '/tasks/$id/skip';
  static String taskPostpone(int id) => '/tasks/$id/postpone';
  static String taskRecover(int id) => '/tasks/$id/recover';

  // ─── Calendar ───────────────────────────────────────────
  static const String calendar = '/calendar';
  static const String today = '/today';
  static const String nextTask = '/next';

  // ─── FCM Notifications ─────────────────────────────────
  static const String fcmToken = '/user/fcm-token';
  static const String testNotification = '/test-notification';
  static const String testNotificationWithActions =
      '/test-notification-with-actions';
  static const String notificationStatus = '/notification-status';
}
