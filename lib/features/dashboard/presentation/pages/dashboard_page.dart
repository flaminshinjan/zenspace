import 'package:flutter/material.dart';
import 'package:zenspace/core/constants/asset_constants.dart';
import 'package:zenspace/features/chat/presentation/pages/talk_with_ai_page.dart';
import 'package:zenspace/features/journal/presentation/screens/journal_screen.dart';
import 'package:zenspace/features/music/presentation/pages/make_music_page.dart';
import 'package:zenspace/features/home/presentation/widgets/talk_to_pawpal_widget.dart';
import 'package:zenspace/features/therapists/presentation/pages/therapists_page.dart';
import 'package:zenspace/features/meditation/presentation/pages/meditation_page.dart';
import 'package:zenspace/features/wellness/presentation/pages/wellness_overview_page.dart';
import 'package:zenspace/features/wellness/data/wellness_insights_cache.dart';
import 'package:zenspace/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:zenspace/features/journal/data/repositories/journal_repository.dart';
import 'package:zenspace/features/journal/data/models/journal_entry.dart';
import 'package:zenspace/features/mood/widgets/mood_check_in_widget.dart';

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
  static const Color darkGray2 = Color(0xFF222222);
  static const Color darkGray3 = Color(0xFF2A2A2A);

  late final JournalRepository _journalRepository;
  late Future<List<JournalEntry>> _journalEntries;
  final WellnessInsightsCache _wellnessInsightsCache = WellnessInsightsCache();
  late Future<WellnessInsightsCacheEntry?> _cachedInsights;
  final Set<String> _completedInsightIds = <String>{};

  @override
  void initState() {
    super.initState();
    _journalRepository = JournalRepository();
    _journalEntries = _journalRepository.getJournalEntries();
    _cachedInsights = _wellnessInsightsCache.load();
  }

  void _reloadCachedInsights() {
    setState(() {
      _cachedInsights = _wellnessInsightsCache.load();
    });
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
                                decoration: const BoxDecoration(
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
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const Text(
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
                    
                    // Mood Check-In Widget
                    const MoodCheckInWidget(),
                    
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
                                          const Text(
                                            'Current Mood',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$moodEmoji ${mood.capitalize()}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            moodMessage,
                                            style: const TextStyle(
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
                                    decoration: const BoxDecoration(
                                      color: darkGray3,
                                      borderRadius: BorderRadius.only(
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
                          color: const Color(0xff1D1D1D),
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
                    
                    // Wellness Insights card
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WellnessOverviewPage()),
                        );
                        if (!mounted) return;
                        _reloadCachedInsights();
                      },
                      child: Container(
                        height: 140,
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
                              width: 130,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E3A2F),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(32),
                                    bottomRight: Radius.circular(32),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.watch,
                                    size: 56,
                                    color: const Color(0xFF7C9A92).withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              top: 16,
                              right: 140,
                              child: FutureBuilder<WellnessInsightsCacheEntry?>(
                                future: _cachedInsights,
                                builder: (context, snapshot) {
                                  final cached = snapshot.data;
                                  final hasCached = cached != null && cached.suggestions.isNotEmpty;
                                  final subtitle1 = hasCached
                                      ? '${cached.suggestions.length} AI tips saved'
                                      : 'Apple Watch data + AI';
                                  final subtitle2 = hasCached
                                      ? cached.suggestions.first.title
                                      : 'for stability tips';
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Wellness Insights',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        subtitle1,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                      Text(
                                        subtitle2,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  );
                                },
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

                    FutureBuilder<WellnessInsightsCacheEntry?>(
                      future: _cachedInsights,
                      builder: (context, snapshot) {
                        final cached = snapshot.data;
                        if (cached == null || cached.suggestions.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: darkGray2,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: darkGray3),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF7C9A92).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome,
                                      color: Color(0xFF9BB8B3),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Latest AI Insight',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${_completedInsightIds.length}/${cached.suggestions.length} completed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.75),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...cached.suggestions.map((suggestion) {
                                final isDone = _completedInsightIds.contains(suggestion.id);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: darkGray3.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDone
                                          ? const Color(0xFF7C9A92).withOpacity(0.7)
                                          : Colors.white.withOpacity(0.08),
                                    ),
                                  ),
                                  child: CheckboxListTile(
                                    dense: true,
                                    value: isDone,
                                    activeColor: const Color(0xFF7C9A92),
                                    checkColor: Colors.white,
                                    controlAffinity: ListTileControlAffinity.leading,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                                    onChanged: (_) {
                                      setState(() {
                                        if (isDone) {
                                          _completedInsightIds.remove(suggestion.id);
                                        } else {
                                          _completedInsightIds.add(suggestion.id);
                                        }
                                      });
                                    },
                                    title: Text(
                                      suggestion.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDone
                                            ? Colors.white.withOpacity(0.65)
                                            : Colors.white,
                                        decoration:
                                            isDone ? TextDecoration.lineThrough : TextDecoration.none,
                                      ),
                                    ),
                                    subtitle: Text(
                                      suggestion.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.68),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Updated ${DateFormat('MMM d, h:mm a').format(cached.fetchedAt)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const WellnessOverviewPage(),
                                        ),
                                      );
                                      if (!mounted) return;
                                      _reloadCachedInsights();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF7C9A92),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      minimumSize: Size.zero,
                                    ),
                                    icon: const Icon(Icons.arrow_forward, size: 16),
                                    label: const Text(
                                      'Open',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
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
                            child: SizedBox(
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
                                  const Text(
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
                                  const Text(
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
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
            decoration: const BoxDecoration(
              color: darkGray3,
              borderRadius: BorderRadius.only(
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