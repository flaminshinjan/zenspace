import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/routes/slide_up_route.dart';
import '../../models/journal_entry.dart';
import '../../services/journal_service.dart';
import 'create_journal_page.dart';
import 'journal_detail_page.dart';

class JournalListPage extends StatefulWidget {
  final JournalService journalService;

  const JournalListPage({
    Key? key,
    required this.journalService,
  }) : super(key: key);

  @override
  State<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  late Future<List<JournalEntry>> _journalEntriesFuture;

  final List<Map<String, dynamic>> _moods = [
    {'name': 'Happy', 'emoji': '😊', 'color': Colors.green},
    {'name': 'Calm', 'emoji': '😌', 'color': Colors.purple},
    {'name': 'Sad', 'emoji': '😢', 'color': Colors.blue},
    {'name': 'Anxious', 'emoji': '😰', 'color': Colors.orange},
    {'name': 'Angry', 'emoji': '😠', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _journalEntriesFuture = widget.journalService.getJournalEntries();
  }

  Color _getMoodColor(String mood) {
    final moodData = _moods.firstWhere(
      (m) => m['name'].toLowerCase() == mood.toLowerCase(),
      orElse: () => _moods[0],
    );
    return moodData['color'] as Color;
  }

  String _getMoodEmoji(String mood) {
    final moodData = _moods.firstWhere(
      (m) => m['name'].toLowerCase() == mood.toLowerCase(),
      orElse: () => _moods[0],
    );
    return moodData['emoji'] as String;
  }

  Map<DateTime, List<JournalEntry>> _groupEntriesByDate(List<JournalEntry> entries) {
    final grouped = <DateTime, List<JournalEntry>>{};
    for (final entry in entries) {
      final date = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(entry);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5DE), // Cream background color
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFFF3F5DE),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'My Journal',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFAE6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        SlideUpRoute(
                          page: CreateJournalPage(
                            journalService: widget.journalService,
                          ),
                        ),
                      ).then((_) {
                        setState(() {
                          _journalEntriesFuture = widget.journalService.getJournalEntries();
                        });
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: kBottomNavigationBarHeight + 16, // Add bottom padding for navigation bar
            ),
            sliver: FutureBuilder<List<JournalEntry>>(
              future: _journalEntriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  );
                }

                final entries = snapshot.data ?? [];

                if (entries.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 64,
                            color: Colors.black.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No journal entries yet',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to create your first entry',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final groupedEntries = _groupEntriesByDate(entries);
                final dates = groupedEntries.keys.toList();

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final date = dates[index];
                      final dateEntries = groupedEntries[date]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index > 0) const SizedBox(height: 24),
                          Text(
                            DateFormat.yMMMd().format(date),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...dateEntries.map((entry) {
                            final moodColor = _getMoodColor(entry.mood);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFAE6),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(0, 4),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SlideUpRoute(
                                          page: JournalDetailPage(
                                            entry: entry,
                                            journalService: widget.journalService,
                                          ),
                                        ),
                                      ).then((shouldRefresh) {
                                        if (shouldRefresh == true) {
                                          setState(() {
                                            _journalEntriesFuture = widget.journalService.getJournalEntries();
                                          });
                                        }
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.black,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  _getMoodEmoji(entry.mood),
                                                  style: const TextStyle(fontSize: 20),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      DateFormat.jm().format(entry.createdAt),
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        color: Colors.black.withOpacity(0.6),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      entry.mood.toUpperCase(),
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right,
                                                color: Colors.black.withOpacity(0.4),
                                              ),
                                            ],
                                          ),
                                          if (entry.content.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Text(
                                              entry.content,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                height: 1.5,
                                                color: Colors.black.withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                    childCount: dates.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 