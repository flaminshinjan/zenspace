import '../constants/api_constants.dart';
import '../network/api_client.dart';

/// Meditation Service (API version)
/// 
/// Handles all meditation-related API calls
class MeditationServiceApi {
  final ApiClient _apiClient = ApiClient();

  /// Get all meditation sessions
  /// 
  /// [category] - Filter by category (optional)
  /// [duration] - Filter by duration (optional)
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 20)
  Future<ApiResponse<Map<String, dynamic>>> getSessions({
    String? category,
    int? duration,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (category != null) queryParams['category'] = category;
    if (duration != null) queryParams['duration'] = duration.toString();

    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.meditationSessions,
      queryParameters: queryParams,
    );
  }

  /// Get a single meditation session
  /// 
  /// [sessionId] - Meditation session ID
  Future<ApiResponse<Map<String, dynamic>>> getSession(String sessionId) async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.meditationSession(sessionId),
    );
  }

  /// Start a meditation session
  /// 
  /// [sessionId] - Meditation session ID
  Future<ApiResponse<Map<String, dynamic>>> startSession(String sessionId) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.meditationSessionStart(sessionId),
    );
  }

  /// Complete a meditation session
  /// 
  /// [sessionId] - Meditation session ID
  /// [durationCompleted] - Duration completed in seconds
  /// [rating] - Session rating (1-5, optional)
  Future<ApiResponse<Map<String, dynamic>>> completeSession({
    required String sessionId,
    required int durationCompleted,
    int? rating,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.meditationSessionComplete(sessionId),
      body: {
        'duration_completed': durationCompleted,
        if (rating != null) 'rating': rating,
      },
    );
  }

  /// Rate a meditation session
  /// 
  /// [sessionId] - Meditation session ID
  /// [rating] - Rating (1-5)
  /// [review] - Review text (optional)
  Future<ApiResponse<Map<String, dynamic>>> rateSession({
    required String sessionId,
    required int rating,
    String? review,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.meditationSessionRate(sessionId),
      body: {
        'rating': rating,
        if (review != null) 'review': review,
      },
    );
  }

  /// Get meditation history
  /// 
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 20)
  Future<ApiResponse<Map<String, dynamic>>> getHistory({
    int page = 1,
    int limit = 20,
  }) async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.meditationHistory,
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
  }

  /// Get meditation categories
  Future<ApiResponse<Map<String, dynamic>>> getCategories() async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.meditationCategories,
    );
  }
}

