import 'package:zenspace/core/constants/api_constants.dart';
import 'package:zenspace/core/network/api_client.dart';
import 'package:zenspace/features/wellness/models/wellness_data.dart';

/// Service for wellness AI insights (Anthropic wrapper)
/// Sends psycho-physiological data and receives personalized suggestions
class WellnessServiceApi {
  final ApiClient _apiClient = ApiClient();

  static List<WellnessSuggestion> _parseSuggestions(dynamic data) {
    if (data == null) return <WellnessSuggestion>[];
    if (data is List) {
      return data
          .map((e) => WellnessSuggestion.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final suggestions = data['suggestions'] ?? data['items'] ?? data['data'];
      if (suggestions is List) {
        return suggestions
            .map((e) => WellnessSuggestion.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return <WellnessSuggestion>[];
  }

  /// Get AI-powered wellness suggestions based on physiological data
  ///
  /// [wellnessData] - Apple Watch / health data (HR, HRV, sleep, etc.)
  /// Returns list of suggestions for emotional and physical stability
  Future<ApiResponse<List<WellnessSuggestion>>> getInsights({
    required WellnessData wellnessData,
    String? additionalContext, // Optional user context e.g. "feeling anxious today"
  }) async {
    return _apiClient.post<List<WellnessSuggestion>>(
      ApiConstants.wellnessInsights,
      body: {
        'physiological_data': wellnessData.toJson(),
        if (additionalContext != null && additionalContext.isNotEmpty)
          'additional_context': additionalContext,
      },
      parser: _parseSuggestions,
    );
  }
}
