import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:productivity/app/app.dart';
import 'package:productivity/app/config/env_config.dart';
import 'package:productivity/app/di/injection_container.dart';
import 'package:productivity/app/router/app_router.dart';
import 'package:productivity/app/router/routes.dart';
import 'package:productivity/core/network/api_interceptors.dart';
import 'package:productivity/core/services/notification_service.dart';
import 'package:productivity/features/calendar/presentation/state/calendar_provider.dart';
import 'package:productivity/features/tasks/presentation/state/task_provider.dart';

/// Global [ProviderContainer] so notification callbacks (which run outside
/// the widget tree) can access Riverpod providers.
late final ProviderContainer _container;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file.
  await EnvConfig.load();
  EnvConfig.printConfig();

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

  // Initialize local notifications FIRST — this registers the single
  // response handler for both local and FCM notifications (the plugin
  // is a singleton so only the last `initialize()` call's handler wins).
  await NotificationService.initialize(
    ianaTimezone: timezoneInterceptor.currentTimezone,
    onTap: _onNotificationTap,
    onComplete: _onNotificationComplete,
    onFCMAction: _onFCMTaskAction,
  );

  // Initialize Firebase Cloud Messaging (FCM) with backend sync.
  // Must run AFTER NotificationService.initialize() so the plugin is
  // ready and channels can be created.
  final fcmService = _container.read(fcmServiceProvider);
  final fcmRemoteDataSource = _container.read(fcmRemoteDataSourceProvider);
  fcmService.setRemoteDataSource(fcmRemoteDataSource);
  fcmService.onTaskAction = _onFCMTaskAction;
  await fcmService.initialize();

  // Process any pending notification actions from background/terminated state.
  // This handles actions that were triggered when the app was not running.
  await fcmService.processPendingActions();

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
  } catch (_) {
    // Silently fail — the user can retry from the app.
  }
}

/// Called when a task action is triggered from FCM notification (Complete/Skip/Postpone).
///
/// This is the single entry point for all notification-triggered task actions.
/// FCMService delegates here to keep itself decoupled from business logic.
void _onFCMTaskAction(int taskId, String action) async {
  dev.log('[Main] ╔══════════════════════════════════════════╗', name: 'fcm');
  dev.log('[Main] ║  _onFCMTaskAction CALLED                 ║', name: 'fcm');
  dev.log('[Main] ╚══════════════════════════════════════════╝', name: 'fcm');
  dev.log('[Main] taskId: $taskId', name: 'fcm');
  dev.log('[Main] action: $action', name: 'fcm');

  // Execute the action via repository
  if (action == 'complete' || action == 'skip' || action == 'postpone') {
    dev.log('[Main] Executing action: $action', name: 'fcm');
    try {
      final repository = _container.read(taskRepositoryProvider);

      if (action == 'complete') {
        await repository.completeTask(
          taskId,
          notes: 'Completado desde notificación',
        );
        dev.log('[Main] ✅ Task $taskId completed successfully', name: 'fcm');
      } else if (action == 'skip') {
        await repository.skipTask(taskId, reason: 'Omitido desde notificación');
        dev.log('[Main] ✅ Task $taskId skipped successfully', name: 'fcm');
      } else {
        await repository.postponeTask(
          taskId,
          reason: 'Pospuesto desde notificación',
        );
        dev.log('[Main] ✅ Task $taskId postponed successfully', name: 'fcm');
      }

      // Dismiss the ongoing local notification for this task
      final service = _container.read(notificationServiceProvider);
      await service.dismissOngoingTask(taskId);

      // Refresh providers to show updated state
      _container.invalidate(todayProvider);
      _container.invalidate(nextTaskProvider);
      _container.invalidate(taskDetailProvider(taskId));
      dev.log('[Main] ✅ Providers refreshed', name: 'fcm');
    } catch (e, stackTrace) {
      dev.log('[Main] ❌ Failed to execute task action: $e', name: 'fcm');
      dev.log('[Main] Stack trace: $stackTrace', name: 'fcm');
    }
  }

  // Navigate to task detail
  final router = _container.read(routerProvider);
  final path = AppRoutes.taskDetail.replaceFirst(':id', '$taskId');
  dev.log('[Main] Navigating to: $path', name: 'fcm');
  router.push(path);
}
