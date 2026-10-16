/// Route path constants.
library;

abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String goals = '/goals';
  static const String goalDetail = '/goals/:id';
  static const String createGoal = '/goals/create';
  static const String goalStats = '/goals/:id/stats';
  static const String goalReplan = '/goals/:id/replan';
  static const String taskDetail = '/tasks/:id';
  static const String calendar = '/calendar';
  static const String today = '/today';
  static const String settings = '/settings';
}
