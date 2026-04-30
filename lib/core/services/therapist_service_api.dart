import '../constants/api_constants.dart';
import '../network/api_client.dart';

/// Therapist Service (API version)
/// 
/// Handles all therapist-related API calls
class TherapistServiceApi {
  final ApiClient _apiClient = ApiClient();

  /// Search therapists
  /// 
  /// [specialty] - Filter by specialty (optional)
  /// [location] - Filter by location (optional)
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 10)
  Future<ApiResponse<Map<String, dynamic>>> searchTherapists({
    String? specialty,
    String? location,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (specialty != null) queryParams['specialty'] = specialty;
    if (location != null) queryParams['location'] = location;

    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.therapistsSearch,
      queryParameters: queryParams,
    );
  }

  /// Get therapist details
  /// 
  /// [therapistId] - Therapist ID
  Future<ApiResponse<Map<String, dynamic>>> getTherapist(String therapistId) async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.therapistDetails(therapistId),
    );
  }

  /// Get therapist availability
  /// 
  /// [therapistId] - Therapist ID
  /// [date] - Date to check availability (ISO format)
  Future<ApiResponse<Map<String, dynamic>>> getAvailability({
    required String therapistId,
    required String date,
  }) async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.therapistAvailability(therapistId),
      queryParameters: {
        'date': date,
      },
    );
  }

  /// Book an appointment with a therapist
  /// 
  /// [therapistId] - Therapist ID
  /// [date] - Appointment date (ISO format)
  /// [time] - Appointment time (HH:MM format)
  /// [duration] - Duration in minutes
  /// [type] - Appointment type ('video', 'phone', 'in-person')
  /// [notes] - Additional notes (optional)
  Future<ApiResponse<Map<String, dynamic>>> bookAppointment({
    required String therapistId,
    required String date,
    required String time,
    required int duration,
    required String type,
    String? notes,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.therapistAppointments(therapistId),
      body: {
        'date': date,
        'time': time,
        'duration': duration,
        'type': type,
        if (notes != null) 'notes': notes,
      },
    );
  }

  /// Rate a therapist
  /// 
  /// [therapistId] - Therapist ID
  /// [rating] - Rating (1-5)
  /// [comment] - Review comment
  Future<ApiResponse<Map<String, dynamic>>> rateTherapist({
    required String therapistId,
    required int rating,
    required String comment,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.therapistReviews(therapistId),
      body: {
        'rating': rating,
        'comment': comment,
      },
    );
  }
}

