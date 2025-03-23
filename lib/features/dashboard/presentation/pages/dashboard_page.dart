import 'package:flutter/material.dart';
import 'package:zenspace/core/constants/asset_constants.dart';
import 'package:zenspace/features/chat/presentation/pages/talk_with_ai_page.dart';
import 'package:zenspace/features/music/presentation/pages/make_music_page.dart';
import 'package:zenspace/features/profile/presentation/pages/profile_page.dart';
import 'package:zenspace/features/home/presentation/widgets/talk_to_pawpal_widget.dart';
import 'package:zenspace/features/journal/presentation/pages/journal_page.dart';
import 'package:zenspace/features/therapists/presentation/pages/therapists_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // Color constants
  static const Color primaryYellow = Color(0xFFFFC107);  // Main yellow for buttons and highlights
  static const Color lightYellow = Color(0xFFFFF3D0);    // Light yellow for cards
  static const Color bgColor = Color(0xFFFFFBF2);        // Very light yellow-white background
  static const Color textDark = Color(0xFF2C2C2C);       // Dark text color
  static const Color textLight = Color(0xFF757575);      // Light text color

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        break; // Already on home
      case 1: // Talk with AI
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TalkWithAIPage()),
        );
        break;
      case 2: // Make Music
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MakeMusicPage()),
        );
        break;
      case 3: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header with profile and actions
                    Row(
                      children: [
                        // Profile section
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: lightYellow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Good Afternoon,',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: textDark,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Shinjan',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '@shinzushinjan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textLight,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Action buttons
                        Image.asset(
                          AssetConstants.normalPaw,
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.notifications_outlined, size: 24, color: textDark),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Talk to Pawpal Widget
                    const TalkToPawpalWidget(),
                    const SizedBox(height: 24),
                    
                    // Walking illustration card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TalkWithAIPage()),
                        );
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: lightYellow,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 6),
                              spreadRadius: 0,
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                AssetConstants.walkingDog,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: Container(
                                padding: const EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Image.asset(
                                  AssetConstants.pawButton,
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Two column layout
                    Row(
                      children: [
                        // Counsellor card
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TherapistsPage()),
                              );
                            },
                            child: Container(
                              height: 170,
                              decoration: BoxDecoration(
                                color: lightYellow,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: Colors.black, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(0, 6),
                                    spreadRadius: 0,
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.asset(
                                      AssetConstants.treatDog,
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Journal card
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const JournalPage()),
                              );
                            },
                            child: Container(
                              height: 200,
                              child: Image.asset(
                                AssetConstants.journalCard,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Meditation card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MakeMusicPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightYellow,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 6),
                              spreadRadius: 0,
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              AssetConstants.meditatingDog,
                              height: 100,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'feel your own mind.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textDark,
                                    ),
                                  ),
                                  Image.asset(
                                    AssetConstants.rythm,
                                    height: 50,
                                  ),
                                  Text(
                                    'Heal Mind, Soul, Heart',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Image.asset(
                                AssetConstants.pawButton,
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // Bottom padding for navigation bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 