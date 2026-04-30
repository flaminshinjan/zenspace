import 'package:flutter/material.dart';
import 'package:zenspace/features/auth/presentation/pages/intro_page.dart';
import 'package:zenspace/core/constants/asset_constants.dart';
import 'package:zenspace/features/main/presentation/pages/main_page.dart';
import 'package:zenspace/core/network/api_client.dart';
import 'package:zenspace/core/services/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasCheckedAuth = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    if (_hasCheckedAuth) return;
    _hasCheckedAuth = true;

    try {
      debugPrint('🔍 Checking authentication status...');
      
      // Check if API token exists
      final apiClient = ApiClient();
      final hasToken = apiClient.accessToken != null;
      
      debugPrint('👤 Token status: ${hasToken ? 'Token found' : 'No token'}');
      debugPrint('🔑 Access token: ${apiClient.accessToken?.substring(0, 20) ?? 'null'}...');
      
      // Add a small delay for splash screen visibility
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      if (hasToken) {
        // Verify token is still valid by checking user data
        final authService = AuthService();
        final userEmail = await authService.getCurrentUserEmail();
        final userId = await authService.getCurrentUserId();
        
        debugPrint('📧 User email: $userEmail');
        debugPrint('🆔 User ID: $userId');

        if (userEmail != null && userId != null) {
          debugPrint('✅ Valid session found');
          debugPrint('➡️ Navigating to MainPage');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
          return;
        } else {
          debugPrint('⚠️ Token exists but user data missing');
        }
      } else {
        debugPrint('❌ No authentication token found');
      }
      
      debugPrint('➡️ Navigating to IntroPage');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const IntroPage()),
      );
    } catch (e) {
      debugPrint('❌ Error during auth check: $e');
      if (!mounted) return;
      
      debugPrint('➡️ Navigating to IntroPage due to error');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const IntroPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff161B1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AssetConstants.logo,
              width: 200,
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
} 