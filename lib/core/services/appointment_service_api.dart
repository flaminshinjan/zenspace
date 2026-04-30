import '../constants/api_constants.dart';
import '../network/api_client.dart';

/// Appointment Service (API version)
/// 
/// Handles all appointment-related API calls
class AppointmentServiceApi {
  final ApiClient _apiClient = ApiClient();

  /// Get user appointments
  /// 
  /// [status] - Filter by status ('upcoming', 'past', 'cancelled', optional)
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 10)
  Future<ApiResponse<Map<String, dynamic>>> getAppointments({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null) queryParams['status'] = status;

    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.appointmentsBase,
      queryParameters: queryParams,
    );
  }

  /// Cancel an appointment
  /// 
  /// [appointmentId] - Appointment ID
  /// [reason] - Cancellation reason (optional)
  Future<ApiResponse<Map<String, dynamic>>> cancelAppointment({
    required String appointmentId,
    String? reason,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.appointmentCancel(appointmentId),
      body: {
        if (reason != null) 'reason': reason,
      },
    );
  }

  /// Reschedule an appointment
  /// 
  /// [appointmentId] - Appointment ID
  /// [newDate] - New appointment date (ISO format)
  /// [newTime] - New appointment time (HH:MM format)
  Future<ApiResponse<Map<String, dynamic>>> rescheduleAppointment({
    required String appointmentId,
    required String newDate,
    required String newTime,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.appointmentReschedule(appointmentId),
      body: {
        'new_date': newDate,
        'new_time': newTime,
      },
    );
  }
}

