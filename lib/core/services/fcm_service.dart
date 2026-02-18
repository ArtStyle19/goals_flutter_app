import 'dart:async';
import 'dart:developer' as dev;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  dev.log(
    '[FCM] Background message received: ${message.messageId}',
    name: 'fcm',
  );
  // Note: Background messages are handled by the system automatically
  // for notification-type messages. Data messages require custom handling.
}

// ═══════════════════════════════════════════════════════════════════════════
// FCM SERVICE
// ═══════════════════════════════════════════════════════════════════════════

/// Service for handling Firebase Cloud Messaging.
///
/// Responsibilities:
/// - Initialize Firebase and FCM
/// - Request notification permissions
/// - Get and refresh FCM token
/// - Handle incoming messages (foreground, background, terminated)
/// - Display local notifications when app is in foreground
/// - Sync tokens with backend
class FCMService {
  FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  FCMRemoteDataSource? _remoteDataSource;

  bool _isInitialized = false;
  String? _currentToken;

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

      _isInitialized = true;
      dev.log('[FCM] Service initialized successfully', name: 'fcm');
    } catch (e) {
      dev.log('[FCM] Initialization error: $e', name: 'fcm');
      rethrow;
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
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'fcm_foreground_channel',
      'FCM Foreground Notifications',
      description: 'Notifications shown when app is in foreground',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle notification tap.
  void _onNotificationTapped(NotificationResponse response) {
    dev.log('[FCM] Notification tapped: ${response.payload}', name: 'fcm');
    // TODO: Navigate to relevant screen based on payload
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
        payload: message.data.toString(),
      );
    }
  }

  /// Handle when app is opened from notification.
  void _handleMessageOpenedApp(RemoteMessage message) {
    dev.log(
      '[FCM] App opened from notification: ${message.notification?.title}',
      name: 'fcm',
    );
    // TODO: Navigate to relevant screen based on message.data
  }

  /// Show local notification (used for foreground messages).
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'fcm_foreground_channel',
      'FCM Foreground Notifications',
      channelDescription: 'Notifications shown when app is in foreground',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond, // Unique ID
      title,
      body,
      details,
      payload: payload,
    );
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

  /// Get FCM service status from backend.
  Future<Map<String, dynamic>> getBackendStatus() async {
    if (_remoteDataSource == null) {
      throw StateError('Remote data source not set');
    }
    return await _remoteDataSource!.getStatus();
  }
}
