import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    try {
      debugPrint('🌱 Loading environment variables...');
      await dotenv.load();
      
      final url = dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
      
      debugPrint('🔑 Supabase URL: $url');
      debugPrint('🔐 Anon Key length: ${anonKey?.length ?? 0} characters');
      
      debugPrint('🚀 Initializing Supabase...');
      await Supabase.initialize(
        url: url ?? '',
        anonKey: anonKey ?? '',
        debug: true, // Enable debug mode for more detailed logs
      );
      debugPrint('✅ Supabase initialized successfully!');

      // Test the connection
      final client = Supabase.instance.client;
      final response = await client.from('profiles').select().limit(1);
      debugPrint('📡 Test query response: $response');
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing Supabase:');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  // Helper method to log auth state changes
  static void listenToAuthChanges() {
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