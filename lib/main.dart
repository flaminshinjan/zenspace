import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenspace/core/config/supabase_config.dart';
import 'package:zenspace/core/theme/app_theme.dart';
import 'package:zenspace/features/main/presentation/pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zenspace',
      theme: AppTheme.lightTheme,
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
} 