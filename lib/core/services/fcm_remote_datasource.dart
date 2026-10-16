import 'package:productivity/core/error/exceptions.dart';
import 'package:productivity/core/network/api_client.dart';
import 'package:productivity/core/network/api_endpoints.dart';

/// Remote data source for FCM (Firebase Cloud Messaging) operations.
///
/// Handles communication with the backend to:
/// - Register FCM tokens
/// - Remove FCM tokens (on logout)
/// - Send test notifications
/// - Check notification service status
class FCMRemoteDataSource {
  final ApiClient _apiClient;

  const FCMRemoteDataSource(this._apiClient);

  // ─── Token Management ───────────────────────────────────────────────────

  /// Register FCM token with the backend.
  ///
  /// Called after obtaining FCM token from Firebase.
  /// Backend will store this token to send push notifications.
  Future<void> registerToken(String fcmToken) async {
    try {
      await _apiClient.post(
        ApiEndpoints.fcmToken,
        data: {'fcm_token': fcmToken},
        parser: (data) => data,
      );
    } catch (e) {
      throw ServerException('Failed to register FCM token: $e');
    }
  }

  /// Remove FCM token from the backend.
  ///
  /// Called on logout to stop receiving notifications.
  Future<void> removeToken() async {
    try {
      await _apiClient.delete(ApiEndpoints.fcmToken, parser: (data) => data);
    } catch (e) {
      throw ServerException('Failed to remove FCM token: $e');
    }
  }

  // ─── Test & Status ──────────────────────────────────────────────────────

  /// Send a test notification from the backend.
  ///
  /// Useful for verifying that FCM integration is working correctly.
  Future<void> sendTestNotification({
    String? title,
    String? body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _apiClient.post(
        ApiEndpoints.testNotification,
        data: {'title': title, 'body': body, 'data': data},
        parser: (data) => data,
      );
    } catch (e) {
      throw ServerException('Failed to send test notification: $e');
    }
  }

  /// Send a test notification with action buttons from the backend.
  ///
  /// Useful for testing notifications with "Complete" and "Skip" buttons.
  Future<void> sendTestNotificationWithActions({
    String? title,
    String? body,
  }) async {
    try {
      await _apiClient.post(
        ApiEndpoints.testNotificationWithActions,
        data: {'title': title, 'body': body},
        parser: (data) => data,
      );
    } catch (e) {
      throw ServerException(
        'Failed to send test notification with actions: $e',
      );
    }
  }

  /// Check FCM service status on the backend.
  ///
  /// Returns status information about the notification service,
  /// including server-side configuration and user-specific token status.
  Future<Map<String, dynamic>> getStatus() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.notificationStatus,
        parser: (data) {
          final map = data as Map<String, dynamic>;
          // Unwrap the 'data' envelope so callers get flat status keys
          return (map['data'] as Map<String, dynamic>?) ?? map;
        },
      );
      return response;
    } catch (e) {
      throw ServerException('Failed to get notification status: $e');
    }
  }
}
