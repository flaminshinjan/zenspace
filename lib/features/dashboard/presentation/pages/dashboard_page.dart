import 'package:flutter/material.dart';
import 'package:zenspace/core/constants/asset_constants.dart';
import 'package:zenspace/features/chat/presentation/pages/talk_with_ai_page.dart';
import 'package:zenspace/features/journal/presentation/screens/journal_screen.dart';
import 'package:zenspace/features/music/presentation/pages/make_music_page.dart';
import 'package:zenspace/features/profile/presentation/pages/profile_page.dart';
import 'package:zenspace/features/home/presentation/widgets/talk_to_pawpal_widget.dart';
import 'package:zenspace/features/journal/presentation/pages/journal_page.dart';
import 'package:zenspace/features/therapists/presentation/pages/therapists_page.dart';
import 'package:zenspace/features/meditation/presentation/pages/meditation_page.dart';
import 'package:zenspace/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:zenspace/features/journal/services/journal_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenspace/features/journal/models/journal_entry.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Custom dark colors
  static const Color darkGray1 = Color(0xFF1A1A1A);
  static const Color darkGray2 = Color(0xFF222222);
  static const Color darkGray3 = Color(0xFF2A2A2A);

  late final JournalService _journalService;
  late Future<List<JournalEntry>> _journalEntries;

  @override
  void initState() {
    super.initState();
    _journalService = JournalService(Supabase.instance.client);
    _journalEntries = _journalService.getJournalEntries();
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'anxious':
        return '😰';
      case 'calm':
        return '😌';
      case 'excited':
        return '🤩';
      case 'tired':
        return '😴';
      case 'grateful':
        return '🙏';
      case 'neutral':
        return '😐';
      default:
        return '😊';
    }
  }

  String _getMoodMessage(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return 'Keep up the good vibes!';
      case 'sad':
        return 'It\'s okay to feel this way';
      case 'angry':
        return 'Take a deep breath';
      case 'anxious':
        return 'You\'re stronger than this feeling';
      case 'calm':
        return 'Peace is within you';
      case 'excited':
        return 'Enjoy the moment!';
      case 'tired':
        return 'Rest when you need to';
      case 'grateful':
        return 'Gratitude is powerful';
      case 'neutral':
        return 'Every feeling is valid';
      default:
        return 'Keep up the good vibes!';
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d').format(now);
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: darkGray2,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: darkGray3,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person, color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    'Shinjan',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                      ],
                    ),
                    const TalkToPawpalWidget(),
                    // Insights Grid
                    Column(
                      children: [
                        // First row - Large mood card
                        FutureBuilder<List<JournalEntry>>(
                          future: _journalEntries,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: darkGray2,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: darkGray3, width: 1),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final entries = snapshot.data ?? [];
                            final latestEntry = entries.isNotEmpty ? entries.first : null;
                            final mood = latestEntry?.mood ?? 'neutral';
                            final moodEmoji = _getMoodEmoji(mood);
                            final moodMessage = _getMoodMessage(mood);

                            return Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: darkGray2,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: darkGray3, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Current Mood',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$moodEmoji ${mood.capitalize()}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            moodMessage,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: darkGray3,
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        moodEmoji,
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        // Second row - Two medium cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildMediumCard(
                                'Meditation',
                                '15 min',
                                'Today\'s session',
                                Icons.self_improvement,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FutureBuilder<List<JournalEntry>>(
                                future: _journalEntries,
                                builder: (context, snapshot) {
                                  final count = snapshot.data?.length ?? 0;
                                  return _buildMediumCard(
                                    'Journal',
                                    '$count entries',
                                    'This week',
                                    Icons.edit_note,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Talk to Pawpal Widget
                    
                    
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
                          color: Color(0xff1D1D1D),
                          borderRadius: BorderRadius.circular(32),
                         
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                AssetConstants.walkingDog,
                                
                                height: 10,
                              ),
                            ),
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: Container(
                                padding: const EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  color: darkGray2,
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
                                color: darkGray2,
                                borderRadius: BorderRadius.circular(32),
                                
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
                                MaterialPageRoute(builder: (context) => const JournalScreen()),
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
                          MaterialPageRoute(builder: (context) => const MeditationPage()),
                        );
                      },
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: darkGray2,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              width: 120,
                              child: Image.asset(
                                AssetConstants.meditationHuman,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              left: 16,
                              top: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Guided Meditation',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Find peace through',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  Text(
                                    'guided sessions',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 16,
                              bottom: 16,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: darkGray3.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Music Generation card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MakeMusicPage()),
                        );
                      },
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: darkGray2,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              width: 140,
                              child: Image.asset(
                                AssetConstants.rocky,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              left: 16,
                              top: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create Music',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Generate your own',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  Text(
                                    'unique melodies',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 16,
                              bottom: 16,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: darkGray3.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 24,
                                ),
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

  Widget _buildMediumCard(String title, String value, String subtitle, IconData icon) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: darkGray2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darkGray3, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 50,
            decoration: BoxDecoration(
              color: darkGray3,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 