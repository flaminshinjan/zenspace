import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class SupabaseConfig {
  static bool _initialized = false;

  static Future<void> initialize() async {
    try {
      debugPrint('🌱 Loading environment variables...');
      await dotenv.load();

      final url = dotenv.env['SUPABASE_URL'] ?? '';
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

      // Skip init if URL is placeholder/missing (app uses API for auth)
      final isPlaceholder = url.isEmpty ||
          url.contains('your_supabase') ||
          url.contains('placeholder');

      if (isPlaceholder) {
        debugPrint('⏭️ Skipping Supabase init (no valid URL). Using API for auth.');
        return;
      }

      debugPrint('🔑 Supabase URL: $url');
      debugPrint('🚀 Initializing Supabase...');
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        debug: true,
      );
      _initialized = true;
      debugPrint('✅ Supabase initialized successfully!');
    } catch (e) {
      debugPrint('❌ Error initializing Supabase (non-fatal, using API): $e');
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  // Helper method to log auth state changes
  static void listenToAuthChanges() {
    if (!_initialized) return;
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      debugPrint('🔄 Auth State Change:');
      debugPrint('Event: $event');
      debugPrint('User ID: ${session?.user.id}');
      debugPrint('User Email: ${session?.user.email}');
    });
  }
} 