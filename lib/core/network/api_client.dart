import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

/// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiError? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.failure(ApiError error, {int? statusCode}) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }
}

/// API Error
class ApiError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? 'An unknown error occurred',
      details: json['details'],
    );
  }

  @override
  String toString() => message;
}

/// Main API Client
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();
  String? _accessToken;
  String? _refreshToken;

  /// Initialize the client with stored tokens
  Future<void> initialize() async {
    print('🔄 Initializing API Client...');
    print('🌐 API base URL: ${ApiConstants.baseUrl}');
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(ApiConstants.accessTokenKey);
    _refreshToken = prefs.getString(ApiConstants.refreshTokenKey);
    
    if (_accessToken != null) {
      print('✅ Access token loaded: ${_accessToken!.substring(0, 20)}...');
      print('✅ Refresh token loaded: ${_refreshToken != null ? 'Yes' : 'No'}');
    } else {
      print('⚠️ No stored tokens found');
    }
  }

  /// Set authentication tokens
  Future<void> setTokens(String accessToken, String refreshToken) async {
    print('💾 Saving tokens to storage...');
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.accessTokenKey, accessToken);
    await prefs.setString(ApiConstants.refreshTokenKey, refreshToken);
    
    print('✅ Tokens saved successfully');
    print('   Access token: ${accessToken.substring(0, 20)}...');
    print('   Refresh token: ${refreshToken.substring(0, 20)}...');
  }

  /// Clear authentication tokens
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.accessTokenKey);
    await prefs.remove(ApiConstants.refreshTokenKey);
    await prefs.remove(ApiConstants.userIdKey);
    await prefs.remove(ApiConstants.userEmailKey);
  }

  /// Get current access token
  String? get accessToken => _accessToken;

  /// Get current refresh token
  String? get refreshToken => _refreshToken;

  /// Build full URL
  String _buildUrl(String endpoint) {
    return '${ApiConstants.basePath}$endpoint';
  }

  /// Get headers with auth token
  Map<String, String> _getHeaders({
    bool includeAuth = true,
    Map<String, String>? additionalHeaders,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Refresh access token
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) {
      print('❌ No refresh token available');
      return false;
    }

    try {
      print('🔄 Attempting to refresh access token...');
      
      final url = _buildUrl(ApiConstants.authRefresh);
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'refresh_token': _refreshToken}),
          )
          .timeout(ApiConstants.connectionTimeout);

      print('📥 Refresh response status: ${response.statusCode}');
      print('📥 Refresh response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final newAccessToken = data['data']['access_token'];
          
          if (newAccessToken != null) {
            print('✅ Token refreshed successfully');
            _accessToken = newAccessToken;
            
            // Save new access token
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(ApiConstants.accessTokenKey, newAccessToken);
            
            return true;
          }
        }
      }
      
      print('❌ Token refresh failed: Invalid response');
      return false;
    } catch (e) {
      print('❌ Token refresh error: $e');
      return false;
    }
  }

  /// Handle API response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? parser,
  ) {
    try {
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      final dynamic responseBody = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success response
        final data = responseBody['data'];
        final message = responseBody['message'];

        print('✅ Parsed data: $data');
        print('✅ Data type: ${data.runtimeType}');
        print('✅ Message: $message');

        if (parser != null && data != null) {
          return ApiResponse.success(
            parser(data),
            message: message,
            statusCode: response.statusCode,
          );
        } else {
          // Handle case where data is already the correct type (no casting needed)
          // This fixes the issue where data is a List but T expects Map
          return ApiResponse.success(
            data,
            message: message,
            statusCode: response.statusCode,
          );
        }
      } else {
        // Error response
        final error = ApiError.fromJson(responseBody['error'] ?? {});
        return ApiResponse.failure(error, statusCode: response.statusCode);
      }
    } catch (e) {
      print('❌ Parse error: $e');
      print('❌ Response body: ${response.body}');
      return ApiResponse.failure(
        ApiError(
          code: 'PARSE_ERROR',
          message: 'Failed to parse response: $e',
        ),
        statusCode: response.statusCode,
      );
    }
  }

  /// Execute request with automatic token refresh on 401
  Future<ApiResponse<T>> _executeRequest<T>(
    Future<http.Response> Function() request,
    T Function(dynamic)? parser, {
    bool includeAuth = true,
    bool isRetry = false,
  }) async {
    try {
      final response = await request();
      
      // Check for 401 Unauthorized
      if (response.statusCode == 401 && includeAuth && !isRetry) {
        print('⚠️ Received 401 Unauthorized - attempting token refresh...');
        
        // Try to refresh the token
        final refreshSuccess = await _refreshAccessToken();
        
        if (refreshSuccess) {
          print('✅ Token refreshed, retrying request...');
          // Retry the request with new token
          return await _executeRequest<T>(request, parser, includeAuth: includeAuth, isRetry: true);
        } else {
          print('❌ Token refresh failed - clearing tokens');
          // Refresh failed, clear tokens
          await clearTokens();
          
          return ApiResponse.failure(
            ApiError(
              code: 'AUTHENTICATION_ERROR',
              message: 'Session expired. Please login again.',
            ),
            statusCode: 401,
          );
        }
      }
      
      return _handleResponse<T>(response, parser);
    } on SocketException {
      return ApiResponse.failure(
        ApiError(
          code: 'NETWORK_ERROR',
          message: 'No internet connection',
        ),
      );
    } on TimeoutException {
      return ApiResponse.failure(
        ApiError(
          code: 'TIMEOUT_ERROR',
          message: 'Request timeout',
        ),
      );
    } catch (e) {
      return ApiResponse.failure(
        ApiError(
          code: 'UNKNOWN_ERROR',
          message: 'An error occurred: $e',
        ),
      );
    }
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    T Function(dynamic)? parser,
    bool includeAuth = true,
  }) async {
    String url = _buildUrl(endpoint);
    
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final uri = Uri.parse(url);
      url = uri.replace(queryParameters: queryParameters).toString();
    }

    return _executeRequest<T>(
      () => _client
          .get(
            Uri.parse(url),
            headers: _getHeaders(includeAuth: includeAuth),
          )
          .timeout(ApiConstants.connectionTimeout),
      parser,
      includeAuth: includeAuth,
    );
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? parser,
    bool includeAuth = true,
  }) async {
    final url = _buildUrl(endpoint);
    
    return _executeRequest<T>(
      () => _client
          .post(
            Uri.parse(url),
            headers: _getHeaders(includeAuth: includeAuth),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout),
      parser,
      includeAuth: includeAuth,
    );
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? parser,
    bool includeAuth = true,
  }) async {
    final url = _buildUrl(endpoint);
    
    return _executeRequest<T>(
      () => _client
          .put(
            Uri.parse(url),
            headers: _getHeaders(includeAuth: includeAuth),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout),
      parser,
      includeAuth: includeAuth,
    );
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? parser,
    bool includeAuth = true,
  }) async {
    final url = _buildUrl(endpoint);
    
    return _executeRequest<T>(
      () => _client
          .delete(
            Uri.parse(url),
            headers: _getHeaders(includeAuth: includeAuth),
          )
          .timeout(ApiConstants.connectionTimeout),
      parser,
      includeAuth: includeAuth,
    );
  }

  /// POST request with multipart (for file uploads)
  Future<ApiResponse<T>> postMultipart<T>(
    String endpoint, {
    required Map<String, String> fields,
    required String fileField,
    required File file,
    T Function(dynamic)? parser,
    bool includeAuth = true,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      if (includeAuth && _accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }

      // Add fields
      request.fields.addAll(fields);

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(fileField, file.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response, parser);
    } on SocketException {
      return ApiResponse.failure(
        ApiError(
          code: 'NETWORK_ERROR',
          message: 'No internet connection',
        ),
      );
    } on TimeoutException {
      return ApiResponse.failure(
        ApiError(
          code: 'TIMEOUT_ERROR',
          message: 'Request timeout',
        ),
      );
    } catch (e) {
      return ApiResponse.failure(
        ApiError(
          code: 'UNKNOWN_ERROR',
          message: 'An error occurred: $e',
        ),
      );
    }
  }

  /// Dispose
  void dispose() {
    _client.close();
  }
}

