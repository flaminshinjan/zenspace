import 'dart:io';
import '../constants/api_constants.dart';
import '../network/api_client.dart';

/// User Service (API version)
/// 
/// Handles all user profile-related API calls
class UserServiceApi {
  final ApiClient _apiClient = ApiClient();

  /// Get user profile
  Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.userProfile,
    );
  }

  /// Update user profile
  /// 
  /// [fullName] - User's full name (optional)
  /// [bio] - User's bio (optional)
  /// [dateOfBirth] - Date of birth (optional)
  /// [phone] - Phone number (optional)
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? fullName,
    String? bio,
    String? dateOfBirth,
    String? phone,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['full_name'] = fullName;
    if (bio != null) body['bio'] = bio;
    if (dateOfBirth != null) body['date_of_birth'] = dateOfBirth;
    if (phone != null) body['phone'] = phone;

    return await _apiClient.put<Map<String, dynamic>>(
      ApiConstants.userProfile,
      body: body,
    );
  }

  /// Update user preferences
  /// 
  /// [theme] - App theme (optional)
  /// [notificationsEnabled] - Enable/disable notifications (optional)
  /// [language] - Preferred language (optional)
  Future<ApiResponse<Map<String, dynamic>>> updatePreferences({
    String? theme,
    bool? notificationsEnabled,
    String? language,
  }) async {
    final body = <String, dynamic>{};
    if (theme != null) body['theme'] = theme;
    if (notificationsEnabled != null) body['notifications_enabled'] = notificationsEnabled;
    if (language != null) body['language'] = language;

    return await _apiClient.put<Map<String, dynamic>>(
      ApiConstants.userPreferences,
      body: body,
    );
  }

  /// Get user statistics
  Future<ApiResponse<Map<String, dynamic>>> getStats() async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.userStats,
    );
  }

  /// Upload profile picture
  /// 
  /// [imageFile] - Profile picture file
  Future<ApiResponse<Map<String, dynamic>>> uploadProfilePicture({
    required File imageFile,
  }) async {
    return await _apiClient.postMultipart<Map<String, dynamic>>(
      ApiConstants.userProfilePicture,
      fields: {},
      fileField: 'image',
      file: imageFile,
    );
  }
}

