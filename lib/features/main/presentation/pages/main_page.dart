import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenspace/core/constants/asset_constants.dart';
import 'package:zenspace/core/routes/app_routes.dart';
import 'package:zenspace/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:zenspace/features/chat/presentation/pages/talk_with_ai_page.dart';
import 'package:zenspace/features/music/presentation/pages/make_music_page.dart';
import 'package:zenspace/features/profile/presentation/pages/profile_page.dart';
import 'package:zenspace/features/journal/presentation/screens/journal_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with RouteAware {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const DashboardPage(),
    const TalkWithAIPage(),
    const JournalScreen(),
   
    const ProfilePage(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = ModalRoute.of(context)?.settings;
    if (settings?.arguments != null) {
      final args = settings!.arguments as Map<String, dynamic>;
      if (args.containsKey('initialTab')) {
        setState(() {
          _currentIndex = args['initialTab'] as int;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/journal/') == true) {
          return AppRoutes.onGenerateRoute(settings);
        }
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: const Color(0xFF161B1E),
            body: Stack(
              children: [
                // Page content
                IndexedStack(
                  index: _currentIndex,
                  children: _pages,
                ),
                
                // Floating bottom navigation
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 25,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildNavItem(0, AssetConstants.dogHouse),
                            _buildNavItem(1, AssetConstants.runningDog),
                            _buildNavItem(2, AssetConstants.happyDog),
                            _buildNavItem(3, AssetConstants.meditatingDog),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, String assetPath) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              assetPath,
              width: 37,
              height: 37,
            ),
            const SizedBox(height: 4),
            Container(
              width: 30,
              height: 3,
              color: _currentIndex == index ? const Color(0xFF6D737C) : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
} 