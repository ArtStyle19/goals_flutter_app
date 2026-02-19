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
import 'package:productivity/core/services/fcm_service.dart';
import 'package:productivity/core/services/fcm_remote_datasource.dart';
import 'package:productivity/features/calendar/presentation/state/calendar_provider.dart';
import 'package:productivity/features/tasks/domain/repositories/task_repository.dart';
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

  // Initialize Firebase Cloud Messaging (FCM) with backend sync.
  final fcmService = _container.read(fcmServiceProvider);
  final fcmRemoteDataSource = _container.read(fcmRemoteDataSourceProvider);
  fcmService.setRemoteDataSource(fcmRemoteDataSource);
  fcmService.setRef(_container); // Set ref for task actions
  fcmService.onTaskAction = _onFCMTaskAction; // Set callback for FCM actions
  await fcmService.initialize();

  // Initialize local notifications for ongoing task notifications.
  await NotificationService.initialize(
    ianaTimezone: timezoneInterceptor.currentTimezone,
    onTap: _onNotificationTap,
    onComplete: _onNotificationComplete,
  );

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

/// Called when a task action is triggered from FCM notification (Complete/Skip).
void _onFCMTaskAction(int taskId, String action) async {
  dev.log('[Main] ╔══════════════════════════════════════════╗', name: 'fcm');
  dev.log('[Main] ║  _onFCMTaskAction CALLED                 ║', name: 'fcm');
  dev.log('[Main] ╚══════════════════════════════════════════╝', name: 'fcm');
  dev.log('[Main] taskId: $taskId', name: 'fcm');
  dev.log('[Main] action: $action', name: 'fcm');

  final router = _container.read(routerProvider);
  dev.log('[Main] Router obtained', name: 'fcm');

  // Execute the action first (before navigation)
  if (action == 'complete' || action == 'skip') {
    dev.log('[Main] Executing action: $action', name: 'fcm');
    try {
      dev.log('[Main] Reading taskRepositoryProvider...', name: 'fcm');
      final repository = _container.read(taskRepositoryProvider);
      dev.log('[Main] Repository obtained successfully', name: 'fcm');

      if (action == 'complete') {
        dev.log(
          '[Main] Calling completeTaskFromNotification($taskId)...',
          name: 'fcm',
        );
        await repository.completeTaskFromNotification(taskId);
        dev.log('[Main] ✅ Task $taskId completed successfully', name: 'fcm');
      } else if (action == 'skip') {
        dev.log(
          '[Main] Calling skipTaskFromNotification($taskId)...',
          name: 'fcm',
        );
        await repository.skipTaskFromNotification(taskId);
        dev.log('[Main] ✅ Task $taskId skipped successfully', name: 'fcm');
      }

      // Refresh providers to show updated state
      dev.log('[Main] Refreshing providers...', name: 'fcm');
      _container.invalidate(todayProvider);
      _container.invalidate(nextTaskProvider);
      _container.invalidate(taskDetailProvider(taskId));
      dev.log('[Main] ✅ Providers refreshed', name: 'fcm');
    } catch (e, stackTrace) {
      dev.log('[Main] ❌ Failed to execute task action: $e', name: 'fcm');
      dev.log('[Main] Stack trace: $stackTrace', name: 'fcm');
    }
  } else {
    dev.log(
      '[Main] Action is not complete/skip, skipping execution',
      name: 'fcm',
    );
  }

  // Navigate to task detail for all actions
  dev.log('[Main] Navigating to task detail...', name: 'fcm');
  final path = AppRoutes.taskDetail.replaceFirst(':id', '$taskId');
  dev.log('[Main] Path: $path', name: 'fcm');
  router.push(path);
  dev.log('[Main] ✅ Navigation completed', name: 'fcm');
}
