import 'package:flutter/foundation.dart';

enum Flavor {
  dev,
  prod,
  testing,
}

class AppConfig {
  final Flavor flavor;
  final String name;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final bool shouldCollectCrashlytics;

  static AppConfig? _instance;

  factory AppConfig({
    required Flavor flavor,
    required String name,
    required String supabaseUrl,
    required String supabaseAnonKey,
    required bool shouldCollectCrashlytics,
  }) {
    _instance ??= AppConfig._internal(
      flavor: flavor,
      name: name,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      shouldCollectCrashlytics: shouldCollectCrashlytics,
    );
    return _instance!;
  }

  AppConfig._internal({
    required this.flavor,
    required this.name,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.shouldCollectCrashlytics,
  });

  static AppConfig get instance {
    return _instance!;
  }

  static bool isDev() => _instance?.flavor == Flavor.dev;
  static bool isProd() => _instance?.flavor == Flavor.prod;
  static bool isTesting() => _instance?.flavor == Flavor.testing;
} 