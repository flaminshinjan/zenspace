import 'package:zenspace/core/config/app_config.dart';

class FlavorConfig {
  static void initialize(Flavor flavor) {
    switch (flavor) {
      case Flavor.dev:
        AppConfig(
          flavor: Flavor.dev,
          name: 'Zenspace Dev',
          supabaseUrl: 'https://iqbxbgwfkrhbvqtjzfxm.supabase.co',
          supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxYnhiZ3dma3JoYnZxdGp6ZnhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDk5OTc2NzcsImV4cCI6MjAyNTU3MzY3N30.Wd0YPpLgRBHKQWZfZRLgNkEtZBEXwWqKcZGFYjGqGXE',
          shouldCollectCrashlytics: false,
        );
        break;
      case Flavor.testing:
        AppConfig(
          flavor: Flavor.testing,
          name: 'Zenspace Testing',
          supabaseUrl: 'https://iqbxbgwfkrhbvqtjzfxm.supabase.co',
          supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxYnhiZ3dma3JoYnZxdGp6ZnhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDk5OTc2NzcsImV4cCI6MjAyNTU3MzY3N30.Wd0YPpLgRBHKQWZfZRLgNkEtZBEXwWqKcZGFYjGqGXE',
          shouldCollectCrashlytics: true,
        );
        break;
      case Flavor.prod:
        AppConfig(
          flavor: Flavor.prod,
          name: 'Zenspace',
          supabaseUrl: 'https://iqbxbgwfkrhbvqtjzfxm.supabase.co',
          supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxYnhiZ3dma3JoYnZxdGp6ZnhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDk5OTc2NzcsImV4cCI6MjAyNTU3MzY3N30.Wd0YPpLgRBHKQWZfZRLgNkEtZBEXwWqKcZGFYjGqGXE',
          shouldCollectCrashlytics: true,
        );
        break;
    }
  }
} 