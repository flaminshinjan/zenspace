import '../constants/api_constants.dart';
import '../network/api_client.dart';

/// Subscription Service (API version)
/// 
/// Handles all subscription and payment-related API calls
class SubscriptionServiceApi {
  final ApiClient _apiClient = ApiClient();

  /// Get available subscription plans
  Future<ApiResponse<Map<String, dynamic>>> getPlans() async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.subscriptionPlans,
    );
  }

  /// Get current subscription
  Future<ApiResponse<Map<String, dynamic>>> getCurrentSubscription() async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.subscriptionCurrent,
    );
  }

  /// Subscribe to a plan
  /// 
  /// [planId] - Plan ID
  /// [paymentMethodId] - Payment method ID
  Future<ApiResponse<Map<String, dynamic>>> subscribe({
    required String planId,
    required String paymentMethodId,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.subscriptionSubscribe,
      body: {
        'plan_id': planId,
        'payment_method_id': paymentMethodId,
      },
    );
  }

  /// Update subscription
  /// 
  /// [planId] - New plan ID
  Future<ApiResponse<Map<String, dynamic>>> updateSubscription({
    required String planId,
  }) async {
    return await _apiClient.put<Map<String, dynamic>>(
      ApiConstants.subscriptionCurrent,
      body: {
        'plan_id': planId,
      },
    );
  }

  /// Cancel subscription
  /// 
  /// [reason] - Cancellation reason (optional)
  Future<ApiResponse<Map<String, dynamic>>> cancelSubscription({
    String? reason,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.subscriptionCancel,
      body: {
        if (reason != null) 'reason': reason,
      },
    );
  }

  /// Get payment history
  /// 
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 20)
  Future<ApiResponse<Map<String, dynamic>>> getPaymentHistory({
    int page = 1,
    int limit = 20,
  }) async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.subscriptionPaymentsHistory,
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
  }

  /// Add payment method
  /// 
  /// [type] - Payment method type ('card', 'paypal', etc.)
  /// [token] - Payment method token
  /// [isDefault] - Set as default payment method
  Future<ApiResponse<Map<String, dynamic>>> addPaymentMethod({
    required String type,
    required String token,
    bool isDefault = false,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.subscriptionPaymentsMethods,
      body: {
        'type': type,
        'token': token,
        'is_default': isDefault,
      },
    );
  }
}

