import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:productivity/app/app.dart';
import 'package:productivity/app/di/injection_container.dart';
import 'package:productivity/app/router/app_router.dart';
import 'package:productivity/app/router/routes.dart';
import 'package:productivity/core/network/api_interceptors.dart';
import 'package:productivity/core/services/notification_scheduler.dart';
import 'package:productivity/core/services/notification_service.dart';
import 'package:productivity/features/calendar/presentation/state/calendar_provider.dart';
import 'package:productivity/features/tasks/presentation/state/task_provider.dart';

/// Global [ProviderContainer] so notification callbacks (which run outside
/// the widget tree) can access Riverpod providers.
late final ProviderContainer _container;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data for Spanish date formatting.
  await initializeDateFormatting('es');

  // Initialize SharedPreferences before the app starts.
  final sharedPreferences = await SharedPreferences.getInstance();

  // Detect the device timezone (IANA identifier) for the X-Timezone header.
  final timezoneInterceptor = TimezoneInterceptor();
  await timezoneInterceptor.initialize();

  // Create the ProviderContainer early so callbacks can use it.
  _container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      timezoneInterceptorProvider.overrideWithValue(timezoneInterceptor),
    ],
  );

  // Initialize local notifications with the detected timezone + callbacks.
  await NotificationService.initialize(
    ianaTimezone: timezoneInterceptor.currentTimezone,
    onTap: _onNotificationTap,
    onComplete: _onNotificationComplete,
  );

  // Initialize the centralized notification scheduler.
  // It listens to auth state + app lifecycle to keep notifications in sync.
  _container.read(notificationSchedulerProvider).initialize();

  runApp(
    UncontrolledProviderScope(
      container: _container,
      child: const ProductivityApp(),
    ),
  );
}

// ─── Notification Callbacks ──────────────────────────────

/// Called when the user taps the notification body → navigate to task detail.
void _onNotificationTap(NotificationPayload payload) {
  final router = _container.read(routerProvider);
  final path = AppRoutes.taskDetail.replaceFirst(':id', '${payload.taskId}');
  router.push(path);
}

/// Called when the user taps "Completar" on an ongoing notification.
Future<void> _onNotificationComplete(int taskId) async {
  try {
    final notifier = _container.read(taskActionsProvider.notifier);
    await notifier.completeTask(taskId);

    // Dismiss the ongoing notification for this task.
    final service = _container.read(notificationServiceProvider);
    await service.dismissOngoingTask(taskId);

    // Refresh today data so the UI updates if visible.
    _container.invalidate(todayProvider);
    _container.invalidate(nextTaskProvider);

    // Re-sync notifications so the next active task gets a notification.
    _container.read(notificationSchedulerProvider).syncNow();
  } catch (_) {
    // Silently fail — the user can retry from the app.
  }
}
