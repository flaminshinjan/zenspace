import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String _supabaseUrl = 'https://ehjmotmkndavlahzemfz.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVoam1vdG1rbmRhdmxhaHplbWZ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI2NjU1NTksImV4cCI6MjA1ODI0MTU1OX0.V3sNslFLCnBWDSHYzId0Paa3c5ifFeIp9lt06XZp2vU';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
} 