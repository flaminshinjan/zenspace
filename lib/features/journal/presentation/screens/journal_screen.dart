import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/models/journal_entry.dart';
import '../widgets/journal_mode_card.dart';
import '../widgets/calendar_strip.dart';
import '../pages/journal_detail_page.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late final JournalRepository _journalRepository;
  List<JournalEntry> _journalEntries = [];
  bool _isLoading = true;
  int _displayedEntries = 3;
  static const int _entriesPerPage = 5;

  @override
  void initState() {
    super.initState();
    _journalRepository = JournalRepository();
    _loadJournalEntries();
  }

  Future<void> _loadJournalEntries() async {
    try {
      final entries = await _journalRepository.getJournalEntries();
      if (!mounted) return;
      setState(() {
        _journalEntries = entries;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openJournalMode(BuildContext context, String mode) async {
    final result = await Navigator.pushNamed(context, '/journal/$mode');
    if (result == true) {
      setState(() => _isLoading = true);
      await _loadJournalEntries();
    }
  }

  void _loadMoreEntries() {
    setState(() => _displayedEntries += _entriesPerPage);
  }

  // ---------- derived stats ----------

  int get _streakDays {
    if (_journalEntries.isEmpty) return 0;
    final dates = _journalEntries
        .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet();
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    var streak = 0;
    var cursor = todayKey;
    if (!dates.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!dates.contains(cursor)) return 0;
    }
    while (dates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get _entriesThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartKey = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return _journalEntries.where((e) => !e.createdAt.isBefore(weekStartKey)).length;
  }

  bool get _hasEntryToday {
    final today = DateTime.now();
    return _journalEntries.any((e) =>
        e.createdAt.year == today.year &&
        e.createdAt.month == today.month &&
        e.createdAt.day == today.day);
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

  // ---------- widgets ----------

  Widget _buildStatsRow() {
    final streak = _streakDays;
    final weekly = _entriesThisWeek;
    final total = _journalEntries.length;

    Widget statCard({
      required IconData icon,
      required String value,
      required String label,
      required Color accent,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withOpacity(0.18), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        statCard(
          icon: Icons.local_fire_department_rounded,
          value: '$streak',
          label: streak == 1 ? 'day streak' : 'day streak',
          accent: const Color(0xFFFF8A4C),
        ),
        const SizedBox(width: 10),
        statCard(
          icon: Icons.calendar_today_rounded,
          value: '$weekly',
          label: 'this week',
          accent: const Color(0xFF7AC3FF),
        ),
        const SizedBox(width: 10),
        statCard(
          icon: Icons.menu_book_rounded,
          value: '$total',
          label: 'entries',
          accent: const Color(0xFFB39CFF),
        ),
      ],
    );
  }

  Widget _buildModeGrid() {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Row(
            children: [
              Expanded(
                child: JournalModeCard(
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'Five Whys',
                  subtitle: 'Get to the root of a feeling',
                  accentColor: const Color(0xFFFFC36E),
                  onTap: () => _openJournalMode(context, 'five_whys'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: JournalModeCard(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Guided Prompts',
                  subtitle: 'AI-led reflection',
                  accentColor: const Color(0xFFB39CFF),
                  onTap: () => _openJournalMode(context, 'suggestions'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: Row(
            children: [
              Expanded(
                child: JournalModeCard(
                  icon: Icons.edit_note_rounded,
                  title: 'Free Write',
                  subtitle: 'A blank page, just for you',
                  accentColor: const Color(0xFF7AC3FF),
                  onTap: () => _openJournalMode(context, 'empty'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: JournalModeCard(
                  icon: Icons.mood_rounded,
                  title: 'Mood Check-In',
                  subtitle: 'A quick emotional pulse',
                  accentColor: const Color(0xFF74E5C7),
                  onTap: () => _openJournalMode(context, 'mood'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    final userMessages = entry.conversation
        .where((msg) => msg['role'] == 'user')
        .map((msg) => msg['content'])
        .where((content) => content != null && content.toString().isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JournalDetailPage(
                  entryId: entry.id,
                  journalRepository: _journalRepository,
                ),
              ),
            );
            if (result == true) _loadJournalEntries();
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      DateFormat('MMM d').format(entry.createdAt),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('h:mm a').format(entry.createdAt).toLowerCase(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (entry.moodValue != null)
                      Icon(
                        _getMoodIcon(entry.moodValue!),
                        color: Colors.white.withOpacity(0.7),
                        size: 18,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  entry.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                if (userMessages.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    userMessages.first.toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
                if (entry.conversation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 13,
                        color: Colors.white.withOpacity(0.45),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${entry.conversation.length} messages',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFB39CFF).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 36,
              color: Color(0xFFB39CFF),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Begin your journal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Reflect on your day with a guided prompt\nor pick a mode above to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => _openJournalMode(context, 'suggestions'),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Text('Try a guided prompt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB39CFF),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalEntries() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_journalEntries.isEmpty) return _buildEmptyState();

    final entriesToShow = _journalEntries.take(_displayedEntries).toList();
    final hasMoreEntries = _journalEntries.length > _displayedEntries;

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entriesToShow.length,
          itemBuilder: (context, index) => _buildEntryCard(entriesToShow[index]),
        ),
        if (hasMoreEntries)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: TextButton.icon(
              onPressed: _loadMoreEntries,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Colors.white.withOpacity(0.7),
              ),
              label: Text(
                'View ${_journalEntries.length - _displayedEntries} more',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.05),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTodayNudge() {
    if (_isLoading || _hasEntryToday || _journalEntries.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openJournalMode(context, 'mood'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x33B39CFF), Color(0x117AC3FF)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFB39CFF).withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB39CFF).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wb_twilight_rounded,
                    color: Color(0xFFB39CFF),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No entry yet today',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'A 2-minute mood check-in keeps your streak alive.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting();
    final date = DateFormat('EEEE, dd MMM').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openJournalMode(context, 'custom'),
        backgroundColor: const Color(0xFFB39CFF),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New entry',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadJournalEntries,
          color: const Color(0xFFB39CFF),
          backgroundColor: const Color(0xFF1E1E1E),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              // Header
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
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Stats row
              _buildStatsRow(),
              const SizedBox(height: 18),

              // Calendar Strip
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const CalendarStrip(),
              ),
              const SizedBox(height: 22),

              // Today nudge (only if user has entries but none today)
              _buildTodayNudge(),

              // Section title
              Text(
                'Start writing',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),

              // 2x2 mode grid
              _buildModeGrid(),
              const SizedBox(height: 28),

              // Entries header
              Row(
                children: [
                  Text(
                    'Your entries',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!_isLoading && _journalEntries.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_journalEntries.length}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildJournalEntries(),
            ],
          ),
        ),
      ),
    );
  }
}
