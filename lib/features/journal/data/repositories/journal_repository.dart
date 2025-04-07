import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenspace/core/config/supabase_config.dart';
import 'package:zenspace/features/journal/domain/models/journal_entry.dart';

class JournalRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<JournalEntry>> getJournalEntries() async {
    try {
      final response = await _client
          .from('journal_entries')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => JournalEntry.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch journal entries: $e');
    }
  }

  Future<List<JournalEntry>> getJournalEntriesByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _client
          .from('journal_entries')
          .select()
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String())
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => JournalEntry.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch journal entries: $e');
    }
  }

  Future<JournalEntry> createJournalEntry({
    required String content,
    required JournalMood mood,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client.from('journal_entries').insert({
        'user_id': userId,
        'content': content,
        'mood': mood.toString().split('.').last,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      return JournalEntry.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create journal entry: $e');
    }
  }

  Future<void> deleteJournalEntry(String id) async {
    try {
      await _client.from('journal_entries').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete journal entry: $e');
    }
  }

  Future<JournalEntry> updateJournalEntry({
    required String id,
    required String content,
    required JournalMood mood,
  }) async {
    try {
      final response = await _client
          .from('journal_entries')
          .update({
            'content': content,
            'mood': mood.toString().split('.').last,
          })
          .eq('id', id)
          .select()
          .single();

      return JournalEntry.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update journal entry: $e');
    }
  }
} 