import 'dart:io';
import '../constants/api_constants.dart';
import '../network/api_client.dart';

/// Chat Service (API version)
/// 
/// Handles all AI chat-related API calls
class ChatServiceApi {
  final ApiClient _apiClient = ApiClient();

  /// Get available AI companions
  Future<ApiResponse<Map<String, dynamic>>> getCompanions() async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chatCompanions,
    );
  }

  /// Create a new chat session
  /// 
  /// [companionId] - ID of the AI companion
  /// [sessionType] - Type of session ('text' or 'voice')
  Future<ApiResponse<Map<String, dynamic>>> createSession({
    required String companionId,
    required String sessionType,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chatSessions,
      body: {
        'companion_id': companionId,
        'session_type': sessionType,
      },
    );
  }

  /// Get all chat sessions with pagination
  /// 
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 10)
  Future<ApiResponse<Map<String, dynamic>>> getSessions({
    int page = 1,
    int limit = 10,
  }) async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chatSessions,
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
  }

  /// Send a message to AI companion
  /// 
  /// [sessionId] - Chat session ID
  /// [message] - User's message
  Future<ApiResponse<Map<String, dynamic>>> sendMessage({
    required String sessionId,
    required String message,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chatSessionMessages(sessionId),
      body: {
        'message': message,
      },
    );
  }

  /// Get messages from a chat session
  /// 
  /// [sessionId] - Chat session ID
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 50)
  Future<ApiResponse<Map<String, dynamic>>> getMessages({
    required String sessionId,
    int page = 1,
    int limit = 50,
  }) async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chatSessionMessages(sessionId),
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
  }

  /// End a chat session (generates AI summary)
  /// 
  /// [sessionId] - Chat session ID
  Future<ApiResponse<Map<String, dynamic>>> endSession(String sessionId) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chatSessionEnd(sessionId),
    );
  }

  /// Convert speech to text
  /// 
  /// [audioFile] - Audio file to transcribe
  Future<ApiResponse<Map<String, dynamic>>> speechToText({
    required File audioFile,
  }) async {
    return await _apiClient.postMultipart<Map<String, dynamic>>(
      ApiConstants.chatSpeechToText,
      fields: {},
      fileField: 'audio',
      file: audioFile,
    );
  }

  /// Convert text to speech
  /// 
  /// [text] - Text to convert to speech
  /// [voice] - Voice type (optional)
  Future<ApiResponse<Map<String, dynamic>>> textToSpeech({
    required String text,
    String? voice,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chatTextToSpeech,
      body: {
        'text': text,
        if (voice != null) 'voice': voice,
      },
    );
  }
}

