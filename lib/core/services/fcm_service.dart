import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:productivity/core/services/fcm_remote_datasource.dart';
import 'package:productivity/core/services/notification_service.dart';

// NOTE: Provider is defined in injection_container.dart to avoid conflicts

// ═══════════════════════════════════════════════════════════════════════════
// BACKGROUND HANDLER
// ═══════════════════════════════════════════════════════════════════════════

/// SharedPreferences key for pending notification actions.
const _kPendingNotificationAction = 'pending_notification_action';
const _kPendingNotificationTaskId = 'pending_notification_task_id';

/// Handler for background messages.
/// Must be a top-level function (not a method of a class).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  dev.log('[FCM] ╔══════════════════════════════════════════╗', name: 'fcm');
  dev.log('[FCM] ║  BACKGROUND MESSAGE RECEIVED             ║', name: 'fcm');
  dev.log('[FCM] ╚══════════════════════════════════════════╝', name: 'fcm');
  dev.log('[FCM] Message ID: ${message.messageId}', name: 'fcm');
  dev.log('[FCM] Data: ${message.data}', name: 'fcm');

  // For data-only messages with action buttons, show local notification
  final hasData = message.data.isNotEmpty;
  final showActions = message.data['show_actions'] == 'true';
  final title = message.data['title'] ?? 'Notificación';
  final body = message.data['body'] ?? '';

  if (hasData && showActions) {
    dev.log(
      '[FCM] Data-only message with actions - showing local notification',
      name: 'fcm',
    );

    // Initialize local notifications plugin in background
    final localNotifications = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onBackgroundNotificationResponse,
    );

    // Create notification channel with actions
    final androidPlugin = localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          'fcm_task_actions',
          'Acciones de Tareas',
          description:
              'Notificaciones con botones para completar u omitir tareas',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        ),
      );
    }

    // Build Android notification details with action buttons
    final androidDetails = AndroidNotificationDetails(
      'fcm_task_actions',
      'Acciones de Tareas',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      actions: const [
        AndroidNotificationAction(
          'complete_task',
          'Completar',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'skip_task',
          'Omitir',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    final details = NotificationDetails(android: androidDetails);

    // Generate notification ID from task_id if available
    int notificationId = DateTime.now().millisecond;
    final taskIdStr = message.data['task_id'];
    if (taskIdStr != null) {
      notificationId = int.tryParse(taskIdStr) ?? notificationId;
    }

    // Show the notification with action buttons
    await localNotifications.show(
      notificationId,
      title,
      body,
      details,
      payload: jsonEncode(message.data),
    );

    dev.log(
      '[FCM] ✅ Local notification with actions shown from background',
      name: 'fcm',
    );
  } else {
    dev.log(
      '[FCM] Standard FCM notification - no local notification needed',
      name: 'fcm',
    );
  }
}

/// Handle notification response in background.
/// Stores the action in SharedPreferences for processing when app opens.
@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) async {
  dev.log(
    '[FCM] Background notification response: action=${response.actionId}',
    name: 'fcm',
  );

  if (response.payload == null || response.payload!.isEmpty) {
    dev.log('[FCM] No payload in background response', name: 'fcm');
    return;
  }

  try {
    final data = jsonDecode(response.payload!) as Map<String, dynamic>;
    final taskIdStr = data['task_id'] as String?;
    final taskId = taskIdStr != null ? int.tryParse(taskIdStr) : null;

    if (taskId == null) {
      dev.log('[FCM] No taskId in background response', name: 'fcm');
      return;
    }

    // Store action in SharedPreferences for processing when app opens
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kPendingNotificationAction,
      response.actionId ?? 'open',
    );
    await prefs.setInt(_kPendingNotificationTaskId, taskId);

    dev.log(
      '[FCM] Stored pending action: ${response.actionId} for task $taskId',
      name: 'fcm',
    );
  } catch (e) {
    dev.log('[FCM] Error storing background action: $e', name: 'fcm');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FCM SERVICE
// ═══════════════════════════════════════════════════════════════════════════

/// Action identifiers for FCM notification buttons.
abstract final class FCMNotificationActions {
  static const String completeTask = 'complete_task';
  static const String skipTask = 'skip_task';
  static const String openTask = 'open_task';
}

/// Service for handling Firebase Cloud Messaging.
///
/// Responsibilities:
/// - Initialize Firebase and FCM
/// - Request notification permissions
/// - Get and refresh FCM token
/// - Handle incoming messages (foreground, background, terminated)
/// - Display local notifications when app is in foreground
/// - Sync tokens with backend
/// - Handle notification action buttons (Complete, Skip)
class FCMService {
  FirebaseMessaging? _messaging;
  FCMRemoteDataSource? _remoteDataSource;

  bool _isInitialized = false;
  String? _currentToken;

  /// Callback for when a task action is triggered from notification.
  /// The callback receives the taskId and action ('complete', 'skip', 'open').
  /// Business logic (API calls, state refresh, navigation) is handled by
  /// the callback owner (main.dart), keeping FCMService decoupled.
  Function(int taskId, String action)? onTaskAction;

  /// Get the messaging instance (only available after initialization)
  FirebaseMessaging get _messagingInstance {
    if (_messaging == null) {
      throw StateError('FCMService not initialized. Call initialize() first.');
    }
    return _messaging!;
  }

  // ─── Initialization ────────────────────────────────────────────────────

  /// Set the remote data source for backend communication.
  /// Must be called before [initialize] if backend sync is needed.
  void setRemoteDataSource(FCMRemoteDataSource dataSource) {
    _remoteDataSource = dataSource;
  }

  /// Initialize Firebase and FCM.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      dev.log('[FCM] Firebase initialized', name: 'fcm');

      // Initialize messaging instance
      _messaging = FirebaseMessaging.instance;

      // Set background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Request permission (iOS requires this)
      await _requestPermission();

      // Initialize local notifications (for foreground messages)
      await _initializeLocalNotifications();

      // Get FCM token
      await _updateToken();

      // Listen for token refresh
      _messagingInstance.onTokenRefresh.listen(_onTokenRefresh);

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification open (when app is opened from notification)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Check if app was opened from a notification (terminated state)
      await _checkInitialMessage();

      _isInitialized = true;
      dev.log('[FCM] Service initialized successfully', name: 'fcm');
    } catch (e) {
      dev.log('[FCM] Initialization error: $e', name: 'fcm');
      rethrow;
    }
  }

  /// Check if app was opened from a notification when terminated.
  Future<void> _checkInitialMessage() async {
    try {
      final RemoteMessage? initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();

      if (initialMessage != null) {
        dev.log(
          '[FCM] App opened from terminated state via notification',
          name: 'fcm',
        );
        _handleMessageOpenedApp(initialMessage);
      }
    } catch (e) {
      dev.log('[FCM] Error checking initial message: $e', name: 'fcm');
    }
  }

  // ─── Permissions ────────────────────────────────────────────────────────

  /// Request notification permission from the user.
  Future<bool> _requestPermission() async {
    final settings = await _messagingInstance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized;
    dev.log(
      '[FCM] Permission status: ${settings.authorizationStatus}',
      name: 'fcm',
    );
    return granted;
  }

  // ─── Token Management ────────────────────────────────────────────────────

  /// Get current FCM token.
  ///
  /// Re-fetches from Firebase if no token is cached locally.
  Future<String?> getToken() async {
    if (!_isInitialized) {
      throw StateError('FCMService not initialized. Call initialize() first.');
    }
    // Re-fetch if missing (e.g. after logout deleted it)
    _currentToken ??= await _messagingInstance.getToken();
    return _currentToken;
  }

  /// Register the current FCM token with the backend.
  ///
  /// If no token is cached locally (e.g. after logout deleted it),
  /// a fresh token is obtained from Firebase first.
  /// Returns `true` on success, `false` if registration was skipped.
  Future<bool> registerTokenWithBackend() async {
    if (!_isInitialized) {
      throw StateError('FCMService not initialized. Call initialize() first.');
    }
    if (_remoteDataSource == null) {
      dev.log('[FCM] No remote data source available', name: 'fcm');
      return false;
    }

    // Re-fetch token from Firebase if we don't have one cached
    // (happens after logout → deleteToken clears _currentToken)
    if (_currentToken == null) {
      dev.log('[FCM] No cached token — requesting fresh token', name: 'fcm');
      _currentToken = await _messagingInstance.getToken();
    }

    if (_currentToken == null) {
      dev.log('[FCM] Firebase returned null token', name: 'fcm');
      return false;
    }

    try {
      await _remoteDataSource!.registerToken(_currentToken!);
      dev.log('[FCM] Token registered with backend ✅', name: 'fcm');
      return true;
    } catch (e) {
      dev.log('[FCM] Token registration failed: $e', name: 'fcm');
      return false;
    }
  }

  /// Update the current FCM token and sync with backend.
  Future<void> _updateToken() async {
    try {
      _currentToken = await _messagingInstance.getToken();
      dev.log(
        '[FCM] Token obtained: ${_currentToken?.substring(0, 20)}...',
        name: 'fcm',
      );

      // Sync with backend if remote data source is available
      if (_currentToken != null && _remoteDataSource != null) {
        try {
          await _remoteDataSource!.registerToken(_currentToken!);
          dev.log(
            '[FCM] Token registered successfully with backend',
            name: 'fcm',
          );
        } catch (e) {
          dev.log(
            '[FCM] Failed to register token with backend: $e',
            name: 'fcm',
          );
          // Don't rethrow - we still want to keep the token locally
        }
      } else {
        dev.log(
          '[FCM] Token not synced: remoteDataSource=${_remoteDataSource != null}, token=${_currentToken != null}',
          name: 'fcm',
        );
      }
    } catch (e) {
      dev.log('[FCM] Error getting token: $e', name: 'fcm');
    }
  }

  /// Handle token refresh and sync with backend.
  void _onTokenRefresh(String newToken) {
    dev.log(
      '[FCM] Token refreshed: ${newToken.substring(0, 20)}...',
      name: 'fcm',
    );
    _currentToken = newToken;

    // Sync with backend if remote data source is available
    if (_remoteDataSource != null) {
      _remoteDataSource!.registerToken(newToken).catchError((e) {
        dev.log('[FCM] Failed to sync refreshed token: $e', name: 'fcm');
      });
    }
  }

  // ─── Local Notifications (for foreground) ────────────────────────────────

  /// Creates the FCM-specific notification channels on Android.
  ///
  /// **Important:** This does NOT call `_plugin.initialize()` —
  /// [NotificationService.initialize()] handles that once, and its
  /// `_handleResponse` handler routes both local and FCM actions.
  /// We only use [NotificationService.plugin] to *show* notifications.
  Future<void> _initializeLocalNotifications() async {
    // Create notification channels for Android
    await _createNotificationChannels();
  }

  /// Create all required notification channels for Android.
  Future<void> _createNotificationChannels() async {
    final androidPlugin = NotificationService.plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return;

    // Standard FCM foreground channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'fcm_foreground_channel',
        'FCM Foreground Notifications',
        description: 'Notifications shown when app is in foreground',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    // Task actions channel with high importance and vibration
    await androidPlugin.createNotificationChannel(
      AndroidNotificationChannel(
        'fcm_task_actions',
        'Acciones de Tareas',
        description:
            'Notificaciones con botones para completar u omitir tareas',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        showBadge: true,
      ),
    );

    dev.log('[FCM] Notification channels created', name: 'fcm');
  }

  /// Process any pending notification actions stored in background.
  /// Call this when app starts to handle actions from terminated state.
  Future<void> processPendingActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final action = prefs.getString(_kPendingNotificationAction);
      final taskId = prefs.getInt(_kPendingNotificationTaskId);

      if (action != null && taskId != null) {
        dev.log(
          '[FCM] Processing pending action: $action for task $taskId',
          name: 'fcm',
        );

        // Clear pending action first to prevent re-processing
        await prefs.remove(_kPendingNotificationAction);
        await prefs.remove(_kPendingNotificationTaskId);

        // Execute the action
        if (action == 'complete_task' || action == 'skip_task') {
          final actionType = action == 'complete_task' ? 'complete' : 'skip';
          await _handleTaskAction(taskId, actionType);
        } else {
          // Open action or unknown
          onTaskAction?.call(taskId, 'open');
        }
      }
    } catch (e) {
      dev.log('[FCM] Error processing pending actions: $e', name: 'fcm');
    }
  }

  /// Extract task ID from notification data.
  int? _extractTaskId(Map<String, dynamic> data) {
    final taskIdStr = data['task_id'] ?? data['taskId'];
    if (taskIdStr == null) return null;
    return int.tryParse(taskIdStr.toString());
  }

  /// Handle task action (complete or skip).
  ///
  /// Delegates execution to [onTaskAction] callback set in main.dart.
  /// The callback is responsible for calling the repository and refreshing UI.
  /// This keeps FCMService decoupled from business logic.
  Future<void> _handleTaskAction(int taskId, String action) async {
    dev.log('[FCM] ╔══════════════════════════════════════════╗', name: 'fcm');
    dev.log('[FCM] ║  HANDLE TASK ACTION                      ║', name: 'fcm');
    dev.log('[FCM] ╚══════════════════════════════════════════╝', name: 'fcm');
    dev.log('[FCM] taskId: $taskId', name: 'fcm');
    dev.log('[FCM] action: $action', name: 'fcm');

    if (onTaskAction != null) {
      dev.log('[FCM] Delegating to onTaskAction callback...', name: 'fcm');
      onTaskAction!(taskId, action);
    } else {
      dev.log('[FCM] ⚠️ No onTaskAction callback registered', name: 'fcm');
    }
  }

  // ─── Message Handlers ────────────────────────────────────────────────────

  /// Handle messages when app is in foreground.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    dev.log(
      '[FCM] Foreground message received: ${message.notification?.title}',
      name: 'fcm',
    );

    // Show local notification since FCM doesn't show automatically in foreground
    final notification = message.notification;
    if (notification != null) {
      await _showLocalNotification(
        title: notification.title ?? 'Notificación',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
        data: message.data,
      );
    }

    // Handle data-only messages (show local notification with actions if needed)
    if (notification == null && message.data.isNotEmpty) {
      dev.log('[FCM] Data-only message received in foreground', name: 'fcm');
      final title = message.data['title'] ?? 'Notificación';
      final body = message.data['body'] ?? '';
      await _showLocalNotification(
        title: title,
        body: body,
        payload: jsonEncode(message.data),
        data: message.data,
      );
    }
  }

  /// Handle when app is opened from notification.
  void _handleMessageOpenedApp(RemoteMessage message) {
    dev.log(
      '[FCM] App opened from notification: ${message.notification?.title}',
      name: 'fcm',
    );
    dev.log('[FCM] Message data: ${message.data}', name: 'fcm');

    // Check if this was an action button press (action will be in data)
    final action = message.data['action'] as String?;
    final taskId = _extractTaskId(message.data);

    if (taskId != null && action != null) {
      // This was an action button press
      dev.log('[FCM] Action button pressed: $action', name: 'fcm');
      if (action == 'complete' || action == 'skip') {
        _handleTaskAction(taskId, action);
        return;
      }
    }

    // Handle deep link routing from FCM payload
    if (taskId != null) {
      // Delegate navigation to the callback (open action)
      onTaskAction?.call(taskId, 'open');
    }
  }

  /// Show local notification (used for foreground messages).
  ///
  /// If the FCM message contains action buttons, they will be displayed.
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    Map<String, dynamic>? data,
  }) async {
    final bool showActions = data?['show_actions'] == 'true';
    final String? actionsJson = data?['actions'] as String?;
    final List<Map<String, dynamic>> actions = [];

    if (actionsJson != null) {
      try {
        final decoded = jsonDecode(actionsJson) as List<dynamic>;
        actions.addAll(decoded.cast<Map<String, dynamic>>());
      } catch (e) {
        dev.log('[FCM] Failed to parse actions: $e', name: 'fcm');
      }
    }

    // Build Android notification details
    final androidDetails = AndroidNotificationDetails(
      showActions ? 'fcm_task_actions' : 'fcm_foreground_channel',
      showActions ? 'Acciones de Tareas' : 'FCM Foreground Notifications',
      importance: showActions ? Importance.max : Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      vibrationPattern: showActions
          ? Int64List.fromList([0, 500, 200, 500])
          : null,
      actions: showActions
          ? [
              const AndroidNotificationAction(
                FCMNotificationActions.completeTask,
                'Completar',
                showsUserInterface: true,
                cancelNotification: true,
              ),
              const AndroidNotificationAction(
                FCMNotificationActions.skipTask,
                'Omitir',
                showsUserInterface: true,
                cancelNotification: true,
              ),
            ]
          : null,
    );

    // Build iOS notification details
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: showActions ? 'task_actions' : null,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Generate unique ID based on task_id if available
    int notificationId = DateTime.now().millisecond;
    if (data != null) {
      final taskId = _extractTaskId(data);
      if (taskId != null) {
        notificationId = taskId;
      }
    }

    await NotificationService.plugin.show(
      notificationId,
      title,
      body,
      details,
      payload: payload ?? jsonEncode(data),
    );

    dev.log('[FCM] ╔══════════════════════════════════════════╗', name: 'fcm');
    dev.log('[FCM] ║  LOCAL NOTIFICATION SHOWN                ║', name: 'fcm');
    dev.log('[FCM] ╚══════════════════════════════════════════╝', name: 'fcm');
    dev.log('[FCM] ID: $notificationId', name: 'fcm');
    dev.log('[FCM] Title: $title', name: 'fcm');
    dev.log('[FCM] Has actions: $showActions', name: 'fcm');
    dev.log('[FCM] Actions count: ${actions.length}', name: 'fcm');
    dev.log('[FCM] Payload: $payload', name: 'fcm');
    dev.log('[FCM] ═══════════════════════════════════════════', name: 'fcm');
  }

  // ─── Public API ─────────────────────────────────────────────────────────

  /// Subscribe to a topic.
  Future<void> subscribeToTopic(String topic) async {
    await _messagingInstance.subscribeToTopic(topic);
    dev.log('[FCM] Subscribed to topic: $topic', name: 'fcm');
  }

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messagingInstance.unsubscribeFromTopic(topic);
    dev.log('[FCM] Unsubscribed from topic: $topic', name: 'fcm');
  }

  /// Delete FCM token and remove from backend (useful for logout).
  Future<void> deleteToken() async {
    // Remove from backend first
    if (_remoteDataSource != null) {
      try {
        await _remoteDataSource!.removeToken();
        dev.log('[FCM] Token removed from backend', name: 'fcm');
      } catch (e) {
        dev.log('[FCM] Failed to remove token from backend: $e', name: 'fcm');
      }
    }

    await _messagingInstance.deleteToken();
    _currentToken = null;
    dev.log('[FCM] Token deleted locally', name: 'fcm');
  }

  /// Send test notification via backend.
  Future<void> sendTestNotificationFromBackend({
    String? title,
    String? body,
  }) async {
    if (_remoteDataSource == null) {
      throw StateError('Remote data source not set');
    }
    await _remoteDataSource!.sendTestNotification(title: title, body: body);
  }

  /// Send test notification with action buttons via backend.
  Future<void> sendTestNotificationWithActionsFromBackend({
    String? title,
    String? body,
  }) async {
    if (_remoteDataSource == null) {
      throw StateError('Remote data source not set');
    }
    await _remoteDataSource!.sendTestNotificationWithActions(
      title: title,
      body: body,
    );
  }

  /// Get FCM service status from backend.
  Future<Map<String, dynamic>> getBackendStatus() async {
    if (_remoteDataSource == null) {
      throw StateError('Remote data source not set');
    }
    return await _remoteDataSource!.getStatus();
  }
}
