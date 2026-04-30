import '../models/journal_entry.dart';
import '../../../../core/services/journal_service_api.dart';

class JournalRepository {
  final JournalServiceApi _journalServiceApi;

  JournalRepository() : _journalServiceApi = JournalServiceApi();

  Future<List<JournalEntry>> getJournalEntries() async {
    try {
      print('🔄 Fetching journal entries from API...');
      final apiResponse = await _journalServiceApi.getEntries();
      
      print('📦 Get entries response success: ${apiResponse.success}');
      print('📦 Get entries response data type: ${apiResponse.data.runtimeType}');
      print('📦 Get entries response data: ${apiResponse.data}');
      
      if (apiResponse.success && apiResponse.data != null) {
        print('✅ Journal entries fetched from API');
        
        // Backend returns data as direct array: { "data": [...] }
        // Not nested like: { "data": { "entries": [...] } }
        dynamic entriesData = apiResponse.data;
        
        // If data is a Map, check for nested structures
        if (entriesData is Map) {
          if (entriesData.containsKey('entries')) {
            entriesData = entriesData['entries'];
          } else if (entriesData.containsKey('data')) {
            entriesData = entriesData['data'];
          }
        }
        
        // Handle direct List response
        if (entriesData is List) {
          print('✅ Processing ${entriesData.length} journal entries');
          return entriesData
              .map<JournalEntry>((json) {
                try {
                  final entry = JournalEntry.fromJson(json as Map<String, dynamic>);
                  print('📝 Entry ${entry.id}: conversation length = ${entry.conversation.length}');
                  return entry;
                } catch (e) {
                  print('❌ Error parsing entry: $e');
                  print('❌ Entry data: $json');
                  rethrow;
                }
              })
              .toList();
        } else {
          print('❌ Unexpected entries data format: ${entriesData.runtimeType}');
          print('❌ Data: $entriesData');
        }
      }
      
      throw Exception('Failed to fetch journal entries: ${apiResponse.error?.message}');
    } catch (e, stackTrace) {
      print('❌ Error fetching journal entries: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to fetch journal entries: $e');
    }
  }

  Future<JournalEntry> getJournalEntry(String entryId) async {
    try {
      print('🔄 Fetching journal entry: $entryId');
      final apiResponse = await _journalServiceApi.getEntry(entryId);
      
      if (apiResponse.success && apiResponse.data != null) {
        print('✅ Journal entry fetched from API');
        final entry = JournalEntry.fromJson(apiResponse.data as Map<String, dynamic>);
        print('📝 Entry has ${entry.conversation.length} conversation messages');
        return entry;
      }
      
      throw Exception('Failed to fetch journal entry: ${apiResponse.error?.message}');
    } catch (e, stackTrace) {
      print('❌ Error fetching journal entry: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to fetch journal entry: $e');
    }
  }

  Future<JournalEntry> createJournalEntry({
    required String title,
    required String content,
    required String? mood,
    required int? moodValue,
    required List<Map<String, String>> conversation,
  }) async {
    try {
      // Backend handles AI and summary generation
      if (mood == null || mood.isEmpty) {
        throw Exception('Mood is required');
      }

      print('🔄 Creating journal entry via API...');
      final apiResponse = await _journalServiceApi.createEntry(
        content: content.trim(),
        mood: mood,
        tags: [],
      );

      print('📦 Create entry response success: ${apiResponse.success}');
      print('📦 Create entry response data: ${apiResponse.data}');

      if (apiResponse.success && apiResponse.data != null) {
        print('✅ Journal entry created via API');
        
        // Try different possible response structures
        dynamic entryData = apiResponse.data;
        
        if (entryData is Map && entryData.containsKey('entry')) {
          entryData = entryData['entry'];
        } else if (entryData is Map && entryData.containsKey('data')) {
          entryData = entryData['data'];
        }
        
        if (entryData != null) {
          return JournalEntry.fromJson(entryData);
        } else {
          print('❌ Entry data is null');
        }
      }
      
      throw Exception('Failed to create journal entry: ${apiResponse.error?.message}');
    } catch (e, stackTrace) {
      print('❌ Error in createJournalEntry: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to create journal entry: $e');
    }
  }

  Future<JournalEntry> updateJournalEntry({
    required String id,
    String? title,
    String? content,
    String? mood,
    int? moodValue,
    List<Map<String, String>>? conversation,
  }) async {
    try {
      final apiResponse = await _journalServiceApi.updateEntry(
        entryId: id,
        content: content,
        mood: mood,
        tags: null,
      );

      if (apiResponse.success && apiResponse.data != null) {
        print('✅ Journal entry updated via API');
        final entry = apiResponse.data!['entry'];
        if (entry != null) {
          return JournalEntry.fromJson(entry);
        }
      }
      
      throw Exception('Failed to update journal entry: ${apiResponse.error?.message}');
    } catch (e) {
      throw Exception('Failed to update journal entry: $e');
    }
  }

  Future<void> deleteJournalEntry(String id) async {
    try {
      final apiResponse = await _journalServiceApi.deleteEntry(id);

      if (apiResponse.success) {
        print('✅ Journal entry deleted via API');
        return;
      }
      
      throw Exception('Failed to delete journal entry: ${apiResponse.error?.message}');
    } catch (e) {
      throw Exception('Failed to delete journal entry: $e');
    }
  }

  Stream<List<JournalEntry>> streamJournalEntries() {
    // For real-time updates, you could implement WebSocket or polling
    // For now, we'll throw an exception as streaming requires backend support
    throw UnimplementedError('Real-time streaming requires WebSocket implementation');
  }

  // AI Suggestions - Backend handles this
  Future<List<String>> getAiSuggestions({
    required String mood,
    String? context,
    String? mode,
  }) async {
    try {
      final apiResponse = await _journalServiceApi.getAiSuggestions(
        mood: mood,
        context: context,
        mode: mode ?? 'suggestions',
      );

      if (apiResponse.success && apiResponse.data != null) {
        print('✅ AI suggestions fetched from API');
        final suggestions = apiResponse.data!['suggestions'];
        if (suggestions is List) {
          return suggestions.cast<String>();
        }
      }

      throw Exception('Failed to get AI suggestions: ${apiResponse.error?.message}');
    } catch (e) {
      throw Exception('Failed to get AI suggestions: $e');
    }
  }

  // Mood Analytics - Backend handles this
  Future<Map<String, dynamic>> getMoodAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final apiResponse = await _journalServiceApi.getMoodAnalytics(
        startDate: startDate.toIso8601String(),
        endDate: endDate.toIso8601String(),
      );

      if (apiResponse.success && apiResponse.data != null) {
        print('✅ Mood analytics fetched from API');
        return apiResponse.data!;
      }

      throw Exception('Failed to get mood analytics: ${apiResponse.error?.message}');
    } catch (e) {
      throw Exception('Failed to get mood analytics: $e');
    }
  }

  // Calendar Entries
  Future<List<JournalEntry>> getCalendarEntries({
    required int year,
    required int month,
  }) async {
    try {
      final apiResponse = await _journalServiceApi.getCalendarEntries(
        year: year,
        month: month,
      );

      if (apiResponse.success && apiResponse.data != null) {
        print('✅ Calendar entries fetched from API');
        final entries = apiResponse.data!['entries'];
        if (entries is List) {
          return entries
              .map<JournalEntry>((json) => JournalEntry.fromJson(json))
              .toList();
        }
      }

      throw Exception('Failed to get calendar entries: ${apiResponse.error?.message}');
    } catch (e) {
      throw Exception('Failed to get calendar entries: $e');
    }
  }
}
