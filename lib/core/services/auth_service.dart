import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../network/api_client.dart';

/// Authentication Service
/// 
/// Handles all authentication-related API calls
class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Register a new user
  /// 
  /// [email] - User's email address
  /// [password] - User's password
  /// [fullName] - User's full name
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.authRegister,
      body: {
        'email': email,
        'password': password,
        'full_name': fullName,
      },
      includeAuth: false,
    );

    if (response.success && response.data != null) {
      await _saveAuthData(response.data!);
    }

    return response;
  }

  /// Login user with email and password
  /// 
  /// [email] - User's email address
  /// [password] - User's password
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.authLogin,
      body: {
        'email': email,
        'password': password,
      },
      includeAuth: false,
    );

    if (response.success && response.data != null) {
      await _saveAuthData(response.data!);
    }

    return response;
  }

  /// OAuth Login (Google/Apple)
  /// 
  /// [provider] - OAuth provider ('google' or 'apple')
  /// [idToken] - OAuth ID token
  /// [accessToken] - OAuth access token
  Future<ApiResponse<Map<String, dynamic>>> oauthLogin({
    required String provider,
    required String idToken,
    String? accessToken,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.authOAuth}/$provider',
      body: {
        'id_token': idToken,
        if (accessToken != null) 'access_token': accessToken,
      },
      includeAuth: false,
    );

    if (response.success && response.data != null) {
      await _saveAuthData(response.data!);
    }

    return response;
  }

  /// Logout user
  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    final refreshToken = _apiClient.refreshToken;
    
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.authLogout,
      body: {
        'refresh_token': refreshToken,
      },
    );

    // Clear tokens regardless of response
    await _apiClient.clearTokens();

    return response;
  }

  /// Request password reset
  /// 
  /// [email] - User's email address
  Future<ApiResponse<Map<String, dynamic>>> requestPasswordReset({
    required String email,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.authPasswordResetRequest,
      body: {
        'email': email,
      },
      includeAuth: false,
    );
  }

  /// Confirm password reset
  /// 
  /// [token] - Reset token from email
  /// [newPassword] - New password
  Future<ApiResponse<Map<String, dynamic>>> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.authPasswordResetConfirm,
      body: {
        'token': token,
        'new_password': newPassword,
      },
      includeAuth: false,
    );
  }

  /// Save authentication data to local storage
  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    print('💾 Saving auth data: $data');
    
    // Extract tokens
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;

    if (accessToken != null && refreshToken != null) {
      await _apiClient.setTokens(accessToken, refreshToken);
      print('✅ Tokens saved: access_token=${accessToken.substring(0, 20)}...');
    } else {
      print('⚠️ No tokens found in response');
    }

    // Extract user data - handle both nested and flat structures
    Map<String, dynamic>? userData;
    
    if (data.containsKey('user')) {
      // Nested structure: { "user": { "id": "...", "email": "..." } }
      userData = data['user'] as Map<String, dynamic>?;
    } else if (data.containsKey('user_id') || data.containsKey('email')) {
      // Flat structure: { "user_id": "...", "email": "...", ... }
      userData = data;
    }

    if (userData != null) {
      final prefs = await SharedPreferences.getInstance();
      
      // Try both 'id' and 'user_id' keys
      final userId = userData['id'] ?? userData['user_id'];
      final email = userData['email'];
      
      if (userId != null) {
        await prefs.setString(ApiConstants.userIdKey, userId.toString());
        print('✅ User ID saved: $userId');
      }
      
      if (email != null) {
        await prefs.setString(ApiConstants.userEmailKey, email.toString());
        print('✅ User email saved: $email');
      }
    } else {
      print('⚠️ No user data found in response');
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return _apiClient.accessToken != null;
  }

  /// Get current user ID from local storage
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConstants.userIdKey);
  }

  /// Get current user email from local storage
  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConstants.userEmailKey);
  }
}

