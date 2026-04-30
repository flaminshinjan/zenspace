import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenspace/core/config/app_config.dart';
import 'package:zenspace/core/config/flavor_config.dart';
import 'package:zenspace/core/config/supabase_config.dart';
import 'package:zenspace/core/theme/app_theme.dart';
import 'package:zenspace/features/auth/presentation/pages/splash_page.dart';
import 'package:device_preview/device_preview.dart';
import 'package:zenspace/core/network/api_client.dart';

// This will be set by the build system
const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  
  debugPrint('🏁 Starting app initialization...');
  
  // Initialize flavor configuration
  final currentFlavor = _getFlavorFromString(flavor);
  FlavorConfig.initialize(currentFlavor);
  debugPrint('🎨 Flavor initialized: $currentFlavor');
  
  // Initialize API Client
  try {
    await ApiClient().initialize();
    debugPrint('🌐 API Client initialized!');
  } catch (e) {
    debugPrint('❌ Error initializing API Client: $e');
  }
  
  // Initialize Supabase (keeping for backward compatibility)
  try {
    await SupabaseConfig.initialize();
    // Start listening to auth changes
    SupabaseConfig.listenToAuthChanges();
    debugPrint('🎉 App initialization complete!');
  } catch (e) {
    debugPrint('❌ Error during app initialization: $e');
  }
  
  runApp(
    DevicePreview(
      enabled: AppConfig.isDev(),
      builder: (context) => const MyApp(),
    ),
  );
}

Flavor _getFlavorFromString(String flavor) {
  switch (flavor.toLowerCase()) {
    case 'dev':
      return Flavor.dev;
    case 'testing':
      return Flavor.testing;
    case 'prod':
      return Flavor.prod;
    default:
      return Flavor.dev;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.instance.name,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.dark,
      home: const ScaffoldMessenger(
        child: SplashPage(),
      ),
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
    );
  }
} 