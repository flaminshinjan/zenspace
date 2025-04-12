import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/models/journal_entry.dart';
import '../widgets/journal_mode_card.dart';
import '../widgets/calendar_strip.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late final JournalRepository _journalRepository;
  List<JournalEntry> _journalEntries = [];
  bool _isLoading = true;
  int _displayedEntries = 2; // Initially show 2 entries
  static const int _entriesPerPage = 5; // Load 5 more entries when "View All" is pressed

  @override
  void initState() {
    super.initState();
    _journalRepository = JournalRepository(Supabase.instance.client);
    _loadJournalEntries();
  }

  Future<void> _loadJournalEntries() async {
    try {
      final entries = await _journalRepository.getJournalEntries();
      setState(() {
        _journalEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _openJournalMode(BuildContext context, String mode) {
    Navigator.pushNamed(context, '/journal/$mode');
  }

  void _loadMoreEntries() {
    setState(() {
      _displayedEntries += _entriesPerPage;
    });
  }

  Widget _buildJournalEntries() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_journalEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 48,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No journal entries yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your journaling journey today',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Get the entries to display based on current _displayedEntries value
    final entriesToShow = _journalEntries.take(_displayedEntries).toList();
    final hasMoreEntries = _journalEntries.length > _displayedEntries;

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entriesToShow.length,
          itemBuilder: (context, index) {
            final entry = entriesToShow[index];
            
            // Get user messages from conversation
            final userMessages = entry.conversation
                .where((msg) => msg['role'] == 'user')
                .map((msg) => msg['content'])
                .where((content) => content != null && content.isNotEmpty)
                .toList();

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/journal/custom',
                      arguments: {
                        'entry': entry,
                        'mode': 'custom',
                      },
                    ).then((_) => _loadJournalEntries());
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('MMM d').format(entry.createdAt),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('h:mm a').format(entry.createdAt).toLowerCase(),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (entry.mood != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      entry.mood!,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (entry.moodValue != null) ...[
                                      const SizedBox(width: 6),
                                      Icon(
                                        _getMoodIcon(entry.moodValue!),
                                        color: Colors.white.withOpacity(0.7),
                                        size: 16,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          entry.title,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (userMessages.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            userMessages.join(' | '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                        if (entry.conversation.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${entry.conversation.length} entries',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (hasMoreEntries)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton(
              onPressed: _loadMoreEntries,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.05),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View More',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  IconData _getMoodIcon(int moodValue) {
    switch (moodValue) {
      case 1:
        return Icons.sentiment_very_dissatisfied_outlined;
      case 2:
        return Icons.sentiment_dissatisfied_outlined;
      case 3:
        return Icons.sentiment_neutral_outlined;
      case 4:
        return Icons.sentiment_satisfied_outlined;
      case 5:
        return Icons.sentiment_very_satisfied_outlined;
      default:
        return Icons.sentiment_neutral_outlined;
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
    final greeting = _getGreeting();
    final date = DateFormat('dd MMMM').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                
              ],
            ),
            const SizedBox(height: 10),
            
            // Calendar Strip
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const CalendarStrip(),
            ),
          
            const SizedBox(height: 24),
            
            // Journal Mode Cards
            SizedBox(
              height: 120, // Fixed height for first row
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: JournalModeCard(
                      icon: Icons.lightbulb_outline,
                      title: 'The Five\nWhys Journal',
                      onTap: () => _openJournalMode(context, 'five_whys'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: JournalModeCard(
                      icon: Icons.add,
                      title: 'Add or Edit',
                      isOutlined: true,
                      onTap: () => _openJournalMode(context, 'custom'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120, // Fixed height for second row
              child: Row(
                children: [
                  Expanded(
                    child: JournalModeCard(
                      icon: Icons.auto_awesome,
                      title: 'Journaling',
                      onTap: () => _openJournalMode(context, 'suggestions'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: JournalModeCard(
                      icon: Icons.description_outlined,
                      title: 'Empty Page',
                      onTap: () => _openJournalMode(context, 'empty'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: JournalModeCard(
                      icon: Icons.mood,
                      title: 'Mood\nCheck-In',
                      onTap: () => _openJournalMode(context, 'mood'),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Past Entries Section
            Row(
              children: [
                Text(
                  'Entries',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                
              ],
            ),
            const SizedBox(height: 10),
            _buildJournalEntries(),
             const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
} 