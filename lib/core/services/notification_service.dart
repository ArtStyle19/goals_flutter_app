import 'dart:convert';
import 'dart:ui';

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
}

/// Action identifiers attached to notification buttons.
abstract final class NotificationActions {
  /// User tapped "Completar" on an ongoing notification.
  static const completeTask = 'complete_task';
}

/// Offset added to a task ID so that the *ongoing* notification uses a
/// different system-notification-ID than the *reminder* for the same task.
const _ongoingIdOffset = 100000;

// ═══════════════════════════════════════════════════════════
// NOTIFICATION PAYLOAD
// ═══════════════════════════════════════════════════════════

/// Structured payload serialized as JSON in the notification's `payload`
/// field.  Keeps routing and action-handling type-safe.
class NotificationPayload {
  final int taskId;
  final String? action;

  const NotificationPayload({required this.taskId, this.action});

  factory NotificationPayload.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return NotificationPayload(
      taskId: map['taskId'] as int,
      action: map['action'] as String?,
    );
  }

  String toJson() => jsonEncode({'taskId': taskId, 'action': action});
}

// ═══════════════════════════════════════════════════════════
// CALLBACK TYPEDEFS
// ═══════════════════════════════════════════════════════════

/// Called when the user taps a notification body → navigate to task.
typedef OnNotificationTap = void Function(NotificationPayload payload);

/// Called when the user taps the "Completar" action button.
typedef OnCompleteAction = Future<void> Function(int taskId);

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

  /// Callbacks set once during [initialize].
  static OnNotificationTap? _onTap;
  static OnCompleteAction? _onComplete;

  /// Tracks scheduled reminder notification IDs so we can cancel only
  /// reminders without touching ongoing task notifications.
  static final Set<int> _scheduledReminderIds = {};

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
  /// * [onComplete]   – called when the user taps "Completar".
  static Future<void> initialize({
    required String ianaTimezone,
    OnNotificationTap? onTap,
    OnCompleteAction? onComplete,
  }) async {
    _onTap = onTap;
    _onComplete = onComplete;

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
  }

  // ─── Response Handlers ─────────────────────────────────

  /// Handles notification interaction in the foreground or when the app
  /// is opened from a notification tap.
  static void _handleResponse(NotificationResponse response) {
    final payload = _parsePayload(response.payload);
    if (payload == null) return;

    if (response.actionId == NotificationActions.completeTask) {
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
  }
}
