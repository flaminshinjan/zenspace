import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zenspace/core/constants/asset_constants.dart';
import 'package:zenspace/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:zenspace/features/chat/presentation/pages/talk_with_ai_page.dart';
import 'package:zenspace/features/music/presentation/pages/make_music_page.dart';
import 'package:zenspace/features/profile/presentation/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const TalkWithAIPage(),
    const MakeMusicPage(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5DE),
      body: Stack(
        children: [
          // Page content
          _pages[_currentIndex],
          
          // Floating bottom navigation
          Positioned(
            left: 16,
            right: 16,
            bottom: 25,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAE6),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Colors.black,
                  width: 3,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 8),
                    spreadRadius: 0,
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Home
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onTabTapped(0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AssetConstants.dogHouse,
                            width: 37,
                            height: 37,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 24,
                            height: 3,
                            color: _currentIndex == 0 ? const Color(0xFFBFD342) : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Talk with AI
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onTabTapped(1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AssetConstants.runningDog,
                            width: 37,
                            height: 37,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 24,
                            height: 3,
                            color: _currentIndex == 1 ? const Color(0xFFBFD342) : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Make Music
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onTabTapped(2),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AssetConstants.meditatingDog,
                            width: 37,
                            height: 37,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 24,
                            height: 3,
                            color: _currentIndex == 2 ? const Color(0xFFBFD342) : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Profile
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onTabTapped(3),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AssetConstants.happyDog,
                            width: 37,
                            height: 37,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 24,
                            height: 3,
                            color: _currentIndex == 3 ? const Color(0xFFBFD342) : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 