import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenspace/features/auth/presentation/pages/intro_page.dart';
import 'package:zenspace/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:zenspace/core/constants/asset_constants.dart';
import 'package:zenspace/features/main/presentation/pages/main_page.dart';

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
      final session = Supabase.instance.client.auth.currentSession;
      
      // Add a small delay for splash screen visibility
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      debugPrint('👤 Session status: ${session != null ? 'Authenticated' : 'Not authenticated'}');
      debugPrint('📧 User email: ${session?.user.email}');

      if (session?.user != null) {
        debugPrint('➡️ Navigating to MainPage');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        debugPrint('➡️ Navigating to IntroPage');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const IntroPage()),
        );
      }
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
      backgroundColor: Colors.white,
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
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
} 