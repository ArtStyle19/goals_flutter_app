import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/app/di/injection_container.dart';
import 'package:productivity/app/router/app_router.dart';
import 'package:productivity/core/services/fcm_remote_datasource.dart';

// NOTE: Provider is defined in injection_container.dart to avoid conflicts

// ═══════════════════════════════════════════════════════════════════════════
// BACKGROUND HANDLER
// ═══════════════════════════════════════════════════════════════════════════

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
  dev.log('[FCM] Notification: ${message.notification?.title}', name: 'fcm');

  // Check if this is a hybrid message (notification + data) with action buttons
  final hasNotification = message.notification != null;
  final hasData = message.data.isNotEmpty;
  final showActions = message.data['show_actions'] == 'true';

  // For hybrid messages with action buttons, we need to show a local notification
  // with the action buttons because FCM doesn't support action buttons natively
  if (hasNotification && hasData && showActions) {
    dev.log(
      '[FCM] Hybrid message with actions detected - showing local notification',
      name: 'fcm',
    );

    final title =
        message.notification?.title ?? message.data['title'] ?? 'Notificación';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    dev.log('[FCM] Title: $title', name: 'fcm');
    dev.log('[FCM] Body: $body', name: 'fcm');
    dev.log('[FCM] Show actions: $showActions', name: 'fcm');

    // Initialize local notifications plugin in background
    final localNotifications = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        dev.log(
          '[FCM] Background notification response: ${response.actionId}',
          name: 'fcm',
        );
      },
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
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  FCMRemoteDataSource? _remoteDataSource;
  ProviderContainer? _ref;

  bool _isInitialized = false;
  String? _currentToken;

  /// Callback for when a task action is triggered from notification.
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

  /// Set the Riverpod container for accessing repositories.
  /// Required for handling task actions from notifications.
  void setRef(ProviderContainer ref) {
    _ref = ref;
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
  Future<String?> getToken() async {
    if (!_isInitialized) {
      throw StateError('FCMService not initialized. Call initialize() first.');
    }
    return _currentToken;
  }

  /// Manually register the current token with the backend.
  /// Useful for retrying failed registrations or forcing re-registration.
  Future<bool> registerTokenWithBackend() async {
    if (!_isInitialized) {
      throw StateError('FCMService not initialized. Call initialize() first.');
    }
    if (_currentToken == null) {
      dev.log('[FCM] No token available to register', name: 'fcm');
      return false;
    }
    if (_remoteDataSource == null) {
      dev.log('[FCM] No remote data source available', name: 'fcm');
      return false;
    }

    try {
      await _remoteDataSource!.registerToken(_currentToken!);
      dev.log('[FCM] Token manually registered with backend', name: 'fcm');
      return true;
    } catch (e) {
      dev.log('[FCM] Manual token registration failed: $e', name: 'fcm');
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

  /// Initialize local notifications plugin.
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings with action categories
    final iosSettings = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          'task_actions',
          actions: [
            DarwinNotificationAction.plain(
              FCMNotificationActions.completeTask,
              'Completar',
              options: {DarwinNotificationActionOption.foreground},
            ),
            DarwinNotificationAction.plain(
              FCMNotificationActions.skipTask,
              'Omitir',
              options: {DarwinNotificationActionOption.foreground},
            ),
          ],
        ),
      ],
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  /// Create all required notification channels for Android.
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications
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

  /// Handle notification tap (foreground).
  void _onNotificationTapped(NotificationResponse response) {
    dev.log('[FCM] ═══════════════════════════════════════════', name: 'fcm');
    dev.log('[FCM] NOTIFICATION TAPPED', name: 'fcm');
    dev.log('[FCM] Action ID: ${response.actionId}', name: 'fcm');
    dev.log('[FCM] Payload: ${response.payload}', name: 'fcm');
    dev.log('[FCM] Notification ID: ${response.id}', name: 'fcm');
    dev.log('[FCM] ═══════════════════════════════════════════', name: 'fcm');

    // Handle the case where payload might be null but we have notification ID
    // This can happen with FCM notifications shown by the system
    if (response.payload == null || response.payload!.isEmpty) {
      dev.log(
        '[FCM] WARNING: Empty payload, trying to extract from notification ID',
        name: 'fcm',
      );
      // Try to get data from a stored map if we have it
      // For now, we can't do much without payload data
      dev.log(
        '[FCM] ERROR: Cannot process notification without payload data',
        name: 'fcm',
      );
      return;
    }

    final data = _parsePayload(response.payload);
    if (data == null) {
      dev.log('[FCM] ERROR: Failed to parse payload', name: 'fcm');
      return;
    }
    dev.log('[FCM] Parsed data: $data', name: 'fcm');

    final taskId = _extractTaskId(data);
    if (taskId == null) {
      dev.log('[FCM] ERROR: Could not extract taskId from data', name: 'fcm');
      return;
    }
    dev.log('[FCM] Extracted taskId: $taskId', name: 'fcm');

    // Handle action buttons
    if (response.actionId == FCMNotificationActions.completeTask) {
      dev.log('[FCM] Action: COMPLETE TASK', name: 'fcm');
      _handleTaskAction(taskId, 'complete');
    } else if (response.actionId == FCMNotificationActions.skipTask) {
      dev.log('[FCM] Action: SKIP TASK', name: 'fcm');
      _handleTaskAction(taskId, 'skip');
    } else if (response.actionId == null) {
      dev.log('[FCM] Action: OPEN TASK (body tap)', name: 'fcm');
      onTaskAction?.call(taskId, 'open');
    } else {
      dev.log('[FCM] Action: UNKNOWN (${response.actionId})', name: 'fcm');
      onTaskAction?.call(taskId, 'open');
    }
  }

  /// Handle notification tap in background (static required by plugin).
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    dev.log(
      '[FCM] Background notification tapped: action=${response.actionId}',
      name: 'fcm',
    );
    // Background actions are limited - app will open and foreground handler takes over
  }

  /// Parse notification payload from JSON string.
  Map<String, dynamic>? _parsePayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (e) {
      dev.log('[FCM] Failed to parse payload: $e', name: 'fcm');
      return null;
    }
  }

  /// Extract task ID from notification data.
  int? _extractTaskId(Map<String, dynamic> data) {
    final taskIdStr = data['task_id'] ?? data['taskId'];
    if (taskIdStr == null) return null;
    return int.tryParse(taskIdStr.toString());
  }

  /// Handle task action (complete or skip).
  Future<void> _handleTaskAction(int taskId, String action) async {
    dev.log('[FCM] ╔══════════════════════════════════════════╗', name: 'fcm');
    dev.log('[FCM] ║  HANDLE TASK ACTION                      ║', name: 'fcm');
    dev.log('[FCM] ╚══════════════════════════════════════════╝', name: 'fcm');
    dev.log('[FCM] taskId: $taskId', name: 'fcm');
    dev.log('[FCM] action: $action', name: 'fcm');
    dev.log('[FCM] _ref available: ${_ref != null}', name: 'fcm');
    dev.log(
      '[FCM] onTaskAction callback set: ${onTaskAction != null}',
      name: 'fcm',
    );

    // Execute via repository first if ref is available
    if (_ref != null) {
      try {
        dev.log('[FCM] Reading taskRepository...', name: 'fcm');
        final taskRepository = _ref!.read(taskRepositoryProvider);
        dev.log('[FCM] Repository obtained successfully', name: 'fcm');

        if (action == 'complete') {
          dev.log(
            '[FCM] Calling completeTaskFromNotification($taskId)...',
            name: 'fcm',
          );
          await taskRepository.completeTaskFromNotification(taskId);
          dev.log(
            '[FCM] ✅ Task $taskId COMPLETED successfully via notification',
            name: 'fcm',
          );
        } else if (action == 'skip') {
          dev.log(
            '[FCM] Calling skipTaskFromNotification($taskId)...',
            name: 'fcm',
          );
          await taskRepository.skipTaskFromNotification(taskId);
          dev.log(
            '[FCM] ✅ Task $taskId SKIPPED successfully via notification',
            name: 'fcm',
          );
        }
      } catch (e, stackTrace) {
        dev.log(
          '[FCM] ❌ FAILED to execute task action via repository: $e',
          name: 'fcm',
        );
        dev.log('[FCM] Stack trace: $stackTrace', name: 'fcm');
        // Don't return - still try to call the callback for UI updates
      }
    } else {
      dev.log('[FCM] ⚠️ No ref available, using callback only', name: 'fcm');
    }

    // Call the callback for UI navigation/refresh
    dev.log('[FCM] Calling onTaskAction callback...', name: 'fcm');
    onTaskAction?.call(taskId, action);
    dev.log('[FCM] onTaskAction callback completed', name: 'fcm');
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
    final route = message.data['route'] as String?;

    if (route != null && _ref != null) {
      _navigateToRoute(route, taskId);
    } else if (taskId != null) {
      // Fallback: navigate to task detail if task_id is present
      onTaskAction?.call(taskId, 'open');
    }
  }

  /// Navigate to a specific route using the router.
  void _navigateToRoute(String route, int? taskId) {
    try {
      final router = _ref!.read(routerProvider);
      String path = route;

      // Replace route parameters if taskId is available
      if (taskId != null && route.contains(':id')) {
        path = route.replaceFirst(':id', '$taskId');
      }

      dev.log('[FCM] Navigating to: $path', name: 'fcm');
      router.push(path);
    } catch (e) {
      dev.log('[FCM] Failed to navigate: $e', name: 'fcm');
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

    await _localNotifications.show(
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
