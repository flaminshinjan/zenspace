import '../constants/api_constants.dart';
import '../network/api_client.dart';

/// Journal Service (API version)
/// 
/// Handles all journal-related API calls
class JournalServiceApi {
  final ApiClient _apiClient = ApiClient();

  /// Create a new journal entry
  /// 
  /// [content] - Journal entry content
  /// [mood] - Current mood (required)
  /// [mode] - Journaling mode (optional)
  /// [tags] - List of tags (optional)
  /// [isPrivate] - Privacy setting (default: true)
  Future<ApiResponse<Map<String, dynamic>>> createEntry({
    required String content,
    required String mood,
    String? mode,
    List<String>? tags,
    bool isPrivate = true,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.journalEntries,
      body: {
        'content': content,
        'mood': mood,
        if (mode != null) 'mode': mode,
        if (tags != null) 'tags': tags,
        'is_private': isPrivate,
      },
    );
  }

  /// Get all journal entries with pagination
  /// 
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 20)
  Future<ApiResponse<dynamic>> getEntries({
    int page = 1,
    int limit = 20,
  }) async {
    return await _apiClient.get<dynamic>(
      ApiConstants.journalEntries,
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
  }

  /// Get a single journal entry by ID
  /// 
  /// [entryId] - Journal entry ID
  Future<ApiResponse<Map<String, dynamic>>> getEntry(String entryId) async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.journalEntry(entryId),
    );
  }

  /// Update a journal entry
  /// 
  /// [entryId] - Journal entry ID
  /// [content] - Updated content (optional)
  /// [mood] - Updated mood (optional)
  /// [tags] - Updated tags (optional)
  Future<ApiResponse<Map<String, dynamic>>> updateEntry({
    required String entryId,
    String? content,
    String? mood,
    List<String>? tags,
  }) async {
    final body = <String, dynamic>{};
    if (content != null) body['content'] = content;
    if (mood != null) body['mood'] = mood;
    if (tags != null) body['tags'] = tags;

    return await _apiClient.put<Map<String, dynamic>>(
      ApiConstants.journalEntryUpdate(entryId),
      body: body,
    );
  }

  /// Delete a journal entry
  /// 
  /// [entryId] - Journal entry ID
  Future<ApiResponse<Map<String, dynamic>>> deleteEntry(String entryId) async {
    return await _apiClient.delete<Map<String, dynamic>>(
      ApiConstants.journalEntryDelete(entryId),
    );
  }

  /// Create journal entry from chat session
  /// 
  /// [sessionId] - Chat session ID
  /// [mood] - Optional mood override
  /// [mode] - Optional journaling mode
  /// [tags] - Optional tags
  Future<ApiResponse<dynamic>> createEntryFromChat({
    required String sessionId,
    String? mood,
    String? mode,
    List<String>? tags,
  }) async {
    return await _apiClient.post<dynamic>(
      '/journal/entries/from-chat',
      body: {
        'session_id': sessionId,
        if (mood != null) 'mood': mood,
        if (mode != null) 'mode': mode,
        if (tags != null) 'tags': tags,
      },
    );
  }

  /// Get journal entries for calendar view
  /// 
  /// [year] - Year (e.g., 2024)
  /// [month] - Month (1-12)
  Future<ApiResponse<Map<String, dynamic>>> getCalendarEntries({
    required int year,
    required int month,
  }) async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.journalCalendar,
      queryParameters: {
        'year': year.toString(),
        'month': month.toString(),
      },
    );
  }

  /// Get AI-powered journal suggestions
  /// 
  /// [mode] - Journaling mode (required)
  /// [mood] - Current mood (optional)
  /// [context] - Additional context (optional)
  Future<ApiResponse<Map<String, dynamic>>> getAiSuggestions({
    required String mode,
    String? mood,
    String? context,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.journalAiSuggestions,
      body: {
        'mode': mode,
        if (mood != null) 'mood': mood,
        if (context != null) 'context': context,
      },
    );
  }

  /// Get mood analytics
  /// 
  /// [startDate] - Start date (ISO format)
  /// [endDate] - End date (ISO format)
  Future<ApiResponse<Map<String, dynamic>>> getMoodAnalytics({
    required String startDate,
    required String endDate,
  }) async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.journalMoodAnalytics,
      queryParameters: {
        'start_date': startDate,
        'end_date': endDate,
      },
    );
  }
}

