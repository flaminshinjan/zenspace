import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zenspace/core/theme/app_colors.dart';
import 'package:zenspace/features/journal/data/repositories/journal_repository.dart';
import 'package:zenspace/features/journal/domain/models/journal_entry.dart';
import 'package:zenspace/features/journal/presentation/pages/create_journal_page.dart';

class JournalListPage extends StatefulWidget {
  const JournalListPage({super.key});

  @override
  State<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  final _repository = JournalRepository();
  final _dateFormat = DateFormat('MMMM d, yyyy');
  final _timeFormat = DateFormat('h:mm a');
  bool _isLoading = true;
  List<JournalEntry> _entries = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final entries = await _repository.getJournalEntries();
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Map<DateTime, List<JournalEntry>> _groupEntriesByDate() {
    final groupedEntries = <DateTime, List<JournalEntry>>{};
    
    for (final entry in _entries) {
      final date = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      
      if (!groupedEntries.containsKey(date)) {
        groupedEntries[date] = [];
      }
      groupedEntries[date]!.add(entry);
    }
    
    return Map.fromEntries(
      groupedEntries.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text('My Journal'),
        backgroundColor: AppColors.bgColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading journal entries',
                        style: TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadEntries,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No journal entries yet',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CreateJournalPage(),
                                ),
                              ).then((_) => _loadEntries());
                            },
                            child: const Text('Start Journaling'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadEntries,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _groupEntriesByDate().length,
                        itemBuilder: (context, index) {
                          final date = _groupEntriesByDate().keys.elementAt(index);
                          final entries = _groupEntriesByDate()[date]!;
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  _dateFormat.format(date),
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              ...entries.map((entry) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Text(
                                    entry.mood.emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  title: Text(
                                    entry.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    _timeFormat.format(entry.createdAt),
                                    style: TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                  onTap: () {
                                    // TODO: Navigate to journal entry detail page
                                  },
                                ),
                              )),
                            ],
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateJournalPage(),
            ),
          ).then((_) => _loadEntries());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 