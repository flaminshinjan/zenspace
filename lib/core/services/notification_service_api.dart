import '../constants/api_constants.dart';
import '../network/api_client.dart';

/// Notification Service (API version)
/// 
/// Handles all notification-related API calls
class NotificationServiceApi {
  final ApiClient _apiClient = ApiClient();

  /// Get notifications
  /// 
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 20)
  /// [unreadOnly] - Show only unread notifications (optional)
  Future<ApiResponse<Map<String, dynamic>>> getNotifications({
    int page = 1,
    int limit = 20,
    bool? unreadOnly,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (unreadOnly != null) queryParams['unread_only'] = unreadOnly.toString();

    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.notificationsBase,
      queryParameters: queryParams,
    );
  }

  /// Mark notification as read
  /// 
  /// [notificationId] - Notification ID
  Future<ApiResponse<Map<String, dynamic>>> markAsRead(String notificationId) async {
    return await _apiClient.put<Map<String, dynamic>>(
      ApiConstants.notificationRead(notificationId),
    );
  }

  /// Mark all notifications as read
  Future<ApiResponse<Map<String, dynamic>>> markAllAsRead() async {
    return await _apiClient.put<Map<String, dynamic>>(
      ApiConstants.notificationsReadAll,
    );
  }

  /// Delete notification
  /// 
  /// [notificationId] - Notification ID
  Future<ApiResponse<Map<String, dynamic>>> deleteNotification(String notificationId) async {
    return await _apiClient.delete<Map<String, dynamic>>(
      ApiConstants.notificationDelete(notificationId),
    );
  }

  /// Update notification settings
  /// 
  /// [pushEnabled] - Enable push notifications (optional)
  /// [emailEnabled] - Enable email notifications (optional)
  /// [meditationReminders] - Enable meditation reminders (optional)
  /// [appointmentReminders] - Enable appointment reminders (optional)
  Future<ApiResponse<Map<String, dynamic>>> updateSettings({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? meditationReminders,
    bool? appointmentReminders,
  }) async {
    final body = <String, dynamic>{};
    if (pushEnabled != null) body['push_enabled'] = pushEnabled;
    if (emailEnabled != null) body['email_enabled'] = emailEnabled;
    if (meditationReminders != null) body['meditation_reminders'] = meditationReminders;
    if (appointmentReminders != null) body['appointment_reminders'] = appointmentReminders;

    return await _apiClient.put<Map<String, dynamic>>(
      ApiConstants.notificationsSettings,
      body: body,
    );
  }

  /// Register device for push notifications
  /// 
  /// [deviceToken] - FCM device token
  /// [platform] - Platform ('ios' or 'android')
  /// [deviceId] - Device unique identifier
  Future<ApiResponse<Map<String, dynamic>>> registerDevice({
    required String deviceToken,
    required String platform,
    required String deviceId,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.notificationsDevices,
      body: {
        'device_token': deviceToken,
        'platform': platform,
        'device_id': deviceId,
      },
    );
  }
}

