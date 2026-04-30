import 'package:zenspace/core/constants/api_constants.dart';
import 'package:zenspace/core/network/api_client.dart';

/// Service class for mood check-in API calls
class MoodServiceApi {
  final ApiClient _apiClient = ApiClient();

  /// Create a mood check-in
  /// 
  /// [mood] - Mood value: very_sad, sad, neutral, happy, very_happy
  /// [notes] - Optional notes about the mood
  Future<ApiResponse<Map<String, dynamic>>> createCheckIn({
    required String mood,
    String? notes,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.moodCheckIns,
      body: {
        'mood': mood,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }

  /// Get paginated mood check-ins
  /// 
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 20)
  /// [startDate] - Optional start date filter (ISO format)
  /// [endDate] - Optional end date filter (ISO format)
  Future<ApiResponse<dynamic>> getCheckIns({
    int page = 1,
    int limit = 20,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (startDate != null) {
      queryParams['start_date'] = startDate;
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate;
    }

    return await _apiClient.get<dynamic>(
      ApiConstants.moodCheckIns,
      queryParameters: queryParams,
    );
  }

  /// Get today's mood check-in
  Future<ApiResponse<Map<String, dynamic>>> getTodayCheckIn() async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.moodCheckInToday,
    );
  }

  /// Get a specific mood check-in by ID
  Future<ApiResponse<Map<String, dynamic>>> getCheckIn(String checkInId) async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.moodCheckIn(checkInId),
    );
  }

  /// Get mood statistics
  /// 
  /// [period] - Time period: day, week, month, year (default: month)
  /// [startDate] - Optional start date filter (ISO format)
  /// [endDate] - Optional end date filter (ISO format)
  Future<ApiResponse<Map<String, dynamic>>> getStats({
    String period = 'month',
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      'period': period,
    };

    if (startDate != null) {
      queryParams['start_date'] = startDate;
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate;
    }

    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.moodStats,
      queryParameters: queryParams,
    );
  }
}

