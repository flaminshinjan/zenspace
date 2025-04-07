import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenspace/core/config/app_config.dart';
import 'package:zenspace/core/config/flavor_config.dart';
import 'package:zenspace/core/config/supabase_config.dart';
import 'package:zenspace/core/theme/app_theme.dart';
import 'package:zenspace/features/auth/presentation/pages/splash_page.dart';

// This will be set by the build system
const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('🏁 Starting app initialization...');
  
  // Initialize flavor configuration
  final currentFlavor = _getFlavorFromString(flavor);
  FlavorConfig.initialize(currentFlavor);
  debugPrint('🎨 Flavor initialized: $currentFlavor');
  
  // Initialize Supabase
  try {
    await SupabaseConfig.initialize();
    // Start listening to auth changes
    SupabaseConfig.listenToAuthChanges();
    debugPrint('🎉 App initialization complete!');
  } catch (e) {
    debugPrint('❌ Error during app initialization: $e');
  }
  
  runApp(const MyApp());
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
      home: ScaffoldMessenger(
        child: const SplashPage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
} 