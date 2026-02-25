import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:productivity/app/di/injection_container.dart';
import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/features/tasks/domain/entities/task_entity.dart';

// ═══════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════

/// SharedPreferences key for the notifications-enabled toggle.
const _kNotificationsEnabled = 'notifications_enabled';

/// Android notification channel IDs.
abstract final class NotificationChannels {
  /// 15-minute-before reminders.
  static const reminders = 'task_reminders';

  /// Persistent notification while a task is in progress.
  static const activeTasks = 'active_tasks';

  /// Test notifications for configuration/testing.
  static const testNotifications = 'test_notifications';
}

/// Action identifiers attached to notification buttons.
///
/// Used by **both** local ongoing-task notifications and FCM-originated
/// notifications shown via [FlutterLocalNotificationsPlugin].
abstract final class NotificationActions {
  /// User tapped "Completar".
  static const completeTask = 'complete_task';

  /// User tapped "Omitir" (FCM notifications only).
  static const skipTask = 'skip_task';
}

/// Offset added to a task ID so that the *ongoing* notification uses a
/// different system-notification-ID than the *reminder* for the same task.
const _ongoingIdOffset = 100000;

/// Offset for test notification IDs to avoid conflicts with task notifications.
const _testIdOffset = 200000;

/// SharedPreferences key for storing scheduled test notifications.
const _kScheduledTestNotifications = 'scheduled_test_notifications';

/// Payload action identifier for test notifications.
abstract final class TestNotificationActions {
  static const instant = 'test_instant';
  static const scheduled = 'test_scheduled';
}

// ═══════════════════════════════════════════════════════════
// NOTIFICATION PAYLOAD
// ═══════════════════════════════════════════════════════════

/// Structured payload serialized as JSON in the notification's `payload`
/// field.  Keeps routing and action-handling type-safe.
///
/// Supports two payload formats:
/// - **Local notifications**: `{"taskId": 42, "action": "..."}`
/// - **FCM data payloads**: `{"task_id": "42", "type": "task_start", ...}`
class NotificationPayload {
  final int taskId;
  final String? action;

  /// `true` when this payload was deserialized from an FCM data message
  /// (contains `task_id` + `type`), `false` for local payloads.
  final bool fromFCM;

  const NotificationPayload({
    required this.taskId,
    this.action,
    this.fromFCM = false,
  });

  factory NotificationPayload.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;

    // Detect origin: FCM payloads use 'task_id' (snake_case) + 'type'.
    final isFCM = map.containsKey('task_id') && map.containsKey('type');

    // Support both local format (taskId as int) and FCM format (task_id as String)
    final rawTaskId = map['taskId'] ?? map['task_id'];
    if (rawTaskId == null) {
      throw FormatException('Payload missing taskId/task_id: $json');
    }
    final taskId = rawTaskId is int
        ? rawTaskId
        : int.parse(rawTaskId.toString());

    return NotificationPayload(
      taskId: taskId,
      action: map['action'] as String?,
      fromFCM: isFCM,
    );
  }

  String toJson() => jsonEncode({'taskId': taskId, 'action': action});
}

// ═══════════════════════════════════════════════════════════
// CALLBACK TYPEDEFS
// ═══════════════════════════════════════════════════════════

/// Called when the user taps a notification body → navigate to task.
typedef OnNotificationTap = void Function(NotificationPayload payload);

/// Called when the user taps the "Completar" action button on a local
/// ongoing-task notification.
typedef OnCompleteAction = Future<void> Function(int taskId);

/// Called when the user taps an action button on an FCM notification
/// (Complete or Skip). Receives the taskId and action name.
typedef OnFCMTaskAction = void Function(int taskId, String action);

// ═══════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════

/// Provider that exposes the singleton [NotificationService].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(sharedPreferencesProvider));
});

/// Provider that tracks whether notifications are enabled.
final notificationsEnabledProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(_kNotificationsEnabled) ?? true;
});

// ═══════════════════════════════════════════════════════════
// SERVICE
// ═══════════════════════════════════════════════════════════

/// Manages local notifications for task reminders, active-task progress,
/// and quick-complete actions.
///
/// ### Architecture
///
/// ```
/// ┌──────────────────────────────────┐
/// │       NotificationService        │
/// ├──────────────────────────────────┤
/// │ Channels:                        │
/// │  • task_reminders   (high)       │
/// │  • active_tasks     (low/ongoing)│
/// ├──────────────────────────────────┤
/// │ Actions:                         │
/// │  • complete_task → API call      │
/// ├──────────────────────────────────┤
/// │ Payload:                         │
/// │  { taskId, action }  (JSON)      │
/// └──────────────────────────────────┘
/// ```
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  final SharedPreferences _prefs;

  /// Exposes the shared [FlutterLocalNotificationsPlugin] instance so that
  /// other services (e.g. [FCMService]) can **show** notifications through
  /// it without calling `initialize()` a second time (which would overwrite
  /// the response handler registered here).
  static FlutterLocalNotificationsPlugin get plugin => _plugin;

  /// Callbacks set once during [initialize].
  static OnNotificationTap? _onTap;
  static OnCompleteAction? _onComplete;
  static OnFCMTaskAction? _onFCMAction;

  /// Tracks scheduled reminder notification IDs so we can cancel only
  /// reminders without touching ongoing task notifications.
  static final Set<int> _scheduledReminderIds = {};

  /// Tracks scheduled test notification IDs.
  static final Set<int> _scheduledTestIds = {};

  /// Android implementation for checking exact alarm permission.
  static AndroidFlutterLocalNotificationsPlugin? _androidPlugin;

  NotificationService(this._prefs);

  /// Whether the user has enabled notifications.
  bool get isEnabled => _prefs.getBool(_kNotificationsEnabled) ?? true;

  // ─── Initialization ────────────────────────────────────

  /// Initializes timezone data, the notification plugin, channels, and
  /// action callbacks.
  ///
  /// Must be called **once** at app startup, before any notification is
  /// scheduled or shown.
  ///
  /// * [ianaTimezone] – IANA timezone from `flutter_timezone`.
  /// * [onTap]        – called when the user taps the notification body.
  /// * [onComplete]   – called when the user taps "Completar" on a **local**
  ///                    ongoing-task notification.
  /// * [onFCMAction]  – called when the user taps an action button on an
  ///                    **FCM** notification (Complete or Skip).
  static Future<void> initialize({
    required String ianaTimezone,
    OnNotificationTap? onTap,
    OnCompleteAction? onComplete,
    OnFCMTaskAction? onFCMAction,
  }) async {
    _onTap = onTap;
    _onComplete = onComplete;
    _onFCMAction = onFCMAction;

    // Timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(ianaTimezone));

    // Android initialization
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Darwin (iOS / macOS)
    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [
        // Category for local ongoing-task notifications (Completar only).
        DarwinNotificationCategory(
          'active_task',
          actions: [
            DarwinNotificationAction.plain(
              NotificationActions.completeTask,
              'Completar',
              options: {DarwinNotificationActionOption.foreground},
            ),
          ],
        ),
        // Category for FCM task notifications (Completar + Omitir).
        DarwinNotificationCategory(
          'task_actions',
          actions: [
            DarwinNotificationAction.plain(
              NotificationActions.completeTask,
              'Completar',
              options: {DarwinNotificationActionOption.foreground},
            ),
            DarwinNotificationAction.plain(
              NotificationActions.skipTask,
              'Omitir',
              options: {DarwinNotificationActionOption.foreground},
            ),
          ],
        ),
      ],
    );

    await _plugin.initialize(
      InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: _handleResponse,
      onDidReceiveBackgroundNotificationResponse: _handleBackgroundResponse,
    );

    // Request Android 13+ notification permission.
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // Store Android plugin reference for exact alarm checks.
    _androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // Create notification channels for Android.
    await _createNotificationChannels();
  }

  // ─── Android Notification Channels ─────────────────────

  /// Creates all required notification channels for Android.
  static Future<void> _createNotificationChannels() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return;

    // Test notifications channel - high importance for sound and vibration.
    final testChannel = AndroidNotificationChannel(
      NotificationChannels.testNotifications,
      'Test de Notificaciones',
      description: 'Notificaciones de prueba con sonido y vibración',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
    );

    await androidPlugin.createNotificationChannel(testChannel);
    dev.log('[NotificationService] Created test notification channel');
  }

  // ─── Exact Alarm Permission (Android 12+) ──────────────

  /// Checks if the app has permission to schedule exact alarms.
  /// Required for Android 12+ (API 31+).
  static Future<bool> canScheduleExactAlarms() async {
    if (_androidPlugin == null) return true; // iOS or not initialized.

    try {
      final canSchedule = await _androidPlugin!.canScheduleExactNotifications();
      dev.log('[NotificationService] Can schedule exact alarms: $canSchedule');
      return canSchedule ?? false;
    } catch (e) {
      dev.log(
        '[NotificationService] Error checking exact alarm permission: $e',
      );
      return false;
    }
  }

  /// Opens system settings to request exact alarm permission.
  /// Returns true if the permission was granted after the user returned.
  static Future<bool> requestExactAlarmPermission() async {
    if (_androidPlugin == null) return true; // iOS or not initialized.

    try {
      await _androidPlugin!.requestExactAlarmsPermission();
      // Check again after user returns from settings.
      return await canScheduleExactAlarms();
    } catch (e) {
      dev.log(
        '[NotificationService] Error requesting exact alarm permission: $e',
      );
      return false;
    }
  }

  // ─── Response Handlers ─────────────────────────────────

  /// Handles notification interaction in the foreground or when the app
  /// is opened from a notification tap.
  ///
  /// This is the **single** response handler for both local and FCM
  /// notifications because [FlutterLocalNotificationsPlugin] is a
  /// singleton — only the **last** `initialize()` call's handler is active.
  static void _handleResponse(NotificationResponse response) {
    dev.log(
      '[NotificationService] Response: actionId=${response.actionId}, '
      'payload=${response.payload}',
    );

    final payload = _parsePayload(response.payload);
    if (payload == null) return;

    // ── FCM-originated notifications ────────────────────
    // FCM payloads contain 'task_id' (snake_case) and extra fields like
    // 'type', 'show_actions', etc.  Local payloads contain 'taskId'.
    if (payload.fromFCM) {
      dev.log(
        '[NotificationService] FCM payload detected for taskId=${payload.taskId}',
      );

      if (response.actionId == NotificationActions.completeTask) {
        dev.log('[NotificationService] FCM action: COMPLETE');
        _onFCMAction?.call(payload.taskId, 'complete');
        return;
      }

      if (response.actionId == NotificationActions.skipTask) {
        dev.log('[NotificationService] FCM action: SKIP');
        _onFCMAction?.call(payload.taskId, 'skip');
        return;
      }

      // Body tap on FCM notification → open task.
      dev.log('[NotificationService] FCM action: OPEN (body tap)');
      _onFCMAction?.call(payload.taskId, 'open');
      return;
    }

    // ── Local ongoing-task notifications ─────────────────
    if (response.actionId == NotificationActions.completeTask) {
      dev.log('[NotificationService] Local action: COMPLETE');
      _onComplete?.call(payload.taskId);
      return;
    }

    // Default: tap on notification body → navigate to task detail.
    _onTap?.call(payload);
  }

  /// Handles notification interaction in the background.
  ///
  /// Must be a top-level or static function (plugin requirement).
  /// The full Riverpod container is not available here, so complex
  /// actions are deferred until the app re-opens.
  @pragma('vm:entry-point')
  static void _handleBackgroundResponse(NotificationResponse response) {
    // Background handling is limited — no DI container available.
    // The tap will re-launch the app where _handleResponse takes over.
  }

  static NotificationPayload? _parsePayload(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return NotificationPayload.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  // ─── Preferences ───────────────────────────────────────

  /// Toggles notifications on or off and persists the preference.
  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool(_kNotificationsEnabled, enabled);
    if (!enabled) await cancelAll();
  }

  // ─── Scheduled Reminders ───────────────────────────────

  /// Schedules a reminder 15 minutes before a task starts.
  ///
  /// Only schedules if the task is in the future and notifications are
  /// enabled.
  Future<void> scheduleTaskReminder(TaskEntity task) async {
    if (!isEnabled) return;

    final reminderTime = task.scheduledAt.subtract(const Duration(minutes: 15));
    if (reminderTime.isBefore(DateTime.now())) return;

    final tzSchedule = tz.TZDateTime.from(reminderTime, tz.local);
    final payload = NotificationPayload(taskId: task.id);

    final timeRange = AppDateUtils.formatTimeRange(
      task.scheduledAt,
      task.endAt,
    );
    final duration = AppDateUtils.formatDuration(task.durationMinutes);

    const title = 'Próxima sesión';
    final body = '${task.title} comienza en 15 minutos';
    final detail =
        '${task.title}\n'
        '$timeRange  ·  $duration'
        '${task.goalTitle != null ? '\n${task.goalTitle}' : ''}';

    await _plugin.zonedSchedule(
      task.id,
      title,
      body,
      tzSchedule,
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.reminders,
          'Recordatorios de tareas',
          channelDescription:
              'Notificaciones 15 minutos antes de cada tarea programada',
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFF6366F1), // AppColors.primary
          category: AndroidNotificationCategory.reminder,
          styleInformation: BigTextStyleInformation(
            detail,
            contentTitle: title,
            summaryText: task.goalTitle ?? 'Productivity Planner',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      payload: payload.toJson(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    _scheduledReminderIds.add(task.id);
  }

  /// Schedules reminders for a list of tasks.
  ///
  /// Only cancels previously scheduled **reminders** — ongoing task
  /// notifications are left untouched.
  Future<void> scheduleAll(List<TaskEntity> tasks) async {
    if (!isEnabled) return;

    // Cancel only previously scheduled reminders, not ongoing notifications.
    await _cancelAllReminders();

    final upcoming = tasks.where(
      (t) => t.isPending && t.scheduledAt.isAfter(DateTime.now()),
    );

    for (final task in upcoming) {
      await scheduleTaskReminder(task);
    }
  }

  // ─── Ongoing (Active Task) Notification ────────────────

  /// Shows a persistent **ongoing** notification for a task that is
  /// currently in progress.
  ///
  /// Displays:
  /// * Title: Goal title (or "Sesión en curso")
  /// * Body:  Detailed task info with time range + elapsed progress
  /// * Action button: Completar
  ///
  /// The notification is **not dismissible** by swiping — it stays until
  /// the task is completed or the time window elapses.
  Future<void> showOngoingTask(TaskEntity task) async {
    if (!isEnabled) return;

    final timeRange = AppDateUtils.formatTimeRange(
      task.scheduledAt,
      task.endAt,
    );
    final duration = AppDateUtils.formatDuration(task.durationMinutes);
    final payload = NotificationPayload(taskId: task.id);

    // Calculate progress.
    final now = DateTime.now();
    final elapsed = now.difference(task.scheduledAt);
    final total = task.endAt.difference(task.scheduledAt);
    final progressPercent = total.inSeconds > 0
        ? ((elapsed.inSeconds / total.inSeconds) * 100).clamp(0, 100).round()
        : 0;
    final remaining = task.endAt.difference(now);
    final remainingText = remaining.inMinutes > 0
        ? '${remaining.inMinutes} min restantes'
        : 'Finalizando...';

    final title = task.goalTitle ?? 'Sesión en curso';

    final body =
        '${task.title}\n'
        '$timeRange  ·  $duration\n'
        '$progressPercent% completado  ·  $remainingText';

    await _plugin.show(
      task.id + _ongoingIdOffset,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.activeTasks,
          'Tareas en curso',
          channelDescription:
              'Notificación permanente mientras una tarea está en progreso',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          usesChronometer: true,
          when: task.scheduledAt.millisecondsSinceEpoch,
          chronometerCountDown: true,
          color: const Color(0xFF6366F1), // AppColors.primary
          category: AndroidNotificationCategory.progress,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: 'Productivity Planner',
          ),
          actions: const [
            AndroidNotificationAction(
              NotificationActions.completeTask,
              'Completar',
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: false,
          categoryIdentifier: 'active_task',
        ),
      ),
      payload: payload.toJson(),
    );
  }

  /// Dismisses the ongoing notification for a task.
  Future<void> dismissOngoingTask(int taskId) async {
    await _plugin.cancel(taskId + _ongoingIdOffset);
  }

  /// Syncs ongoing notifications with the current task list.
  ///
  /// * Shows an ongoing notification for each currently active task.
  /// * Dismisses notifications for tasks that are no longer active.
  Future<void> syncOngoingNotifications(List<TaskEntity> tasks) async {
    if (!isEnabled) return;

    final activeTasks = tasks.where((t) => t.isActive).toList();
    final inactiveTasks = tasks.where((t) => !t.isActive).toList();

    // Dismiss notifications for tasks no longer active.
    for (final task in inactiveTasks) {
      await dismissOngoingTask(task.id);
    }

    // Show ongoing notification for each currently active task.
    for (final task in activeTasks) {
      await showOngoingTask(task);
    }
  }

  // ─── Cancellation ──────────────────────────────────────

  /// Cancels a single reminder notification by task ID.
  Future<void> cancel(int taskId) async {
    await _plugin.cancel(taskId);
    _scheduledReminderIds.remove(taskId);
  }

  /// Cancels only scheduled reminder notifications, leaving ongoing
  /// task notifications untouched.
  Future<void> _cancelAllReminders() async {
    for (final id in _scheduledReminderIds) {
      await _plugin.cancel(id);
    }
    _scheduledReminderIds.clear();
  }

  /// Cancels all scheduled and shown notifications (reminders + ongoing).
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    _scheduledReminderIds.clear();
    _scheduledTestIds.clear();
    await _prefs.remove(_kScheduledTestNotifications);
  }

  // ═══════════════════════════════════════════════════════════
  // TEST NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════

  /// Shows an instant test notification immediately with sound and vibration.
  ///
  /// Used for testing notification configuration in the settings page.
  Future<void> showTestNotification() async {
    if (!isEnabled) return;

    const title = '🔔 Test de Notificación';
    const body = '¡Las notificaciones están funcionando correctamente!';

    await _plugin.show(
      _testIdOffset,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.testNotifications,
          'Test de Notificaciones',
          channelDescription:
              'Notificaciones de prueba para verificar configuración',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
          color: const Color(0xFF6366F1),
          category: AndroidNotificationCategory.reminder,
          styleInformation: BigTextStyleInformation(
            '$body\n\nEsta es una notificación de prueba. Si puedes ver esto y escuchar el sonido, la configuración es correcta.',
            contentTitle: title,
            summaryText: 'Productivity Planner',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
          sound: 'default',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
    );
  }

  /// Schedules a test notification at the specified date and time.
  ///
  /// The notification will trigger exactly at [scheduledDate] with sound
  /// and vibration, even if the device is in doze mode or restarted.
  ///
  /// For Android 12+, this requires the SCHEDULE_EXACT_ALARM permission.
  /// If not granted, it will fall back to inexact scheduling.
  ///
  /// Returns the notification ID that can be used to cancel it.
  Future<int> scheduleTestNotification(DateTime scheduledDate) async {
    if (!isEnabled) throw StateError('Notifications are disabled');

    // Check for exact alarm permission on Android 12+.
    final canScheduleExact = await canScheduleExactAlarms();
    if (!canScheduleExact) {
      dev.log(
        '[NotificationService] Exact alarm permission not granted, '
        'falling back to inexact scheduling',
      );
    }

    // Generate unique ID based on timestamp.
    final notificationId =
        _testIdOffset + DateTime.now().millisecondsSinceEpoch % 100000;

    final tzSchedule = tz.TZDateTime.from(scheduledDate, tz.local);

    // Don't schedule if the time has already passed.
    if (tzSchedule.isBefore(tz.TZDateTime.now(tz.local))) {
      throw ArgumentError('Cannot schedule notification in the past');
    }

    const title = '⏰ Notificación Programada';
    final body =
        'Esta notificación fue programada para: ${_formatDateTime(scheduledDate)}';

    // Use exact scheduling if permitted, otherwise fall back to inexact.
    final scheduleMode = canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    dev.log(
      '[NotificationService] Scheduling notification $notificationId '
      'for $tzSchedule with mode: $scheduleMode',
    );

    await _plugin.zonedSchedule(
      notificationId,
      title,
      body,
      tzSchedule,
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.testNotifications,
          'Test de Notificaciones',
          channelDescription: 'Notificaciones de prueba programadas',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
          color: const Color(0xFF6366F1),
          category: AndroidNotificationCategory.reminder,
          styleInformation: BigTextStyleInformation(
            '$body\n\n¡La notificación programada funcionó correctamente! '
            'El dispositivo reiniciado o apagado no afectó la programación.',
            contentTitle: title,
            summaryText: 'Productivity Planner',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
          sound: 'default',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    _scheduledTestIds.add(notificationId);
    await _saveScheduledTestNotifications();

    dev.log(
      '[NotificationService] Scheduled notification $notificationId '
      'successfully',
    );

    return notificationId;
  }

  /// Cancels a specific scheduled test notification.
  Future<void> cancelTestNotification(int notificationId) async {
    await _plugin.cancel(notificationId);
    _scheduledTestIds.remove(notificationId);
    await _saveScheduledTestNotifications();
  }

  /// Gets all currently scheduled test notification IDs.
  Set<int> getScheduledTestNotificationIds() {
    return Set.unmodifiable(_scheduledTestIds);
  }

  /// Persists scheduled test notification IDs to SharedPreferences.
  Future<void> _saveScheduledTestNotifications() async {
    final list = _scheduledTestIds.toList();
    await _prefs.setStringList(
      _kScheduledTestNotifications,
      list.map((id) => id.toString()).toList(),
    );
  }

  /// Loads scheduled test notification IDs from SharedPreferences.
  Future<void> loadScheduledTestNotifications() async {
    final list = _prefs.getStringList(_kScheduledTestNotifications);
    if (list != null) {
      _scheduledTestIds.clear();
      _scheduledTestIds.addAll(list.map((s) => int.parse(s)));
    }
  }

  /// Formats DateTime for display in notification body.
  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    return '$day/$month/$year $hour:$minute';
  }
}
