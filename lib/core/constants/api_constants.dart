/// API Constants
/// 
/// This file contains all API endpoints and configuration
/// for the ZenSpace backend API.
import 'dart:io' show Platform;

class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  // ==================== BASE CONFIGURATION ====================
  static const String _baseUrlOverride = String.fromEnvironment('API_BASE_URL');
  
  /// Base URL for the API
  /// Override with --dart-define=API_BASE_URL=http://<host>:5050
  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) return _baseUrlOverride;
    if (Platform.isAndroid) return 'http://10.0.2.2:5050';
    return 'http://localhost:5050';
  }
  
  /// API Version
  static const String apiVersion = 'v1';
  
  /// Base API Path
  static String get basePath => '$baseUrl/api/$apiVersion';

  // ==================== TIMEOUT CONFIGURATION ====================
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ==================== AUTHENTICATION ENDPOINTS ====================
  
  static const String authBase = '/auth';
  static const String authRegister = '$authBase/register';
  static const String authLogin = '$authBase/login';
  static const String authOAuth = '$authBase/oauth'; // append /{provider}
  static const String authRefresh = '$authBase/refresh';
  static const String authLogout = '$authBase/logout';
  static const String authPasswordResetRequest = '$authBase/password-reset/request';
  static const String authPasswordResetConfirm = '$authBase/password-reset/confirm';

  // ==================== USER ENDPOINTS ====================
  
  static const String usersBase = '/users';
  static const String userProfile = '$usersBase/profile';
  static const String userPreferences = '$usersBase/preferences';
  static const String userStats = '$usersBase/stats';
  static const String userProfilePicture = '$usersBase/profile-picture';

  // ==================== JOURNAL ENDPOINTS ====================
  
  static const String journalBase = '/journal';
  static const String journalEntries = '$journalBase/entries';
  static const String journalCalendar = '$journalEntries/calendar';
  static const String journalAiSuggestions = '$journalBase/ai-suggestions';
  static const String journalMoodAnalytics = '$journalBase/mood-analytics';

  // Helper methods for journal endpoints
  static String journalEntry(String id) => '$journalEntries/$id';
  static String journalEntryUpdate(String id) => '$journalEntries/$id';
  static String journalEntryDelete(String id) => '$journalEntries/$id';

  // ==================== CHAT ENDPOINTS ====================
  
  static const String chatBase = '/chat';
  static const String chatCompanions = '$chatBase/companions';
  static const String chatSessions = '$chatBase/sessions';
  static const String chatSpeechToText = '$chatBase/speech-to-text';
  static const String chatTextToSpeech = '$chatBase/text-to-speech';

  // Helper methods for chat endpoints
  static String chatSessionMessages(String sessionId) => '$chatSessions/$sessionId/messages';
  static String chatSessionEnd(String sessionId) => '$chatSessions/$sessionId/end';

  // ==================== MEDITATION ENDPOINTS ====================
  
  static const String meditationBase = '/meditation';
  static const String meditationSessions = '$meditationBase/sessions';
  static const String meditationHistory = '$meditationBase/history';
  static const String meditationCategories = '$meditationBase/categories';

  // Helper methods for meditation endpoints
  static String meditationSession(String id) => '$meditationSessions/$id';
  static String meditationSessionStart(String id) => '$meditationSessions/$id/start';
  static String meditationSessionComplete(String id) => '$meditationSessions/$id/complete';
  static String meditationSessionRate(String id) => '$meditationSessions/$id/rate';

  // ==================== THERAPIST ENDPOINTS ====================
  
  static const String therapistsBase = '/therapists';
  static const String therapistsSearch = '$therapistsBase/search';

  // Helper methods for therapist endpoints
  static String therapistDetails(String id) => '$therapistsBase/$id';
  static String therapistAvailability(String id) => '$therapistsBase/$id/availability';
  static String therapistAppointments(String id) => '$therapistsBase/$id/appointments';
  static String therapistReviews(String id) => '$therapistsBase/$id/reviews';

  // ==================== APPOINTMENT ENDPOINTS ====================
  
  static const String appointmentsBase = '/appointments';

  // Helper methods for appointment endpoints
  static String appointmentCancel(String id) => '$appointmentsBase/$id/cancel';
  static String appointmentReschedule(String id) => '$appointmentsBase/$id/reschedule';

  // ==================== SUBSCRIPTION ENDPOINTS ====================
  
  static const String subscriptionsBase = '/subscriptions';
  static const String subscriptionPlans = '$subscriptionsBase/plans';
  static const String subscriptionCurrent = '$subscriptionsBase/current';
  static const String subscriptionSubscribe = '$subscriptionsBase/subscribe';
  static const String subscriptionCancel = '$subscriptionsBase/cancel';
  static const String subscriptionPaymentsHistory = '$subscriptionsBase/payments/history';
  static const String subscriptionPaymentsMethods = '$subscriptionsBase/payments/methods';

  // ==================== NOTIFICATION ENDPOINTS ====================
  
  static const String notificationsBase = '/notifications';
  static const String notificationsReadAll = '$notificationsBase/read-all';
  static const String notificationsSettings = '$notificationsBase/settings';
  static const String notificationsDevices = '$notificationsBase/devices';

  // Helper methods for notification endpoints
  static String notificationRead(String id) => '$notificationsBase/$id/read';
  static String notificationDelete(String id) => '$notificationsBase/$id';

  // ==================== MOOD CHECK-IN ENDPOINTS ====================
  
  static const String moodBase = '/mood';
  static const String moodCheckIns = '$moodBase/check-ins';
  static const String moodCheckInToday = '$moodCheckIns/today';
  static const String moodStats = '$moodBase/stats';

  // Helper methods for mood endpoints
  static String moodCheckIn(String id) => '$moodCheckIns/$id';

  // ==================== WELLNESS (ANTHROPIC AI) ENDPOINTS ====================
  
  static const String wellnessBase = '/wellness';
  static const String wellnessInsights = '$wellnessBase/insights';

  // ==================== UTILITY ENDPOINTS ====================
  
  static const String health = '/health';
  static const String docs = '/docs';

  // ==================== STORAGE KEYS ====================
  
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
}

