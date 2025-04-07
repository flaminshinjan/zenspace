import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/journal_entry.dart';

class JournalService {
  final SupabaseClient _supabaseClient;

  JournalService(this._supabaseClient);

  Future<List<JournalEntry>> getJournalEntries() async {
    final response = await _supabaseClient
        .from('journal_entries')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((entry) => JournalEntry.fromJson(entry))
        .toList();
  }

  Future<JournalEntry> createJournalEntry({
    required String content,
    required String mood,
  }) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User must be authenticated to create a journal entry');
    }

    final response = await _supabaseClient.from('journal_entries').insert({
      'user_id': userId,
      'content': content,
      'mood': mood,
    }).select().single();

    return JournalEntry.fromJson(response);
  }

  Future<void> deleteJournalEntry(String id) async {
    await _supabaseClient.from('journal_entries').delete().eq('id', id);
  }

  Future<JournalEntry> updateJournalEntry({
    required String id,
    required String content,
    required String mood,
  }) async {
    final response = await _supabaseClient
        .from('journal_entries')
        .update({
          'content': content,
          'mood': mood,
        })
        .eq('id', id)
        .select()
        .single();

    return JournalEntry.fromJson(response);
  }
} 